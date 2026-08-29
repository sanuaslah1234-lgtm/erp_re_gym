import 'package:bcrypt/bcrypt.dart';

class PasswordService {
  static String hashPassword(String password) {
    final salt = BCrypt.gensalt();
    return BCrypt.hashpw(password, salt);
  }

  static bool verifyPassword(String password, String hashedPassword) {
    if (hashedPassword.isEmpty) return false;
    if (password == hashedPassword) return true;
    try {
      if (hashedPassword.startsWith(r'$2a$') ||
          hashedPassword.startsWith(r'$2b$') ||
          hashedPassword.startsWith(r'$2y$') ||
          hashedPassword.startsWith(r'$2$')) {
        return BCrypt.checkpw(password, hashedPassword);
      }
    } catch (_) {}
    return password == hashedPassword;
  }
}
