import 'dart:convert';
import 'package:erp_software/backend/services/auth_service.dart';
import 'package:erp_software/backend/services/jwt_service.dart';
import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/backend/utils/response_utils.dart';
import 'package:shelf/shelf.dart';

class AuthController {
  final AuthService authService;

  AuthController(this.authService);

  Future<Response> login(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return ResponseUtils.error(message: 'Request body cannot be empty', statusCode: 400);
      }

      final data = jsonDecode(bodyStr) as Map<String, dynamic>;
      final identifier = (data['identifier'] ?? data['email'] ?? data['employeeId'] ?? data['employee_id'])?.toString().trim();
      final password = data['password']?.toString();

      if (identifier == null || password == null) {
        return ResponseUtils.error(message: 'Email and password are required', statusCode: 400);
      }

      final authResponse = await authService.login(identifier, password);

      return ResponseUtils.success(
        message: 'Login successful',
        data: authResponse.toJson(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Login failed', statusCode: 500, error: e);
    }
  }

  Future<Response> logout(Request request) async {
    return ResponseUtils.success(message: 'Logout successful');
  }

  Future<Response> me(Request request) async {
    try {
      final payload = request.context['user'] as JwtPayload?;
      if (payload == null) {
        return ResponseUtils.error(message: 'Unauthorized', statusCode: 401);
      }

      final authResponse = await authService.getCurrentUser(payload.userId);

      return ResponseUtils.success(
        message: 'User profile fetched successfully',
        data: authResponse.toJson(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to fetch profile', statusCode: 500, error: e);
    }
  }

  Future<Response> forgotPassword(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return ResponseUtils.error(message: 'Email is required', statusCode: 400);
      }

      final data = jsonDecode(bodyStr) as Map<String, dynamic>;
      final email = data['email']?.toString().trim();

      if (email == null || email.isEmpty) {
        return ResponseUtils.error(message: 'Email address is required', statusCode: 400);
      }

      final otpCode = await authService.sendPasswordResetOtp(email);

      return ResponseUtils.success(
        message: 'OTP has been dispatched to $email',
        data: {'otp': otpCode, 'email': email},
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to send reset OTP', statusCode: 500, error: e);
    }
  }

  Future<Response> verifyOtp(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return ResponseUtils.error(message: 'Email and OTP are required', statusCode: 400);
      }

      final data = jsonDecode(bodyStr) as Map<String, dynamic>;
      final email = data['email']?.toString().trim();
      final otp = data['otp']?.toString().trim();

      if (email == null || otp == null || email.isEmpty || otp.isEmpty) {
        return ResponseUtils.error(message: 'Email and OTP are required', statusCode: 400);
      }

      final isVerified = await authService.verifyOtp(email, otp);

      return ResponseUtils.success(
        message: 'OTP verified successfully',
        data: {'verified': isVerified},
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'OTP verification failed', statusCode: 500, error: e);
    }
  }

  Future<Response> resetPassword(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return ResponseUtils.error(message: 'Request body cannot be empty', statusCode: 400);
      }

      final data = jsonDecode(bodyStr) as Map<String, dynamic>;
      final email = data['email']?.toString().trim();
      final otp = data['otp']?.toString().trim();
      final newPassword = data['newPassword']?.toString();

      if (email == null || otp == null || newPassword == null) {
        return ResponseUtils.error(message: 'Email, OTP, and new password are required', statusCode: 400);
      }

      await authService.resetPassword(email, otp, newPassword);

      return ResponseUtils.success(
        message: 'Password reset successfully. You can now login with your new password.',
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Password reset failed', statusCode: 500, error: e);
    }
  }
}

