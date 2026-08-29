import 'dart:convert';

import 'package:erp_software/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

import 'package:erp_software/core/models/customer_model.dart';

class CustomerService {
static const baseUrl = AppConstants.apiBaseUrl;
  Future<List<CustomerModel>> getCustomers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customers'),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final List data = body['data'];

      return data
          .map(
            (json) => CustomerModel.fromJson(json),
          )
          .toList();
    }

    throw Exception(
      'Failed to load customers: ${response.body}',
    );
  }

  Future<CustomerModel> getCustomerById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customers/$id'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return CustomerModel.fromJson(
        body['data'],
      );
    }

    throw Exception(
      'Customer not found: ${response.body}',
    );
  }

  Future<CustomerModel> createCustomer(
    CustomerModel customer,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/customers'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        customer.toJson(),
      ),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);

      return CustomerModel.fromJson(
        body['data'],
      );
    }
    throw Exception(
      'Failed to create customer: ${response.body}',
    );
  }

  Future<CustomerModel> updateCustomer(
    String id,
    CustomerModel customer,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/customers/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        customer.toJson(),
      ),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return CustomerModel.fromJson(
        body['data'],
      );
    }

    throw Exception(
      'Failed to update customer: ${response.body}',
    );
  }

  Future<void> deleteCustomer(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/customers/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete customer: ${response.body}',
      );
    }
  }
}

