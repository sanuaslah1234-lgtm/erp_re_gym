import 'package:shelf_router/shelf_router.dart';
import 'package:erp_software/backend/controllers/product_management_controller.dart';

Router setupProductManagementRoutes(ProductManagementController controller) {
  final router = Router();

  // Products API
  router.get('/products', controller.getProducts);
  router.get('/products/<id>', controller.getProductById);
  router.post('/products', controller.createProduct);
  router.put('/products/<id>', controller.updateProduct);
  router.delete('/products/<id>', controller.deleteProduct);

  // Categories API
  router.get('/categories', controller.getCategories);
  router.post('/categories', controller.createCategory);
  router.put('/categories/<id>', controller.updateCategory);
  router.delete('/categories/<id>', controller.deleteCategory);

  // Brands API
  router.get('/brands', controller.getBrands);
  router.post('/brands', controller.createBrand);
  router.put('/brands/<id>', controller.updateBrand);
  router.delete('/brands/<id>', controller.deleteBrand);

  // Units API
  router.get('/units', controller.getUnits);
  router.post('/units', controller.createUnit);
  router.put('/units/<id>', controller.updateUnit);
  router.delete('/units/<id>', controller.deleteUnit);


  // Suppliers API
  router.get('/suppliers', controller.getSuppliers);
  router.post('/suppliers', controller.createSupplier);
  router.put('/suppliers/<id>', controller.updateSupplier);

  // Purchases API (Stock IN)
  router.get('/purchases', controller.getPurchases);
  router.post('/purchases', controller.createPurchase);

  // Stock Adjustments & History
  router.post('/stock/adjustment', controller.recordStockAdjustment);
  router.get('/stock/movements', controller.getStockMovements);

  // Reports API
  router.get('/reports/stock-value', controller.getStockValueReport);
  router.get('/reports/profit-loss', controller.getProfitLossReport);

  return router;
}
