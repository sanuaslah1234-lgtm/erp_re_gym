// import 'package:erp_software/core/models/employee_model.dart';
// import 'package:erp_software/core/models/user_model.dart';
// import 'package:erp_software/backend/database/postgres_service.dart';
// import 'package:postgres/postgres.dart';

// class EmployeeRepository {
//   final PostgresService db;

//   EmployeeRepository(this.db);

//   /// Creates both [users] and [employees] records in a single PostgreSQL transaction
//   Future<EmployeeModel> createEmployeeTransaction({
//     required String email,
//     required String hashedPassword,
//     required String role,
//     required String employeeId,
//     required String fullName,
//     String? phone,
//     String? department,
//     String? designation,
//     String? joiningDate,
//     bool isVerified = false,
//   }) async {
//     return await db.connection.runTx((session) async {
//       // 1. Insert into users table
//       final userResult = await session.execute(
//         Sql.named('''
//           INSERT INTO users (email, password_hash, role, name, is_active)
//           VALUES (@email, @password_hash, @role, @name, true)
//           RETURNING id, email, role, is_active, created_at, updated_at
//         '''),
//         parameters: {
//           'email': email,
//           'password_hash': hashedPassword,
//           'role': role,
//           'name': fullName,
//         },
//       );

//       final userRow = userResult.first;
//       final userId = userRow[0] as int;

//       final userModel = UserModel(
//         id: userId,
//         email: userRow[1] as String,
//         role: userRow[2] as String,
//         isActive: userRow[3] as bool,
//         createdAt: userRow[4] != null ? DateTime.tryParse(userRow[4].toString()) : null,
//         updatedAt: userRow[5] != null ? DateTime.tryParse(userRow[5].toString()) : null,
//       );

//       // 2. Insert into employees table
//       final empResult = await session.execute(
//         Sql.named('''
//           INSERT INTO employees (
//             user_id, employee_id, full_name, phone, department, designation, joining_date, is_verified
//           )
//           VALUES (
//             @user_id, @employee_id, @full_name, @phone, @department, @designation, @joining_date, @is_verified
//           )
//           RETURNING id, user_id, employee_id, full_name, phone, department, designation, joining_date, is_verified, created_at, updated_at
//         '''),
//         parameters: {
//           'user_id': userId,
//           'employee_id': employeeId,
//           'full_name': fullName,
//           'phone': phone,
//           'department': department,
//           'designation': designation,
//           'joining_date': joiningDate != null && joiningDate.isNotEmpty ? DateTime.tryParse(joiningDate) : null,
//           'is_verified': isVerified,
//         },
//       );

//       final empRow = empResult.first;

//       return EmployeeModel(
//         id: empRow[0] as int,
//         userId: empRow[1] as int,
//         employeeId: empRow[2] as String,
//         fullName: empRow[3] as String,
//         phone: empRow[4]?.toString(),
//         department: empRow[5]?.toString(),
//         designation: empRow[6]?.toString(),
//         joiningDate: empRow[7]?.toString(),
//         isVerified: empRow[8] as bool,
//         createdAt: empRow[9] != null ? DateTime.tryParse(empRow[9].toString()) : null,
//         updatedAt: empRow[10] != null ? DateTime.tryParse(empRow[10].toString()) : null,
//         user: userModel,
//       );
//     });
//   }

//   Future<List<EmployeeModel>> getAllEmployees() async {
//     final result = await db.connection.execute('''
//       SELECT
//         e.id, e.user_id, e.employee_id, e.full_name, e.phone, e.department, e.designation, e.joining_date, e.is_verified, e.created_at, e.updated_at,
//         u.email, u.role, u.is_active, u.last_login_at
//       FROM employees e
//       INNER JOIN users u ON e.user_id = u.id
//       ORDER BY e.id DESC
//     ''');

//     return result.map((row) {
//       return EmployeeModel(
//         id: row[0] as int,
//         userId: row[1] as int,
//         employeeId: row[2] as String,
//         fullName: row[3] as String,
//         phone: row[4]?.toString(),
//         department: row[5]?.toString(),
//         designation: row[6]?.toString(),
//         joiningDate: row[7]?.toString(),
//         isVerified: row[8] as bool,
//         createdAt: row[9] != null ? DateTime.tryParse(row[9].toString()) : null,
//         updatedAt: row[10] != null ? DateTime.tryParse(row[10].toString()) : null,
//         user: UserModel(
//           id: row[1] as int,
//           email: row[11] as String,
//           role: row[12] as String,
//           isActive: row[13] as bool,
//           lastLoginAt: row[14] != null ? DateTime.tryParse(row[14].toString()) : null,
//         ),
//       );
//     }).toList();
//   }

