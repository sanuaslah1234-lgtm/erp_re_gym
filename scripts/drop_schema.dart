import 'package:erp_software/backend/database/postgres_service.dart';

void main() async {
  final db = PostgresService();
  await db.connect();
  
  print('Dropping schema public...');
  await db.connection.execute('DROP SCHEMA public CASCADE;');
  print('Creating schema public...');
  await db.connection.execute('CREATE SCHEMA public;');
  print('Done.');
}
