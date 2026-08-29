import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'package:erp_software/backend/admin/audit_log/services/audit_log_service.dart';

class AuditLogController {
  final AuditLogService service;

  AuditLogController(this.service);

  // ============================================================
  // GET /admin/audit-logs?search=&action=&module=
  // ============================================================

  Future<Response> getLogs(Request request) async {
    try {
      final params = request.url.queryParameters;

      final data = await service.getLogsPage(
        search: params['search'],
        action: params['action'],
        module: params['module'],
      );

      return _success(message: 'Audit logs fetched successfully', data: data);
    } catch (e) {
      return _serverError('Failed to fetch audit logs', e);
    }
  }

  // ============================================================
  // GET /admin/audit-logs/employee/<id>
  // <id> is the employee's numeric database id (employees.id)
  // ============================================================

  Future<Response> getEmployeeTimeline(Request request, String id) async {
    try {
      final parsedId = int.tryParse(id);
      if (parsedId == null) return _badRequest('Invalid employee id');

      final data = await service.getEmployeeTimelinePage(parsedId);
      if (data == null) return _notFound('Employee not found');

      return _success(message: 'Employee timeline fetched successfully', data: data);
    } catch (e) {
      return _serverError('Failed to fetch employee timeline', e);
    }
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  Response _success({required String message, dynamic data}) {
    final response = <String, dynamic>{'success': true, 'message': message};
    if (data != null) response['data'] = data;
    return Response(200, body: jsonEncode(response), headers: {'Content-Type': 'application/json'});
  }

  Response _badRequest(String message) {
    return Response(400,
        body: jsonEncode({'success': false, 'message': message}),
        headers: {'Content-Type': 'application/json'});
  }

  Response _notFound(String message) {
    return Response(404,
        body: jsonEncode({'success': false, 'message': message}),
        headers: {'Content-Type': 'application/json'});
  }

  Response _serverError(String message, Object error) {
    return Response(500,
        body: jsonEncode({'success': false, 'message': message, 'error': error.toString()}),
        headers: {'Content-Type': 'application/json'});
  }
}