//   Future<EmployeeModel?> getEmployeeById(int id) async {
//     final result = await db.connection.execute(
//       Sql.named('''
//         SELECT
//           e.id, e.user_id, e.employee_id, e.full_name, e.phone, e.department, e.designation, e.joining_date, e.is_verified, e.created_at, e.updated_at,
//           u.email, u.role, u.is_active, u.last_login_at
//         FROM employees e
//         INNER JOIN users u ON e.user_id = u.id
//         WHERE e.id = @id
//         LIMIT 1
//       '''),
//       parameters: {'id': id},
//     );

//     if (result.isEmpty) return null;
//     final row = result.first;

//     return EmployeeModel(
//       id: row[0] as int,
//       userId: row[1] as int,
//       employeeId: row[2] as String,
//       fullName: row[3] as String,
//       phone: row[4]?.toString(),
//       department: row[5]?.toString(),
//       designation: row[6]?.toString(),
//       joiningDate: row[7]?.toString(),
//       isVerified: row[8] as bool,
//       createdAt: row[9] != null ? DateTime.tryParse(row[9].toString()) : null,
//       updatedAt: row[10] != null ? DateTime.tryParse(row[10].toString()) : null,
//       user: UserModel(
//         id: row[1] as int,
//         email: row[11] as String,
//         role: row[12] as String,
//         isActive: row[13] as bool,
//         lastLoginAt: row[14] != null ? DateTime.tryParse(row[14].toString()) : null,
//       ),
//     );
//   }

//   Future<EmployeeModel?> getEmployeeByUserId(int userId) async {
//     final result = await db.connection.execute(
//       Sql.named('''
//         SELECT
//           e.id, e.user_id, e.employee_id, e.full_name, e.phone, e.department, e.designation, e.joining_date, e.is_verified, e.created_at, e.updated_at,
//           u.email, u.role, u.is_active, u.last_login_at
//         FROM employees e
//         INNER JOIN users u ON e.user_id = u.id
//         WHERE e.user_id = @user_id
//         LIMIT 1
//       '''),
//       parameters: {'user_id': userId},
//     );

//     if (result.isEmpty) return null;
//     final row = result.first;

//     return EmployeeModel(
//       id: row[0] as int,
//       userId: row[1] as int,
//       employeeId: row[2] as String,
//       fullName: row[3] as String,
//       phone: row[4]?.toString(),
//       department: row[5]?.toString(),
//       designation: row[6]?.toString(),
//       joiningDate: row[7]?.toString(),
//       isVerified: row[8] as bool,
//       createdAt: row[9] != null ? DateTime.tryParse(row[9].toString()) : null,
//       updatedAt: row[10] != null ? DateTime.tryParse(row[10].toString()) : null,
//       user: UserModel(
//         id: row[1] as int,
//         email: row[11] as String,
//         role: row[12] as String,
//         isActive: row[13] as bool,
//         lastLoginAt: row[14] != null ? DateTime.tryParse(row[14].toString()) : null,
//       ),
//     );
//   }

//   Future<EmployeeModel?> updateEmployee(int id, Map<String, dynamic> data) async {
//     final emp = await getEmployeeById(id);
//     if (emp == null) return null;

//     // Update user role/email if provided
//     if (data['role'] != null || data['email'] != null) {
//       await db.connection.execute(
//         Sql.named('''
//           UPDATE users
//           SET
//             role = COALESCE(@role, role),
//             email = COALESCE(@email, email),
//             updated_at = CURRENT_TIMESTAMP
//           WHERE id = @user_id
//         '''),
//         parameters: {
//           'user_id': emp.userId,
//           'role': data['role'],
//           'email': data['email'],
//         },
//       );
//     }

//     // Update employee record
//     await db.connection.execute(
//       Sql.named('''
//         UPDATE employees
//         SET
//           employee_id = COALESCE(@employee_id, employee_id),
//           full_name = COALESCE(@full_name, full_name),
//           phone = COALESCE(@phone, phone),
//           department = COALESCE(@department, department),
//           designation = COALESCE(@designation, designation),
//           is_verified = COALESCE(@is_verified, is_verified),
//           updated_at = CURRENT_TIMESTAMP
//         WHERE id = @id
//       '''),
//       parameters: {
//         'id': id,
//         'employee_id': data['employee_id'],
//         'full_name': data['full_name'],
//         'phone': data['phone'],
//         'department': data['department'],
//         'designation': data['designation'],
//         'is_verified': data['is_verified'],
//       },
//     );

//     return await getEmployeeById(id);
//   }

//   Future<bool> deleteEmployee(int id) async {
//     final emp = await getEmployeeById(id);
//     if (emp == null) return false;

//     // Deleting user automatically cascades to employees table due to ON DELETE CASCADE
//     final result = await db.connection.execute(
//       Sql.named('DELETE FROM users WHERE id = @user_id'),
//       parameters: {'user_id': emp.userId},
//     );

//     return result.affectedRows > 0;
//   }
// }

