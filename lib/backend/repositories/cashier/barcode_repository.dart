import 'package:erp_software/core/models/cashier/barcode_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class BarcodeRepository {
  final PostgresService db;

  BarcodeRepository(this.db);

  bool _barcodesTableEnsured = false;
  Future<void> _ensureBarcodesTable() async {
    if (_barcodesTableEnsured) return;
    try {
      await db.connection.execute('''
        CREATE TABLE IF NOT EXISTS barcodes (
          id SERIAL PRIMARY KEY,
          product_id INT NOT NULL,
          barcode VARCHAR(100) NOT NULL,
          label_quantity INT NOT NULL DEFAULT 1,
          created_by INT,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
      ''');
      _barcodesTableEnsured = true;
    } catch (e) {
      print('Error ensuring barcodes table: $e');
    }
  }

  Future<BarcodeModel> createBarcode({
    required int productId,
    required String barcode,
    int labelQuantity = 1,
    int? createdBy,
  }) async {
    await _ensureBarcodesTable();

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

    final id = int.tryParse(result.first[0].toString());
    final createdAt = DateTime.parse(result.first[1].toString());

    // Fetch product details for preview model
    final prodRes = await db.connection.execute(
      Sql.named('SELECT name, product_code, selling_price FROM products WHERE id::text = @idStr LIMIT 1'),
      parameters: {'idStr': productId.toString()},
    );

    final prodMap = prodRes.isNotEmpty ? prodRes.first.toColumnMap() : <String, dynamic>{};

    return BarcodeModel(
      id: id,
      productId: productId,
      productName: prodMap['name'] as String?,
      productCode: prodMap['product_code'] as String?,
      sellingPrice: prodMap['selling_price'] != null ? double.tryParse(prodMap['selling_price'].toString()) : null,
      barcode: barcode,
      labelQuantity: labelQuantity,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  Future<List<BarcodeModel>> getAllBarcodes() async {
    await _ensureBarcodesTable();

    final sql = '''
      SELECT b.*, p.name as product_name, p.product_code, p.selling_price
      FROM barcodes b
      LEFT JOIN products p ON b.product_id::text = p.id::text
      ORDER BY b.created_at DESC
    ''';

    final result = await db.connection.execute(sql);
    return result.map((row) => BarcodeModel.fromJson(row.toColumnMap())).toList();
  }
}

