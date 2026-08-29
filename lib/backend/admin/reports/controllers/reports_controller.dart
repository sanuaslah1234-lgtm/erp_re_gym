import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'package:erp_software/backend/admin/reports/services/reports_service.dart';

class ReportsController {
  final ReportsService service;

  ReportsController(this.service);

  // ============================================================
  // GET /admin/reports/sales?from=YYYY-MM-DD&to=YYYY-MM-DD&customer=&search=
  // Returns { summary: {...}, records: [...] } in one call
  // ============================================================

  Future<Response> getSalesReport(Request request) async {
    try {
      final params = request.url.queryParameters;

      final now = DateTime.now();
      final defaultFrom = now.subtract(const Duration(days: 30));

      final from = params['from'] != null
          ? DateTime.tryParse(params['from']!) ?? defaultFrom
          : defaultFrom;

      final to = params['to'] != null
          ? DateTime.tryParse(params['to']!) ?? now
          : now;

      if (from.isAfter(to)) {
        return _badRequest('"from" date cannot be after "to" date');
      }

      final data = await service.getSalesReport(
        from: from,
        to: to,
        customer: params['customer'],
        search: params['search'],
      );

      return _success(
        message: 'Sales report fetched successfully',
        data: data,
      );
    } catch (e) {
      return _serverError('Failed to fetch sales report', e);
    }
  }

  // ============================================================
  // GET /admin/reports/customers
  // ============================================================

  Future<Response> getCustomers(Request request) async {
    try {
      final customers = await service.getCustomers();

      return _success(
        message: 'Customers fetched successfully',
        data: customers,
      );
    } catch (e) {
      return _serverError('Failed to fetch customers', e);
    }
  }

  // ============================================================
  // GET /admin/reports/purchases?from=&to=&supplier=&search=
  // ============================================================

  Future<Response> getPurchaseReport(Request request) async {
    try {
      final params = request.url.queryParameters;

      final now = DateTime.now();
      final defaultFrom = now.subtract(const Duration(days: 30));

      final from = params['from'] != null
          ? DateTime.tryParse(params['from']!) ?? defaultFrom
          : defaultFrom;
      final to = params['to'] != null ? DateTime.tryParse(params['to']!) ?? now : now;

      if (from.isAfter(to)) {
        return _badRequest('"from" date cannot be after "to" date');
      }

      final data = await service.getPurchaseReport(
        from: from,
        to: to,
        supplier: params['supplier'],
        search: params['search'],
      );

      return _success(message: 'Purchase report fetched successfully', data: data);
    } catch (e) {
      return _serverError('Failed to fetch purchase report', e);
    }
  }

  // ============================================================
  // GET /admin/reports/suppliers
  // ============================================================

  Future<Response> getSuppliers(Request request) async {
    try {
      final suppliers = await service.getSuppliers();
      return _success(message: 'Suppliers fetched successfully', data: suppliers);
    } catch (e) {
      return _serverError('Failed to fetch suppliers', e);
    }
  }

  // ============================================================
  // GET /admin/reports/inventory?category=&search=
  // ============================================================

  Future<Response> getInventoryReport(Request request) async {
    try {
      final params = request.url.queryParameters;

      final data = await service.getInventoryReport(
        category: params['category'],
        search: params['search'],
      );

      return _success(message: 'Inventory report fetched successfully', data: data);
    } catch (e) {
      return _serverError('Failed to fetch inventory report', e);
    }
  }

  // ============================================================
  // GET /admin/reports/categories
  // ============================================================

  Future<Response> getCategories(Request request) async {
    try {
      final categories = await service.getCategories();
      return _success(message: 'Categories fetched successfully', data: categories);
    } catch (e) {
      return _serverError('Failed to fetch categories', e);
    }
  }

  // ============================================================
  // RESPONSE HELPERS (same shape as BranchController)
  // ============================================================

  Response _success({required String message, dynamic data}) {
    final response = <String, dynamic>{'success': true, 'message': message};
    if (data != null) response['data'] = data;

    return Response(
      200,
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