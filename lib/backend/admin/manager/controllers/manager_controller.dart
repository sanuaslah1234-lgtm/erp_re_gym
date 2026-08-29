import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'package:erp_software/backend/admin/manager/services/manager_service.dart';

class ManagerController {
  final ManagerService service;

  ManagerController(this.service);

  // ============================================================
  // POST /admin/managers
  // ============================================================

  Future<Response> createManager(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final manager = await service.createManager(body);

      return _success(
        status: 201,
        message: 'Manager created successfully',
        data: manager.toJson(),
      );
    } on ManagerValidationException catch (e) {
      return _badRequest(e.message);
    } catch (e) {
      return _serverError('Failed to create manager', e);
    }
  }

  // ============================================================
  // GET /admin/managers
  // ============================================================

  Future<Response> getManagers(Request request) async {
    try {
      final managers = await service.getManagers();
      return _success(
        message: 'Managers fetched successfully',
        data: managers.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return _serverError('Failed to fetch managers', e);
    }
  }

  // ============================================================
  // GET /admin/managers/<id>
  // ============================================================

  Future<Response> getManagerById(Request request, String id) async {
    try {
      final parsedId = int.tryParse(id);
      if (parsedId == null) return _badRequest('Invalid manager id');

      final manager = await service.getManagerById(parsedId);
      if (manager == null) return _notFound('Manager not found');

      return _success(message: 'Manager fetched successfully', data: manager.toJson());
    } catch (e) {
      return _serverError('Failed to fetch manager', e);
    }
  }

  // ============================================================
  // PUT /admin/managers/<id>
  // ============================================================

  Future<Response> updateManager(Request request, String id) async {
    try {
      final parsedId = int.tryParse(id);
      if (parsedId == null) return _badRequest('Invalid manager id');

      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final manager = await service.updateManager(parsedId, body);

      if (manager == null) return _notFound('Manager not found');

      return _success(message: 'Manager updated successfully', data: manager.toJson());
    } on ManagerValidationException catch (e) {
      return _badRequest(e.message);
    } catch (e) {
      return _serverError('Failed to update manager', e);
    }
  }

  // ============================================================
  // DELETE /admin/managers/<id>
  // ============================================================

  Future<Response> deleteManager(Request request, String id) async {
    try {
      final parsedId = int.tryParse(id);
      if (parsedId == null) return _badRequest('Invalid manager id');

      final deleted = await service.deleteManager(parsedId);
      if (!deleted) return _notFound('Manager not found');

      return _success(message: 'Manager deleted successfully');
    } catch (e) {
      return _serverError('Failed to delete manager', e);
    }
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  Response _success({int status = 200, required String message, dynamic data}) {
    final response = <String, dynamic>{'success': true, 'message': message};
    if (data != null) response['data'] = data;

    return Response(
      status,
      body: jsonEncode(response),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _badRequest(String message) {
    return Response(
      400,
      body: jsonEncode({'success': false, 'message': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _notFound(String message) {
    return Response(
      404,
      body: jsonEncode({'success': false, 'message': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _serverError(String message, Object error) {
    return Response(
      500,
      body: jsonEncode({
        'success': false,
        'message': message,
        'error': error.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}