import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../services/warehouse_service.dart';

class WarehouseController {
  final WarehouseService warehouseService;

  WarehouseController(this.warehouseService);

  // ==========================================================
  // CREATE
  // POST /warehouses
  // ==========================================================

  Future<Response> createWarehouse(
    Request request,
  ) async {
    try {
      final body = jsonDecode(
        await request.readAsString(),
      );

      if (body is! Map) {
        return _badRequest(
          'Invalid request body',
        );
      }

      final name =
          body['name']?.toString().trim();

      if (name == null || name.isEmpty) {
        return _badRequest(
          'Warehouse name is required',
        );
      }

      final warehouse =
          await warehouseService.createWarehouse(
        name: name,
      );

      return Response(
        201,
        body: jsonEncode({
          'success': true,
          'message':
              'Warehouse created successfully',
          'data': warehouse,
        }),
        headers: _headers,
      );
    } catch (e) {
      print('CREATE WAREHOUSE ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // GET ALL
  // GET /warehouses
  // ==========================================================

  Future<Response> getWarehouses(
    Request request,
  ) async {
    try {
      final warehouses =
          await warehouseService.getWarehouses();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': warehouses,
        }),
        headers: _headers,
      );
    } catch (e) {
      print('GET WAREHOUSES ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // GET BY ID
  // GET /warehouses/<id>
  // ==========================================================

  Future<Response> getWarehouseById(
    Request request,
    String id,
  ) async {
    try {
      final warehouse =
          await warehouseService.getWarehouseById(
        id,
      );

      if (warehouse == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Warehouse not found',
          }),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': warehouse,
        }),
        headers: _headers,
      );
    } catch (e) {
      print('GET WAREHOUSE ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // UPDATE
  // PUT /warehouses/<id>
  // ==========================================================

  Future<Response> updateWarehouse(
    Request request,
    String id,
  ) async {
    try {
      final body = jsonDecode(
        await request.readAsString(),
      );

      if (body is! Map) {
        return _badRequest(
          'Invalid request body',
        );
      }

      final name =
          body['name']?.toString().trim();

      if (name == null || name.isEmpty) {
        return _badRequest(
          'Warehouse name is required',
        );
      }

      final warehouse =
          await warehouseService.updateWarehouse(
        id: id,
        name: name,
      );

      if (warehouse == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Warehouse not found',
          }),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message':
              'Warehouse updated successfully',
          'data': warehouse,
        }),
        headers: _headers,
      );
    } catch (e) {
      print('UPDATE WAREHOUSE ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // DELETE
  // DELETE /warehouses/<id>
  // ==========================================================

  Future<Response> deleteWarehouse(
    Request request,
    String id,
  ) async {
    try {
      final deleted =
          await warehouseService.deleteWarehouse(
        id,
      );

      if (!deleted) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Warehouse not found',
          }),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message':
              'Warehouse deleted successfully',
        }),
        headers: _headers,
      );
    } catch (e) {
      print('DELETE WAREHOUSE ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  Response _badRequest(String message) {
    return Response(
      400,
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: _headers,
    );
  }

  Response _serverError(Object error) {
    return Response.internalServerError(
      body: jsonEncode({
        'success': false,
        'message': error.toString(),
      }),
      headers: _headers,
    );
  }

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };
}