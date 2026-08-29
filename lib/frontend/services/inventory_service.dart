import 'dart:convert';

import 'package:erp_software/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

import 'package:erp_software/core/models/inventory_model.dart';
import 'package:flutter/material.dart';
class InventoryService {

  static const String baseUrl = AppConstants.apiBaseUrl;

  Future<List<InventoryModel>> getInventory({
    String? search,
    String? warehouseId,
    String? status,
  }) async {
    try {
      final queryParameters = <String, String>{};

      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      if (warehouseId != null &&
          warehouseId.isNotEmpty) {
        queryParameters['warehouseId'] = warehouseId;
      }

      if (status != null &&
          status.isNotEmpty) {
        queryParameters['status'] = status;
      }

      final uri = Uri.parse(
        '$baseUrl/api/inventory',
      ).replace(
        queryParameters:
            queryParameters.isEmpty
                ? null
                : queryParameters,
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch inventory: '
          '${response.statusCode}',
        );
      }

      final decoded =
          jsonDecode(response.body);

      /*
       * Supports:
       *
       * [
       *   {...},
       *   {...}
       * ]
       *
       * OR
       *
       * {
       *   "data": [...]
       * }
       */

      final List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map &&
          decoded['data'] is List) {
        data = decoded['data'];
      } else {
        throw Exception(
          'Invalid inventory response',
        );
      }

      return data
          .map(
            (json) => InventoryModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to fetch inventory: $e',
      );
    }
  }

  // ==========================================================
  // GET INVENTORY BY ID
  // ==========================================================

  Future<InventoryModel> getInventoryById(
    String id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/inventory/$id',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch inventory',
        );
      }

      final decoded =
          jsonDecode(response.body);

      final data =
          decoded is Map &&
                  decoded['data'] != null
              ? decoded['data']
              : decoded;

      return InventoryModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      throw Exception(
        'Failed to fetch inventory item: $e',
      );
    }
  }

  // ==========================================================
  // CREATE INVENTORY
  // ==========================================================

  // Future<InventoryModel> createInventory({
  //   required String productId,
  //   required String warehouseId,
  //   required int quantity,
  //   required int minStock,
  //   required int maxStock,
  //   required int reorderLevel,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //         '$baseUrl/api/inventory',
  //       ),
  //       headers: {
  //         'Content-Type':
  //             'application/json',
  //       },
  //       body: jsonEncode({
  //         'productId': productId,
  //         'warehouseId': warehouseId,
  //         'quantity': quantity,
  //         'minimumStock': minStock,
  //         'maximumStock': maxStock,
  //         'reorderLevel': reorderLevel,
  //       }),
  //     );

  //     if (response.statusCode != 200 &&
  //         response.statusCode != 201) {
  //       throw Exception(
  //         'Failed to create inventory: '
  //         '${response.statusCode}',
  //       );
  //     }

  //     final decoded =
  //         jsonDecode(response.body);

  //     final data =
  //         decoded is Map &&
  //                 decoded['data'] != null
  //             ? decoded['data']
  //             : decoded;

  //     return InventoryModel.fromJson(
  //       Map<String, dynamic>.from(data),
  //     );
  //   } catch (e) {
  //     throw Exception(
  //       'Failed to create inventory: $e',
  //     );
  //   }
  // }



  //===========================================================
  // TEMPORARY CREATE INVENTORY
  //===========================================================

  Future<InventoryModel> createInventory({
  required String productId,
  required String warehouseId,
  required int quantity,
  required int minStock,
  required int maxStock,
  required int reorderLevel,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/api/inventory');

    final body = {
      'productId': productId,
      'warehouseId': warehouseId,
      'quantity': quantity,
      'minimumStock': minStock,
      'maximumStock': maxStock,
      'reorderLevel': reorderLevel,
    };

    debugPrint('=================================');
    debugPrint('CREATE INVENTORY');
    debugPrint('URL: $uri');
    debugPrint('BODY: $body');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('RESPONSE: ${response.body}');
    debugPrint('=================================');

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Create inventory failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    final data =
        decoded is Map && decoded['data'] != null
            ? decoded['data']
            : decoded;

    if (data is! Map) {
      throw Exception(
        'Invalid server response: ${response.body}',
      );
    }

    return InventoryModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  } catch (e) {
    debugPrint('CREATE INVENTORY ERROR: $e');

    throw Exception(
      'Failed to create inventory: $e',
    );
  }
}


  // ==========================================================
  // UPDATE INVENTORY
  // ==========================================================

  Future<InventoryModel> updateInventory({
    required String id,
    required String productId,
    required String warehouseId,
    required int quantity,
    required int minStock,
    required int maxStock,
    required int reorderLevel,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/inventory/$id',
        ),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'productId': productId,
          'warehouseId': warehouseId,
          'quantity': quantity,
          'minimumStock': minStock,
          'maximumStock': maxStock,
          'reorderLevel': reorderLevel,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update inventory: '
          '${response.statusCode}',
        );
      }

      final decoded =
          jsonDecode(response.body);

      final data =
          decoded is Map &&
                  decoded['data'] != null
              ? decoded['data']
              : decoded;

      return InventoryModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      throw Exception(
        'Failed to update inventory: $e',
      );
    }
  }

  // ==========================================================
  // DELETE INVENTORY
  // ==========================================================

  Future<void> deleteInventory(
    String id,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/api/inventory/$id',
        ),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw Exception(
          'Failed to delete inventory: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to delete inventory: $e',
      );
    }
  }

  // ==========================================================
  // UPDATE QUANTITY
  // ==========================================================

  Future<InventoryModel> updateQuantity({
    required String id,
    required int quantity,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/api/inventory/$id/quantity',
        ),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update quantity: '
          '${response.statusCode}',
        );
      }

      final decoded =
          jsonDecode(response.body);

      final data =
          decoded is Map &&
                  decoded['data'] != null
              ? decoded['data']
              : decoded;

      return InventoryModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      throw Exception(
        'Failed to update quantity: $e',
      );
    }
  }
}
