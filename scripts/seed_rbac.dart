import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/backend/database/rbac_seeder.dart';

Future<void> main() async {
  print('--- Seeding Unified RBAC (Roles & Permissions) ---');
  final db = PostgresService();
  try {
    await db.connect();
    final seeder = RbacSeeder(db);
    await seeder.seedAll();
    print('✅ RBAC Roles and Permissions seeded successfully!');
  } catch (e) {
    print('❌ Error seeding RBAC: $e');
  } finally {
    await db.close();
  }
}
