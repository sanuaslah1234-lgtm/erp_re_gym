import 'package:erp_software/core/models/cashier/barcode_model.dart';
import 'package:erp_software/backend/repositories/cashier/barcode_repository.dart';

class BarcodeService {
  final BarcodeRepository barcodeRepository;

  BarcodeService(this.barcodeRepository);

  Future<BarcodeModel> generateBarcodePrint({
    required int productId,
    required String barcode,
    int labelQuantity = 1,
    int? createdBy,
  }) async {
    return await barcodeRepository.createBarcode(
      productId: productId,
      barcode: barcode,
      labelQuantity: labelQuantity,
      createdBy: createdBy,
    );
  }

  Future<List<BarcodeModel>> getBarcodeHistory() async {
    return await barcodeRepository.getAllBarcodes();
  }
}
