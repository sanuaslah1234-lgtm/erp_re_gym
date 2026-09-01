import 'package:dotenv/dotenv.dart';

class AppConfig {
  static final DotEnv _env = _initEnv();

  static DotEnv _initEnv() {
    final env = DotEnv();
    try {
      env.load(['.env', '.env']);
    } catch (_) {}
    return env;
  }

  /// Helper: check _env first, then dart-define, then default
  static String _get(String key, {String fallback = ''}) {
    final envVal = _env[key];
    if (envVal != null && envVal.isNotEmpty) return envVal;
    // dart-define fallback (set via --dart-define=KEY=VALUE)
    const dartDefine = String.fromEnvironment('', defaultValue: '');
    if (dartDefine.isNotEmpty) return dartDefine;
    return fallback;
  }

  // Database settings
  static String get dbHost => _get('DB_HOST', fallback: _get('DATABASE_HOST', fallback: 'localhost'));
  static int get dbPort => int.tryParse(_get('DB_PORT', fallback: _get('DATABASE_PORT', fallback: '5432'))) ?? 5432;
  static String get dbName => _get('DB_NAME', fallback: _get('DATABASE_NAME', fallback: 'Erp'));
  static String get dbUser => _get('DB_USER', fallback: _get('DATABASE_USER', fallback: 'postgres'));
  static String get dbPassword => _get('DB_PASSWORD', fallback: _get('DATABASE_PASSWORD', fallback: 'postgresql123'));

  // API Server settings
  static int get apiPort => int.tryParse(_get('API_PORT', fallback: '5000')) ?? 5000;
  static String get apiBaseUrl => _get('API_BASE_URL', fallback: 'http://localhost:5000');
  static String get jwtSecret => _get('JWT_SECRET', fallback: 'default_erp_jwt_secret_key');

  // SMTP Email Settings
  static String get smtpHost => _get('SMTP_HOST');
  static int get smtpPort => int.tryParse(_get('SMTP_PORT', fallback: '587')) ?? 587;
  static String get smtpUser => _get('SMTP_USER');
  static String get smtpPass => _get('SMTP_PASS');
  static String get smtpSenderName => _get('SMTP_SENDER_NAME', fallback: 'ERP System');
  static bool get smtpEnableTls => (_get('SMTP_ENABLE_TLS', fallback: 'true')).toLowerCase() == 'true';
}
