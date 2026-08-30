import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/backend/services/password_service.dart';
import 'package:erp_software/core/errors/app_exception.dart';
import 'package:postgres/postgres.dart';

import 'package:erp_software/core/models/employee_model.dart';

class EmployeeService {
  final PostgresService postgresService;

  EmployeeService(this.postgresService);

  // =========================================================
  // GET ALL EMPLOYEES
  // =========================================================

  Future<List<EmployeeModel>> getEmployees() async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT
          id,
          full_name,
          email,
          employee_id,
          phone,
          password_hash,
          is_verified,
          first_login,
          role,
          branch_id
        FROM employees
        ORDER BY full_name ASC
      '''),
    );

    return result
        .map(
          (row) => EmployeeModel.fromMap(
            row.toColumnMap(),
          ),
        )
        .toList();
  }

  // =========================================================
  // GET ONE EMPLOYEE
  // =========================================================

  Future<EmployeeModel?> getEmployeeById(
    String id,
  ) async {
    final intId = int.tryParse(id);
    String query = '''
      SELECT
        id,
        full_name,
        email,
        employee_id,
        phone,
        password_hash,
        is_verified,
        first_login,
        role,
        branch_id
      FROM employees
      WHERE employee_id = @id OR LOWER(email) = LOWER(@id)
    ''';
    if (intId != null) {
      query += ' OR id = $intId';
    }
    query += ' LIMIT 1';

    final result = await postgresService.connection.execute(
      Sql.named(query),
      parameters: {
        'id': id,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return EmployeeModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // =========================================================
  // CREATE EMPLOYEE
  // =========================================================

  Future<EmployeeModel> createEmployee({
    required String fullName,
    required String email,
    required String employeeId,
    required String phone,
    required String passwordHash,
    String? role,
    String? roleId,
    String? type,
    String? branchId,
  }) async {
    // 1. Check if employee_id or email already exists in employees table
    final checkEmp = await postgresService.connection.execute(
      Sql.named('''
        SELECT employee_id, email FROM employees 
        WHERE LOWER(employee_id) = LOWER(@empId) OR LOWER(email) = LOWER(@email) 
        LIMIT 1;
      '''),
      parameters: {'empId': employeeId, 'email': email},
    );

    if (checkEmp.isNotEmpty) {
      final r = checkEmp.first;
      if (r[0]?.toString().toLowerCase() == employeeId.toLowerCase()) {
        throw ApiException("Employee ID '$employeeId' is already in use. Please choose a different ID.", statusCode: 400);
      }
      if (r[1]?.toString().toLowerCase() == email.toLowerCase()) {
        throw ApiException("Email '$email' is already registered.", statusCode: 400);
      }
    }

    // 2. Hash password
    final secureHash = passwordHash.startsWith(r'$2')
        ? passwordHash
        : PasswordService.hashPassword(passwordHash);

    // 3. Resolve branch ID if provided
    int? resolvedBranchId = int.tryParse(branchId ?? '');
    if (resolvedBranchId == null && branchId != null && branchId.isNotEmpty) {
      try {
        final bRes = await postgresService.connection.execute(
          Sql.named('SELECT id FROM branches WHERE id::text = @bId OR LOWER(branch_name) = LOWER(@bId) LIMIT 1;'),
          parameters: {'bId': branchId},
        );
        if (bRes.isNotEmpty) {
          resolvedBranchId = int.tryParse(bRes.first[0].toString());
        }
      } catch (_) {}
    }

    // 4. Create/link user in users table for authentication
    try {
      final userCheck = await postgresService.connection.execute(
        Sql.named('SELECT id FROM users WHERE LOWER(email) = LOWER(@email) OR LOWER(employee_id) = LOWER(@empId) LIMIT 1;'),
        parameters: {'email': email, 'empId': employeeId},
      );
      if (userCheck.isEmpty) {
        await postgresService.connection.execute(
          Sql.named('''
            INSERT INTO users (full_name, email, employee_id, phone, password_hash, plain_password, is_verified, role)
            VALUES (@fullName, @email, @employeeId, @phone, @hash, @plain, true, @role)
            ON CONFLICT (email) DO NOTHING;
          '''),
          parameters: {
            'fullName': fullName,
            'email': email,
            'employeeId': employeeId,
            'phone': phone,
            'hash': secureHash,
            'plain': passwordHash,
            'role': role ?? 'employee',
          },
        );
      }
    } catch (e) {
      print('Warning: could not sync user account for employee: $e');
    }

    // 5. Insert employee
    final result = await postgresService.connection.execute(
      Sql.named('''
        INSERT INTO employees (
          full_name,
          email,
          employee_id,
          phone,
          password_hash,
          is_verified,
          first_login,
          role,
          branch_id
        )
        VALUES (
          @fullName,
          @email,
          @employeeId,
          @phone,
          @passwordHash,
          true,
          false,
          @role,
          @branchId
        )
        RETURNING
          id,
          full_name,
          email,
          employee_id,
          phone,
          password_hash,
          is_verified,
          first_login,
          role,
          branch_id
      '''),
      parameters: {
        'fullName': fullName,
        'email': email,
        'employeeId': employeeId,
        'phone': phone,
        'passwordHash': secureHash,
        'role': role ?? 'employee',
        'branchId': resolvedBranchId,
      },
    );

    return EmployeeModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // =========================================================
  // UPDATE EMPLOYEE
  // =========================================================

  Future<EmployeeModel?> updateEmployee({
    required String id,
    String? fullName,
    String? email,
    String? employeeId,
    String? phone,
    String? role,
    String? roleId,
    String? type,
    String? branchId,
  }) async {
    final result = await  postgresService.connection.execute(
      Sql.named('''
        UPDATE employees
        SET
          full_name = COALESCE(@fullName, full_name),
          email = COALESCE(@email, email),
          employee_id = COALESCE(@employeeId, employee_id),
          phone = COALESCE(@phone, phone),
          role = COALESCE(@role, role),
          branch_id = COALESCE(@branchId, branch_id)
        WHERE id = @id
        RETURNING
          id,
          full_name,
          email,
          employee_id,
          phone,
          password_hash,
          is_verified,
          first_login,
          role,
          branch_id
      '''),
      parameters: {
        'id': id,
        'fullName': fullName,
        'email': email,
        'employeeId': employeeId,
        'phone': phone,
        'role': role,
        'branchId': branchId != null ? int.tryParse(branchId) : null,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return EmployeeModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // =========================================================
  // DELETE EMPLOYEE
  // =========================================================

  Future<bool> deleteEmployee(String id) async {
    final result = await  postgresService.connection.execute(
      Sql.named('''
        DELETE FROM employees
        WHERE id = @id
      '''),
      parameters: {
        'id': id,
      },
    );

    return result.affectedRows > 0;
  }
}
