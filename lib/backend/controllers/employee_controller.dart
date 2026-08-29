import 'dart:convert';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:shelf/shelf.dart';

import '../services/employee_service.dart';

class EmployeeController {
  final EmployeeService service;

  EmployeeController(this.service);

  // =========================================================
  // GET
  // =========================================================

  Future<Response> getEmployees(
    Request request,
  ) async {
    try {
      final employees =
          await service.getEmployees();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': employees
              .map((e) => e.toMap())
              .toList(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return _error(
        'Failed to fetch employees',
        e,
      );
    }
  }

  // =========================================================
  // GET ONE
  // =========================================================

  Future<Response> getEmployee(
    Request request,
    String id,
  ) async {
    try {
      final employee =
          await service.getEmployeeById(id);

      if (employee == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Employee not found',
          }),
          headers: {
            'content-type': 'application/json',
          },
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': employee.toMap(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return _error(
        'Failed to fetch employee',
        e,
      );
    }
  }

  // =========================================================
  // CREATE
  // =========================================================

  Future<Response> createEmployee(
    Request request,
  ) async {
    try {
      final body =
          jsonDecode(await request.readAsString());

      final fullName =
          body['fullName']?.toString().trim();

      final email =
          body['email']?.toString().trim();

      final employeeId =
          body['employeeId']?.toString().trim();

      final phone =
          body['phone']?.toString().trim();

      final passwordHash =
          body['password']?.toString();

      if (fullName == null ||
          fullName.isEmpty ||
          email == null ||
          email.isEmpty ||
          employeeId == null ||
          employeeId.isEmpty ||
          phone == null ||
          phone.isEmpty ||
          passwordHash == null ||
          passwordHash.isEmpty) {
        return Response(
          400,
          body: jsonEncode({
            'success': false,
            'message':
                'Required employee fields are missing',
          }),
          headers: {
            'content-type': 'application/json',
          },
        );
      }

      final employee =
          await service.createEmployee(
        fullName: fullName,
        email: email,
        employeeId: employeeId,
        phone: phone,
        passwordHash: passwordHash,
        role: body['role']?.toString(),
        roleId: body['roleId']?.toString(),
        type: body['type']?.toString(),
        branchId: body['branchId']?.toString(),
      );

      return Response(
        201,
        body: jsonEncode({
          'success': true,
          'message': 'Employee created successfully',
          'data': employee.toMap(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return _error(
        'Failed to create employee',
        e,
      );
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<Response> updateEmployee(
    Request request,
    String id,
  ) async {
    try {
      final body =
          jsonDecode(await request.readAsString());

      final employee =
          await service.updateEmployee(
        id: id,
        fullName:
            body['fullName']?.toString(),
        email:
            body['email']?.toString(),
        employeeId:
            body['employeeId']?.toString(),
        phone:
            body['phone']?.toString(),
        role:
            body['role']?.toString(),
        roleId:
            body['roleId']?.toString(),
        type:
            body['type']?.toString(),
        branchId:
            body['branchId']?.toString(),
      );

      if (employee == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Employee not found',
          }),
          headers: {
            'content-type': 'application/json',
          },
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Employee updated successfully',
          'data': employee.toMap(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return _error(
        'Failed to update employee',
        e,
      );
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<Response> deleteEmployee(
    Request request,
    String id,
  ) async {
    try {
      final deleted =
          await service.deleteEmployee(id);

      if (!deleted) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Employee not found',
          }),
          headers: {
            'content-type': 'application/json',
          },
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message':
              'Employee deleted successfully',
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return _error(
        'Failed to delete employee',
        e,
      );
    }
  }

  Response _error(
    String message,
    Object error,
  ) {
    print('Employee error: $error');
    if (error is ApiException) {
      return Response(
        error.statusCode,
        body: jsonEncode({
          'success': false,
          'message': error.message,
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    }

    final errStr = error.toString();
    if (errStr.contains('duplicate key') || errStr.contains('23505')) {
      if (errStr.contains('employee_id')) {
        return Response(
          400,
          body: jsonEncode({
            'success': false,
            'message': 'Employee ID is already in use. Please choose a different ID.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      if (errStr.contains('email')) {
        return Response(
          400,
          body: jsonEncode({
            'success': false,
            'message': 'Email address is already registered.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      if (errStr.contains('phone')) {
        return Response(
          400,
          body: jsonEncode({
            'success': false,
            'message': 'Phone number is already registered.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    }

    return Response.internalServerError(
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  }
}
