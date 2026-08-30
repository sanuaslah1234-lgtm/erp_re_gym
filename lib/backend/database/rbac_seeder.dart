import 'package:postgres/postgres.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/core/constants/app_permissions.dart';

class RbacSeeder {
  final PostgresService postgresService;

  RbacSeeder(this.postgresService);

  Future<void> seedAll() async {
    final conn = postgresService.connection;

    // 1. Seed Roles
    final roleDescriptions = {
      AppRoles.superAdmin: 'Full access to all ERP and Gym Management features',
      AppRoles.erpManager: 'Full access to all ERP operations and analytics',
      AppRoles.erpCashier: 'Access to POS terminal, invoicing, and payment processing',
      AppRoles.inventoryManager: 'Access to products, categories, suppliers, inventory, and warehouses',
      AppRoles.gymManager: 'Full access to all Gym operations, trainers, and reports',
      AppRoles.gymReceptionist: 'Front-desk operations: members, memberships, attendance, and payments',
      AppRoles.gymTrainer: 'Fitness trainer: assigned members, workout plans, attendance, and schedules',
    };

    for (final entry in roleDescriptions.entries) {
      await conn.execute(
        Sql.named('''
          INSERT INTO roles (id, name, description)
          VALUES (gen_random_uuid()::text, @name, @description)
          ON CONFLICT (name) DO NOTHING
        '''),
        parameters: {
          'name': entry.key,
          'description': entry.value,
        },
      );
    }

    // 2. Seed Permissions
    for (final perm in AppPermissions.allPermissions) {
      final module = perm.split('.').first;
      await conn.execute(
        Sql.named('''
          INSERT INTO permissions (name, module, description)
          VALUES (@name, @module, @description)
          ON CONFLICT (name) DO NOTHING
        '''),
        parameters: {
          'name': perm,
          'module': module,
          'description': 'Permission for $perm',
        },
      );
    }

    // 3. Bind Role Permissions
    for (final entry in AppPermissions.rolePermissionsMap.entries) {
      final roleName = entry.key;
      final perms = entry.value;

      final roleRes = await conn.execute(
        Sql.named('SELECT id FROM roles WHERE UPPER(name) = UPPER(@name) LIMIT 1'),
        parameters: {'name': roleName},
      );

      if (roleRes.isEmpty) continue;
      final roleId = roleRes.first.toColumnMap()['id'].toString();

      for (final permName in perms) {
        final permRes = await conn.execute(
          Sql.named('SELECT id FROM permissions WHERE name = @name LIMIT 1'),
          parameters: {'name': permName},
        );

        if (permRes.isEmpty) continue;
        final permId = int.parse(permRes.first.toColumnMap()['id'].toString());

        await conn.execute(
          Sql.named('''
            INSERT INTO role_permissions (role_id, permission_id)
            VALUES (@role_id, @permission_id)
            ON CONFLICT DO NOTHING
          '''),
          parameters: {
            'role_id': roleId,
            'permission_id': permId,
          },
        );
      }
    }

    // 4. Update existing admin user
    await conn.execute(
      Sql.named('''
        UPDATE users 
        SET role_id = (SELECT id FROM roles WHERE UPPER(name) = 'SUPER_ADMIN' LIMIT 1),
            role = 'SUPER_ADMIN'
        WHERE role_id IS NULL AND (UPPER(role) = 'ADMIN' OR UPPER(role) = 'SUPER_ADMIN')
      '''),
    );
  }
}
