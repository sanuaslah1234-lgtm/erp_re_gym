import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'package:erp_software/backend/admin/settings/services/settings_service.dart';

class SettingsController {
  final SettingsService service;

  SettingsController(this.service);

  // ============================================================
  // GET /admin/settings
  // ============================================================

  Future<Response> getSettings(Request request) async {
    try {
      final settings = await service.getSettings();
      return _success(message: 'Settings fetched successfully', data: settings.toJson());
    } catch (e) {
      return _serverError('Failed to fetch settings', e);
    }
  }

  // ============================================================
  // PUT /admin/settings
  // ============================================================

  Future<Response> updateSettings(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final settings = await service.updateSettings(body);
      return _success(message: 'Settings saved successfully', data: settings.toJson());
    } on SettingsValidationException catch (e) {
      return _badRequest(e.message);
    } catch (e) {
      return _serverError('Failed to save settings', e);
    }
  }

  // ============================================================
  // POST /admin/settings/reset
  // ============================================================

  Future<Response> resetSettings(Request request) async {
    try {
      final settings = await service.resetToDefaults();
      return _success(message: 'Settings reset to defaults', data: settings.toJson());
    } catch (e) {
      return _serverError('Failed to reset settings', e);
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

  Response _serverError(String message, Object error) {
    return Response(500,
        body: jsonEncode({'success': false, 'message': message, 'error': error.toString()}),
        headers: {'Content-Type': 'application/json'});
  }
}