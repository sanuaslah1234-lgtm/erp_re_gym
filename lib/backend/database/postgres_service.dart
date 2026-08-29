import 'dart:io';
import 'package:postgres/postgres.dart';
import '../../core/config/app_config.dart';

class PostgresService {
  Connection? _connection;

  Connection get connection {
    if (_connection == null || !_connection!.isOpen) {
      throw Exception('Database connection has not been initialized. Call connect() first.');
    }
    return _connection!;
  }

  Future<void> connect() async {
    if (_connection != null && _connection!.isOpen) {
      return; // Already connected
    }

    final host = AppConfig.dbHost;
    final port = AppConfig.dbPort;
    final database = AppConfig.dbName;
    final username = AppConfig.dbUser;
    final password = AppConfig.dbPassword;

    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );

    // Verify connection
    await _connection!.execute('SELECT 1');

    stdout.writeln('PostgreSQL connected successfully to $database');
  }

  Future<void> close() async {
    if (_connection != null && _connection!.isOpen) {
      await _connection!.close();
      _connection = null;
    }
  }
}