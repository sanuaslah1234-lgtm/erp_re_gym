import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:erp_software/core/config/app_config.dart';

class JwtPayload {
  final dynamic userId;
  final String email;
  final String role;

  const JwtPayload({
    required this.userId,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'role': role,
      };
}

class JwtService {
  static String generateToken(JwtPayload payload) {
    final jwt = JWT(
      payload.toJson(),
      issuer: 'erp_software',
    );
    return jwt.sign(
      SecretKey(AppConfig.jwtSecret),
      expiresIn: const Duration(days: 7),
    );
  }

  static JwtPayload? verifyToken(String token) {
    try {
      final jwt = JWT.verify(
        token,
        SecretKey(AppConfig.jwtSecret),
      );
      final payloadData = jwt.payload as Map<String, dynamic>;
      return JwtPayload(
        userId: payloadData['userId'],
        email: payloadData['email'] as String,
        role: payloadData['role'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}
