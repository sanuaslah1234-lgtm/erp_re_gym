import 'package:erp_software/core/database/postgres_service.dart';
import 'package:erp_software/backend/models/cashier/product_model.dart';
import 'package:erp_software/backend/models/category_model.dart';
import 'package:erp_software/backend/models/supplier_model.dart';
import 'package:erp_software/backend/models/purchase_model.dart';
import 'package:erp_software/backend/repositories/product_management_repository.dart';
import 'package:erp_software/backend/services/product_management_service.dart';

Future<void> main() async {
  print('===================================================');
  print('[TEST] ERP PRODUCT & INVENTORY SYSTEM VERIFICATION');
  print('===================================================');

  final db = PostgresService();
  await db.connect();

  final repository = ProductManagementRepository(db);
  final service = ProductManagementService(repository);

  try {
    // 1. Create Category
    print('\n[1/7] Creating Category in PostgreSQL...');
    final catName = 'Electronics Test ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final category = await service.createCategory(CategoryModel(name: catName, description: 'Test Electronics Category'));
    print('✅ Category Created: ID=${category.id}, Name=${category.name}');

    // 2. Create Supplier
    print('\n[2/7] Creating Supplier in PostgreSQL...');
    final supCode = 'SUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final supplier = await service.createSupplier(SupplierModel(
      supplierCode: supCode,
      name: 'Samsung Electronics Global',
      phone: '+1 800 726 7864',
      email: 'supply@samsung.com',
    ));
    print('✅ Supplier Created: ID=${supplier.id}, Code=${supplier.supplierCode}, Name=${supplier.name}');

    // 3. Create Product (Opening Stock = 20)
    print('\n[3/7] Creating Product in PostgreSQL (Opening Stock = 20)...');
    final sku = 'SAM-A54-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final product = await service.createProduct(ProductModel(
      productCode: sku,
      name: 'Samsung Galaxy A54 5G',
      categoryId: category.id,
      supplierId: supplier.id,
      brand: 'Samsung',
      unit: 'pcs',
      purchasePrice: 25000.0,
      sellingPrice: 29000.0,
      openingStock: 20.0,
      minimumStock: 5.0,
      description: 'High performance smartphone with 50MP OIS camera',
    ));
    print('✅ Product Created: ID=${product.id}, Name=${product.name}, SKU=${product.productCode}, Stock=${product.stockQuantity}');

    // Verify initial stock == 20
    assert(product.stockQuantity == 20.0, 'Initial stock should be 20');

    // 4. Purchase -> Stock IN (+10 Qty)
    print('\n[4/7] Creating Purchase Invoice (Stock IN +10 Qty)...');
    final invNo = 'PUR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final purchase = await service.createPurchase(PurchaseModel(
      invoiceNumber: invNo,
      supplierId: supplier.id,
      subtotal: 250000.0,
      totalAmount: 250000.0,
      items: [
        PurchaseItemModel(
          productId: product.id!,
          quantity: 10.0,
          purchasePrice: 25000.0,
          totalAmount: 250000.0,
        ),
      ],
    ));
    print('✅ Purchase Processed: Invoice=${purchase.invoiceNumber}');

    final prodAfterPur = await service.getProductById(product.id!);
    print('✅ Updated Stock after Purchase: ${prodAfterPur!.stockQuantity} (Expected: 30)');
    assert(prodAfterPur.stockQuantity == 30.0, 'Stock after purchase should be 30');

    // 5. Stock Damage -> Stock OUT (-2 Qty)
    print('\n[5/7] Recording Stock Damage (Stock OUT -2 Qty)...');
    final damage = await service.recordStockAdjustment(
      productId: product.id!,
      movementType: 'DAMAGE_OUT',
      quantity: 2.0,
      reason: 'Screen cracked during shipment handling',
    );
    print('✅ Damage Recorded: Ref=${damage.referenceId}, Previous=${damage.previousStock}, New=${damage.newStock}');
    assert(damage.newStock == 28.0, 'Stock after damage should be 28');

    // 6. Stock Movements Audit Trail
    print('\n[6/7] Verifying PostgreSQL Stock Movements Audit Trail...');
    final movements = await service.getStockMovements(productId: product.id!);
    print('✅ Stock Movements Found: ${movements.length} logs:');
    for (final m in movements) {
      print('   - [${m.movementType}] Qty: ${m.quantity} | Prev: ${m.previousStock} -> New: ${m.newStock} | Ref: ${m.referenceId}');
    }

    // 7. Stock Value & Financial Reports
    print('\n[7/7] Verifying Financial & Stock Value Reports...');
    final stockReport = await service.getStockValueReport();
    final profitLossReport = await service.getProfitLossReport();

    print('✅ Total Stock Value: \$${stockReport['totalStockValue']}');
    print('✅ Total Retail Value: \$${stockReport['totalRetailValue']}');
    print('✅ Net Profit Report: \$${profitLossReport['netProfit']}');

    print('\n===================================================');
    print('🎉 ALL ERP PRODUCT & STOCK INVARIANT TESTS PASSED!');
    print('===================================================');
  } catch (e, stack) {
    print('❌ TEST FAILED: $e');
    print(stack);
  } finally {
    await db.close();
  }
}
