import 'dart:io';
import 'package:erp_software/backend/database/migration_runner.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/core/config/app_config.dart';
import 'package:postgres/postgres.dart';

Future<void> main() async {
  print('--- ERP Migration Script ---');
  print('Ensuring database exists...');

  try {
    final defaultConnection = await Connection.open(
      Endpoint(
        host: AppConfig.dbHost,
        port: AppConfig.dbPort,
        database: 'postgres',
        username: AppConfig.dbUser,
        password: AppConfig.dbPassword,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    final dbName = AppConfig.dbName;
    final result = await defaultConnection.execute(
      Sql.named('SELECT 1 FROM pg_database WHERE datname = @dbName'),
      parameters: {'dbName': dbName},
    );

    if (result.isEmpty) {
      await defaultConnection.execute('CREATE DATABASE "$dbName"');
      print('Database "$dbName" created successfully.');
    } else {
      print('Database "$dbName" already exists.');
    }
    await defaultConnection.close();
  } catch (e) {
    print('Failed to check/create database: $e');
  }

  print('\nConnecting to ERP database...');
  final postgresService = PostgresService();
  await postgresService.connect();

  print('\nStarting migrations...');
  final runner = MigrationRunner(postgresService);
  await runner.runMigrations();

  await postgresService.close();
  print('--- Migration Script Complete ---');
  exit(0);
}
