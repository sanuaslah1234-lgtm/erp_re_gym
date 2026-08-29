import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

Future<void> main() async {
  print('--- ERP Seed Script ---');
  final postgresService = PostgresService();
  await postgresService.connect();

  try {
    print('Seeding default Admin user...');
    final defaultPassword = BCrypt.hashpw('admin123', BCrypt.gensalt());
    final result = await postgresService.connection.execute(
      Sql.named('''
        INSERT INTO users (email, password_hash, role) 
        VALUES (@email, @password, 'admin') 
        ON CONFLICT (email) DO NOTHING 
        RETURNING id
      '''),
      parameters: {
        'email': 'admin@erp.com',
        'password': defaultPassword,
      },
    );

    if (result.isNotEmpty) {
      final userId = result.first[0] as int;
      print('Seeding admin employee record...');
      await postgresService.connection.execute(
        Sql.named('''
          INSERT INTO employees (user_id, employee_id, full_name, email, phone, role, password_hash, is_verified) 
          VALUES (@userId, 'EMP-001', 'System Admin', 'admin@erp.com', '0000000000', 'admin', @password, true) 
          ON CONFLICT (employee_id) DO NOTHING
        '''),
        parameters: {
          'userId': userId,
          'password': defaultPassword,
        },
      );
      print('Admin user seeded (admin@erp.com / admin123)');
    } else {
      print('Admin user already exists.');
    }

    print('Seeding completed successfully.');
  } catch (e) {
    print('Error during seeding: $e');
  }

  await postgresService.close();
  exit(0);
}
