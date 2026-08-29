import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/core/models/brand_model.dart';
import 'package:erp_software/backend/repositories/product_management_repository.dart';
import 'package:erp_software/backend/services/product_management_service.dart';

Future<void> main() async {
  print('===================================================');
  print('[TEST] POSTGRESQL BRANDS MODULE VERIFICATION');
  print('===================================================');

  final db = PostgresService();
  try {
    await db.connect();
    print('✅ PostgreSQL Database connected successfully.');

    final repository = ProductManagementRepository(db);
    final service = ProductManagementService(repository);

    // 1. Create Brand
    print('\n[1/4] Testing CREATE Brand in PostgreSQL database...');
    final testBrandName = 'Apple Inc ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final createdBrand = await service.createBrand(
      BrandModel(
        name: testBrandName,
        description: 'Premium Consumer Electronics and Software',
        status: 'active',
      ),
    );
    print('✅ Brand Created in DB -> ID: ${createdBrand.id}, Name: "${createdBrand.name}", Status: "${createdBrand.status}"');

    // 2. Update Brand
    print('\n[2/4] Testing UPDATE Brand in PostgreSQL database...');
    final updatedBrand = await service.updateBrand(
      createdBrand.id!,
      BrandModel(
        id: createdBrand.id,
        name: '$testBrandName Updated',
        description: 'Innovative hardware & ecosystem products',
        status: 'active',
      ),
    );
    print('✅ Brand Updated in DB -> ID: ${updatedBrand.id}, New Name: "${updatedBrand.name}", Desc: "${updatedBrand.description}"');

    // 3. Fetch All Brands
    print('\n[3/4] Testing FETCH ALL Brands from PostgreSQL database...');
    final allBrands = await service.getBrands();
    print('✅ Retrieved ${allBrands.length} brand(s) from PostgreSQL database:');
    for (final b in allBrands) {
      print('   - ID: ${b.id} | Name: ${b.name} | Status: ${b.status} | Product Count: ${b.productCount}');
    }

    // 4. Delete Brand
    print('\n[4/4] Testing DELETE Brand from PostgreSQL database...');
    await service.deleteBrand(createdBrand.id!);
    print('✅ Brand ID ${createdBrand.id} successfully deleted from PostgreSQL database.');

    print('\n===================================================');
    print('🎉 ALL POSTGRESQL BRAND TESTS PASSED SUCCESSFULLY!');
    print('===================================================');
  } catch (e, stack) {
    print('❌ Error during PostgreSQL brand verification: $e');
    print(stack);
  }
}
