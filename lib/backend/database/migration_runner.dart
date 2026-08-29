import 'dart:io';
import 'package:postgres/postgres.dart';
import 'postgres_service.dart';

class MigrationRunner {
  final PostgresService postgresService;

  MigrationRunner(this.postgresService);

  Future<void> runMigrations() async {
    final migrationDirectory = Directory('lib/backend/database/migrations');

    if (!migrationDirectory.existsSync()) {
      print('Migration directory not found.');
      return;
    }

    final files = migrationDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.sql'))
        .toList();

    files.sort((a, b) => a.path.compareTo(b.path));

    // Ensure schema_migrations table exists
    if (files.isNotEmpty && files.first.path.endsWith('001_create_schema_migrations.sql')) {
      final sql = await files.first.readAsString();
      await _executeSqlStatements(postgresService.connection, sql);
    }

    for (final file in files) {
      final migrationName = file.uri.pathSegments.last;
      
      // Check if migration is already applied
      final result = await postgresService.connection.execute(
        Sql.named('SELECT id FROM schema_migrations WHERE migration_name = @name'),
        parameters: {'name': migrationName},
      );

      if (result.isNotEmpty) {
        continue;
      }

      print('Running migration: $migrationName');
      final sql = await file.readAsString();
      
      try {
        await postgresService.connection.runTx((session) async {
          await _executeSqlStatements(session, sql);
          
          await session.execute(
            Sql.named('INSERT INTO schema_migrations (migration_name) VALUES (@name)'),
            parameters: {'name': migrationName},
          );
        });
        print('Migration completed: $migrationName');
      } catch (e) {
        print('Error executing migration $migrationName: $e');
        rethrow;
      }
    }

    print('All migrations completed.');
  }

  Future<void> _executeSqlStatements(Session session, String sql) async {
    final statements = sql
        .split(';')
        .map((statement) => statement.trim())
        .where((statement) => statement.isNotEmpty)
        .toList();

    for (final statement in statements) {
      await session.execute(statement);
    }
  }
}