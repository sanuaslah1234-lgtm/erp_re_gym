import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/backend/repositories/cashier/product_repository.dart';
import 'package:erp_software/core/errors/app_exception.dart';

class PosService {
  final ProductRepository productRepository;

  PosService(this.productRepository);

  Future<List<ProductModel>> searchProducts({String? search, int? categoryId}) async {
    return await productRepository.getAllProducts(search: search, categoryId: categoryId);
  }

  Future<ProductModel> getProductByBarcode(String barcode) async {
    final product = await productRepository.findByBarcode(barcode);
    if (product == null) {
      throw ApiException('No active product found with barcode "$barcode"', statusCode: 404);
    }
    return product;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await productRepository.getCategories();
  }
}

