import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'package:erp_software/core/models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerController {
  final CustomerService service;

  CustomerController(this.service);

  // CREATE
  Future<Response> createCustomer(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final customer = CustomerModel(
        branchId: data['branchId']?.toString(),
        name: data['name']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
        email: data['email']?.toString(),
        address: data['address']?.toString(),
        loyaltyId: data['loyaltyId']?.toString(),
        creditLimit:
            double.tryParse(data['creditLimit']?.toString() ?? '0') ?? 0,
        currentBalance:
            double.tryParse(data['currentBalance']?.toString() ?? '0') ?? 0,
      );

      final created = await service.createCustomer(customer);

      return Response(
        201,
        body: jsonEncode({
          'success': true,
          'message': 'Customer created successfully',
          'data': created.toMap(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return Response(
        500,
        body: jsonEncode({
          'success': false,
          'message': 'Failed to create customer',
          'error': e.toString(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    }
  }

  // GET ALL
  Future<Response> getCustomers(Request request) async {
    try {
      final customers = await service.getCustomers();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': customers.map((customer) {
            return customer.toMap();
          }).toList(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return Response(
        500,
        body: jsonEncode({
          'success': false,
          'message': 'Failed to get customers',
          'error': e.toString(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    }
  }

  // GET BY ID
  Future<Response> getCustomerById(
    Request request,
    String id
    ) async {
    try {

      final customer = await service.getCustomerById(id);

      if (customer == null) {
        return Response(
          404,
          body: jsonEncode({
            'success': false,
            'message': 'Customer not found',
          }),
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': customer.toMap(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return Response(
        500,
        body: jsonEncode({
          'success': false,
          'message': 'Failed to get customer',
          'error': e.toString(),
        }),
      );
    }
  }

  // UPDATE
  Future<Response> updateCustomer(Request request,String id) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final customer = CustomerModel(
        branchId: data['branchId']?.toString(),
        name: data['name']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
        email: data['email']?.toString(),
        address: data['address']?.toString(),
        loyaltyId: data['loyaltyId']?.toString(),
        creditLimit:
            double.tryParse(data['creditLimit']?.toString() ?? '0') ?? 0,
        currentBalance:
            double.tryParse(data['currentBalance']?.toString() ?? '0') ?? 0,
      );

      final updated = await service.updateCustomer(
        id,
        customer,
      );

      if (updated == null) {
        return Response(
          404,
          body: jsonEncode({
            'success': false,
            'message': 'Customer not found',
          }),
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Customer updated successfully',
          'data': updated.toMap(),
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    } catch (e) {
      return Response(
        500,
        body: jsonEncode({
          'success': false,
          'message': 'Failed to update customer',
          'error': e.toString(),
        }),
      );
    }
  }

  // DELETE
  // DELETE
Future<Response> deleteCustomer(
  Request request,
  String id,
) async {
  try {
    final deleted = await service.deleteCustomer(id);

    if (!deleted) {
      return Response(
        404,
        body: jsonEncode({
          'success': false,
          'message': 'Customer not found',
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    }

    return Response.ok(
      jsonEncode({
        'success': true,
        'message': 'Customer deleted successfully',
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  } catch (e) {
    return Response(
      500,
      body: jsonEncode({
        'success': false,
        'message': 'Failed to delete customer',
        'error': e.toString(),
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  }
}
}