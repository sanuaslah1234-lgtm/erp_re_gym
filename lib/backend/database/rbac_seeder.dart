import 'package:bcrypt/bcrypt.dart';
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
      AppRoles.gymSuperAdmin: 'Full super admin access to all Gym Management features',
      AppRoles.retailSuperAdmin: 'Full super admin access to all ERP and Retail features',
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
          ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description
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

    // 4. Seed / Upsert Dedicated Super Admin Users
    final defaultPasswordHash = BCrypt.hashpw('admin123', BCrypt.gensalt());

    final superAdminUsers = [
      {
        'email': 'superadmingym@gmail.com',
        'role': AppRoles.gymSuperAdmin,
        'fullName': 'Gym Super Admin',
        'empId': 'EMP_GYM001',
        'department': 'Gym Management',
        'designation': 'Gym Super Administrator',
      },
      {
        'email': 'superadminretail@gmail.com',
        'role': AppRoles.retailSuperAdmin,
        'fullName': 'Retail Super Admin',
        'empId': 'EMP_RET001',
        'department': 'Retail Management',
        'designation': 'Retail Super Administrator',
      },
      {
        'email': 'admin@erp.com',
        'role': AppRoles.superAdmin,
        'fullName': 'System Admin',
        'empId': 'EMP001',
        'department': 'Executive',
        'designation': 'Administrator',
      },
    ];

    int _empIndex = 0;
    for (final u in superAdminUsers) {
      final email = u['email']!;
      final role = u['role']!;
      final fullName = u['fullName']!;
      final empId = u['empId']!;
      final department = u['department']!;
      final designation = u['designation']!;
      final phone = '+1${++_empIndex}000000000';

      final roleRes = await conn.execute(
        Sql.named('SELECT id FROM roles WHERE UPPER(name) = UPPER(@name) LIMIT 1'),
        parameters: {'name': role},
      );
      final roleId = roleRes.isNotEmpty ? roleRes.first.toColumnMap()['id'].toString() : null;

      final userCheck = await conn.execute(
        Sql.named('SELECT id FROM users WHERE LOWER(email) = LOWER(@email) LIMIT 1'),
        parameters: {'email': email},
      );

      dynamic userId;
      if (userCheck.isEmpty) {
        final insertRes = await conn.execute(
          Sql.named('''
            INSERT INTO users (email, password_hash, plain_password, role, role_id, is_active, is_verified, employee_id)
            VALUES (@email, @hash, 'admin123', @role, @role_id, true, true, @emp_id)
            RETURNING id
          '''),
          parameters: {
            'email': email,
            'hash': defaultPasswordHash,
            'role': role,
            'role_id': roleId,
            'emp_id': empId,
          },
        );
        userId = insertRes.first[0];
      } else {
        userId = userCheck.first[0];
        await conn.execute(
          Sql.named('''
            UPDATE users 
            SET role = @role,
                role_id = @role_id,
                password_hash = COALESCE(password_hash, @hash),
                plain_password = COALESCE(plain_password, 'admin123'),
                is_active = true,
                is_verified = true,
                employee_id = @emp_id
            WHERE LOWER(email) = LOWER(@email)
          '''),
          parameters: {
            'role': role,
            'role_id': roleId,
            'hash': defaultPasswordHash,
            'emp_id': empId,
            'email': email,
          },
        );
      }

      // Ensure employee record exists
      final empCheck = await conn.execute(
        Sql.named('SELECT id FROM employees WHERE LOWER(email) = LOWER(@email) LIMIT 1'),
        parameters: {'email': email},
      );

      final userIdInt = int.tryParse(userId.toString());

      if (empCheck.isEmpty) {
        await conn.execute(
          Sql.named('''
            INSERT INTO employees (user_id, employee_id, full_name, email, phone, password_hash, department, designation, is_verified, role)
            VALUES (@user_id, @emp_id, @full_name, @email, @phone, @hash, @department, @designation, true, @role)
          '''),
          parameters: {
            'user_id': userIdInt,
            'emp_id': empId,
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'hash': defaultPasswordHash,
            'department': department,
            'designation': designation,
            'role': role,
          },
        );
      } else {
        await conn.execute(
          Sql.named('''
            UPDATE employees
            SET full_name = @full_name,
                role = @role,
                department = @department,
                designation = @designation
            WHERE LOWER(email) = LOWER(@email)
          '''),
          parameters: {
            'full_name': fullName,
            'role': role,
            'department': department,
            'designation': designation,
            'email': email,
          },
        );
      }
    }
  }
}
