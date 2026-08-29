import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../services/inventory_service.dart';


class InventoryController {
  final InventoryService inventoryService;
  InventoryController(this.inventoryService);

  // =========================================================
  // GET ALL
  // =========================================================

  Future<Response> getInventory(
    Request request,
  ) async {
    try {
      final params = request.url.queryParameters;

      final search = params['search'];

      final warehouseId =
          params['warehouseId'];

      final status =
          params['status'];

      final sort =
          params['sort'] ?? 'latest';

      final inventory =
          await inventoryService.getInventory(
        search: search,
        warehouseId: warehouseId,
        status: status,
        sort: sort,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'count': inventory.length,
          'data': inventory
              .map((item) => item.toMap())
              .toList(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': e.toString(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    }
  }

  // =========================================================
  // GET ONE
  // =========================================================

  Future<Response> getInventoryById(
    Request request,
    String id,
  ) async {
    try {
      final inventory =
          await inventoryService.getInventoryById(id);

      if (inventory == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Inventory not found',
          }),
          headers: {
            'Content-Type':
                'application/json',
          },
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': inventory.toMap(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': e.toString(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    }
  }

  // =========================================================
  // CREATE
  // =========================================================

  Future<Response> createInventory(
    Request request,
  ) async {
    try {
      final body =
          jsonDecode(await request.readAsString());

      final inventory =
          await inventoryService.createInventory(
        productId:
            body['productId'],

        warehouseId:
            body['warehouseId'],

        quantity:
            body['quantity'] ?? 0,

        minimumStock:
            body['minimumStock'] ?? 10,

        maximumStock:
            body['maximumStock'] ?? 1000,

        reorderLevel:
            body['reorderLevel'] ?? 20,
      );

      return Response(
        201,
        body: jsonEncode({
          'success': true,
          'message':
              'Inventory created successfully',
          'data': inventory.toMap(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': e.toString(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<Response> updateInventory(
    Request request,
    String id,
  ) async {
    try {
      final body =
          jsonDecode(await request.readAsString());

      final inventory =
          await inventoryService.updateInventory(
        id: id,

        productId:
            body['productId'],

        warehouseId:
            body['warehouseId'],

        quantity:
            body['quantity'],

        minimumStock:
            body['minimumStock'],

        maximumStock:
            body['maximumStock'],

        reorderLevel:
            body['reorderLevel'],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message':
              'Inventory updated successfully',
          'data': inventory.toMap(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': e.toString(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<Response> deleteInventory(
    Request request,
    String id,
  ) async {
    try {
      await inventoryService.deleteInventory(id);

      return Response.ok(
        jsonEncode({
          'success': true,
          'message':
              'Inventory deleted successfully',
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': e.toString(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    }
  }

  // =========================================================
  // UPDATE QUANTITY
  // =========================================================

  Future<Response> updateQuantity(
    Request request,
    String id,
  ) async {
    try {
      final body =
          jsonDecode(await request.readAsString());

      final quantity =
          body['quantity'];

      if (quantity == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message':
                'Quantity is required',
          }),
          headers: {
            'Content-Type':
                'application/json',
          },
        );
      }

      final inventory =
          await inventoryService.updateQuantity(
        id: id,
        quantity: quantity,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message':
              'Quantity updated successfully',
          'data': inventory.toMap(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': e.toString(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    }
  }
}