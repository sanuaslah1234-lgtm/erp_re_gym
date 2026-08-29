import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../services/product_service.dart';

class ProductController {
  final ProductService productService;

  ProductController(this.productService);

  // ==========================================================
  // CREATE
  // POST /products
  // ==========================================================

  Future<Response> createProduct(
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

      final sku =
          body['sku']?.toString().trim();

      if (name == null || name.isEmpty) {
        return _badRequest(
          'Product name is required',
        );
      }

      if (sku == null || sku.isEmpty) {
        return _badRequest(
          'SKU is required',
        );
      }

      final product =
          await productService.createProduct(
        name: name,
        sku: sku,
      );

      return Response(
        201,
        body: jsonEncode({
          'success': true,
          'message': 'Product created successfully',
          'data': product,
        }),
        headers: _headers,
      );
    } catch (e) {
      print('CREATE PRODUCT ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // GET ALL
  // GET /products
  // ==========================================================

  Future<Response> getProducts(
    Request request,
  ) async {
    try {
      final products =
          await productService.getProducts();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': products,
        }),
        headers: _headers,
      );
    } catch (e) {
      print('GET PRODUCTS ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // GET BY ID
  // GET /products/<id>
  // ==========================================================

  Future<Response> getProductById(
    Request request,
    String id,
  ) async {
    try {
      final product =
          await productService.getProductById(id);

      if (product == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Product not found',
          }),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': product,
        }),
        headers: _headers,
      );
    } catch (e) {
      print('GET PRODUCT ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // UPDATE
  // PUT /products/<id>
  // ==========================================================

  Future<Response> updateProduct(
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

      final sku =
          body['sku']?.toString().trim();

      if (name == null || name.isEmpty) {
        return _badRequest(
          'Product name is required',
        );
      }

      if (sku == null || sku.isEmpty) {
        return _badRequest(
          'SKU is required',
        );
      }

      final product =
          await productService.updateProduct(
        id: id,
        name: name,
        sku: sku,
      );

      if (product == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Product not found',
          }),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Product updated successfully',
          'data': product,
        }),
        headers: _headers,
      );
    } catch (e) {
      print('UPDATE PRODUCT ERROR: $e');

      return _serverError(e);
    }
  }

  // ==========================================================
  // DELETE
  // DELETE /products/<id>
  // ==========================================================

  Future<Response> deleteProduct(
    Request request,
    String id,
  ) async {
    try {
      final deleted =
          await productService.deleteProduct(id);

      if (!deleted) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': 'Product not found',
          }),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Product deleted successfully',
        }),
        headers: _headers,
      );
    } catch (e) {
      print('DELETE PRODUCT ERROR: $e');

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