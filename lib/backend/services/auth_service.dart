import 'package:bcrypt/bcrypt.dart';
import 'package:erp_software/backend/models/auth_response_model.dart';
import 'package:erp_software/backend/repositories/auth_repository.dart';
import 'package:erp_software/backend/repositories/employee_repository.dart';
import 'package:erp_software/backend/repositories/otp_repository.dart';
import 'package:erp_software/backend/services/email_service.dart';
import 'package:erp_software/backend/services/jwt_service.dart';
import 'package:erp_software/backend/services/password_service.dart';
import 'package:erp_software/core/errors/api_exception.dart';

class AuthService {
  final AuthRepository authRepository;
  final EmployeeRepository employeeRepository;
  final OtpRepository? otpRepository;
  final EmailService? emailService;

  AuthService({
    required this.authRepository,
    required this.employeeRepository,
    this.otpRepository,
    this.emailService,
  });

  Future<AuthResponseModel> login(String identifier, String password) async {
    final user = await authRepository.findUserByIdentifier(identifier);

    if (user == null || user.passwordHash == null) {
      throw ApiException('Invalid email/ID or password', statusCode: 401);
    }

    final isValidPassword = PasswordService.verifyPassword(password, user.passwordHash!);
    if (!isValidPassword) {
      throw ApiException('Invalid email/ID or password', statusCode: 401);
    }

    if (!user.isActive) {
      throw ApiException('Account has been deactivated. Please contact Admin.', statusCode: 403);
    }

    await authRepository.updateLastLogin(user.id!);

    final employee = await employeeRepository.getEmployeeByUserId(user.id!);

    final token = JwtService.generateToken(
      JwtPayload(
        userId: user.id!,
        email: user.email,
        role: user.role,
      ),
    );

    return AuthResponseModel(
      token: token,
      user: user,
      employee: employee,
    );
  }

  Future<AuthResponseModel> getCurrentUser(int userId) async {
    final user = await authRepository.findUserById(userId);

    if (user == null) {
      throw ApiException('User not found', statusCode: 404);
    }

    final employee = await employeeRepository.getEmployeeByUserId(user.id!);

    final token = JwtService.generateToken(
      JwtPayload(
        userId: user.id!,
        email: user.email,
        role: user.role,
      ),
    );

    return AuthResponseModel(
      token: token,
      user: user,
      employee: employee,
    );
  }

  Future<String> sendPasswordResetOtp(String email) async {
    final user = await authRepository.findUserByEmail(email);
    if (user == null) {
      throw ApiException('No employee account found registered with $email', statusCode: 404);
    }
    if (!user.isActive) {
      throw ApiException('Account is inactive. Cannot reset password.', statusCode: 403);
    }

    final mailer = emailService ?? EmailService();
    final otpCode = mailer.generateOtp();
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));

    if (otpRepository != null) {
      await otpRepository!.saveOtp(
        email: email,
        otpCode: otpCode,
        expiresAt: expiresAt,
      );
    }

    final sent = await mailer.sendOtpEmail(email, otpCode);
    if (!sent) {
      throw ApiException('Failed to send OTP email', statusCode: 500);
    }

    return otpCode;
  }

  Future<bool> verifyOtp(String email, String otp) async {
    if (otpRepository == null) {
      // Dev mode fallback verification
      return otp.length == 6;
    }

    final otpRecord = await otpRepository!.getValidOtp(email: email, otpCode: otp);
    if (otpRecord == null) {
      throw ApiException('Invalid or expired OTP', statusCode: 400);
    }

    return true;
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    if (newPassword.length < 4) {
      throw ApiException('Password must be at least 4 characters', statusCode: 400);
    }

    final isVerified = await verifyOtp(email, otp);
    if (!isVerified) {
      throw ApiException('OTP verification failed', statusCode: 400);
    }

    final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    final user = await authRepository.findUserByEmail(email);

    if (user != null) {
      await authRepository.updatePasswordByEmail(email, hashedPassword);
    } else {
      await authRepository.createUser(
        email: email,
        passwordHash: hashedPassword,
        role: 'employee',
      );
    }

    if (otpRepository != null) {
      final otpRecord = await otpRepository!.getValidOtp(email: email, otpCode: otp);
      if (otpRecord != null) {
        await otpRepository!.markOtpAsUsed(otpRecord.id);
      }
    }
  }
}
