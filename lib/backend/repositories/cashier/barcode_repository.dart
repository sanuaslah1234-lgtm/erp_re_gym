import 'package:erp_software/core/models/cashier/barcode_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class BarcodeRepository {
  final PostgresService db;

  BarcodeRepository(this.db);

  Future<BarcodeModel> createBarcode({
    required int productId,
    required String barcode,
    int labelQuantity = 1,
    int? createdBy,
  }) async {
    final sql = '''
      INSERT INTO barcodes (product_id, barcode, label_quantity, created_by)
      VALUES (@productId, @barcode, @qty, @createdBy)
      RETURNING id, created_at
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'productId': productId,
        'barcode': barcode,
        'qty': labelQuantity,
        'createdBy': createdBy,
      },
    );

    final id = result.first[0] as int;
    final createdAt = DateTime.parse(result.first[1].toString());

    // Fetch product details for preview model
    final prodRes = await db.connection.execute(
      Sql.named('SELECT name, product_code, selling_price FROM products WHERE id = @id'),
      parameters: {'id': productId},
    );

    final prodMap = prodRes.isNotEmpty ? prodRes.first.toColumnMap() : <String, dynamic>{};

    return BarcodeModel(
      id: id,
      productId: productId,
      productName: prodMap['name'] as String?,
      productCode: prodMap['product_code'] as String?,
      sellingPrice: prodMap['selling_price'] != null ? (prodMap['selling_price'] as num).toDouble() : null,
      barcode: barcode,
      labelQuantity: labelQuantity,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  Future<List<BarcodeModel>> getAllBarcodes() async {
    final sql = '''
      SELECT b.*, p.name as product_name, p.product_code, p.selling_price
      FROM barcodes b
      JOIN products p ON b.product_id = p.id
      ORDER BY b.created_at DESC
    ''';

    final result = await db.connection.execute(sql);
    return result.map((row) => BarcodeModel.fromJson(row.toColumnMap())).toList();
  }
}

