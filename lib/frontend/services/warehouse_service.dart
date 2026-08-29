import 'dart:convert';

import 'package:erp_software/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

import 'package:erp_software/core/models/warehouse_model.dart';

class WarehouseService {
  static const String baseUrl = AppConstants.apiBaseUrl;

  Future<List<WarehouseModel>> getWarehouses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/warehouses'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch warehouses: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map &&
        decoded['data'] is List) {
      data = decoded['data'];
    } else {
      throw Exception(
        'Invalid warehouses response',
      );
    }

    return data
        .map(
          (json) => WarehouseModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }
}
