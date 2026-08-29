import 'package:erp_software/backend/services/cashier/pos_service.dart';
import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/backend/utils/response_utils.dart';
import 'package:shelf/shelf.dart';

class PosController {
  final PosService posService;

  PosController(this.posService);

  Future<Response> getProducts(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final search = queryParams['search'];
      final catId = queryParams['categoryId'] != null ? int.tryParse(queryParams['categoryId']!) : null;

      final products = await posService.searchProducts(search: search, categoryId: catId);

      return ResponseUtils.success(
        message: 'Products fetched successfully',
        data: products.map((p) => p.toJson()).toList(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to fetch products', statusCode: 500, error: e);
    }
  }

  Future<Response> getProductByBarcode(Request request, String barcode) async {
    try {
      final product = await posService.getProductByBarcode(barcode);
      return ResponseUtils.success(
        message: 'Product found',
        data: product.toJson(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to scan product barcode', statusCode: 500, error: e);
    }
  }

  Future<Response> getCategories(Request request) async {
    try {
      final categories = await posService.getCategories();
      return ResponseUtils.success(
        message: 'Categories fetched successfully',
        data: categories,
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to fetch categories', statusCode: 500, error: e);
    }
  }
}

