import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class OtpRecord {
  final int id;
  final String email;
  final String otpCode;
  final DateTime expiresAt;
  final bool isUsed;
  final DateTime createdAt;

  OtpRecord({
    required this.id,
    required this.email,
    required this.otpCode,
    required this.expiresAt,
    required this.isUsed,
    required this.createdAt,
  });
}

class OtpRepository {
  final PostgresService db;

  OtpRepository(this.db);

  Future<void> saveOtp({
    required String email,
    required String otpCode,
    required DateTime expiresAt,
  }) async {
    // First mark existing active OTPs for this email as used
    await db.connection.execute(
      Sql.named('''
        UPDATE otp_verifications
        SET is_used = true
        WHERE LOWER(email) = LOWER(@email) AND is_used = false
      '''),
      parameters: {'email': email},
    );

    // Insert new OTP record
    await db.connection.execute(
      Sql.named('''
        INSERT INTO otp_verifications (email, otp_code, expires_at, is_used)
        VALUES (@email, @otp_code, @expires_at, false)
      '''),
      parameters: {
        'email': email,
        'otp_code': otpCode,
        'expires_at': expiresAt,
      },
    );
  }

  Future<OtpRecord?> getValidOtp({
    required String email,
    required String otpCode,
  }) async {
    final result = await db.connection.execute(
      Sql.named('''
        SELECT id, email, otp_code, expires_at, is_used, created_at
        FROM otp_verifications
        WHERE LOWER(email) = LOWER(@email)
          AND otp_code = @otp_code
          AND is_used = false
          AND expires_at > CURRENT_TIMESTAMP
        ORDER BY created_at DESC
        LIMIT 1
      '''),
      parameters: {
        'email': email,
        'otp_code': otpCode,
      },
    );

    if (result.isEmpty) return null;
    final row = result.first;

    return OtpRecord(
      id: row[0] as int,
      email: row[1] as String,
      otpCode: row[2] as String,
      expiresAt: DateTime.parse(row[3].toString()),
      isUsed: row[4] as bool,
      createdAt: DateTime.parse(row[5].toString()),
    );
  }

  Future<void> markOtpAsUsed(int id) async {
    await db.connection.execute(
      Sql.named('''
        UPDATE otp_verifications
        SET is_used = true
        WHERE id = @id
      '''),
      parameters: {'id': id},
    );
  }
}

