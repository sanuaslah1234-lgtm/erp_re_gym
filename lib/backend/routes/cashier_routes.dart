import 'package:erp_software/backend/controllers/cashier/barcode_controller.dart';
import 'package:erp_software/backend/controllers/cashier/cashier_settings_controller.dart';
import 'package:erp_software/backend/controllers/cashier/order_controller.dart';
import 'package:erp_software/backend/controllers/cashier/pos_controller.dart';
import 'package:erp_software/backend/controllers/cashier/refund_controller.dart';
import 'package:erp_software/backend/middleware/auth_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router setupCashierRoutes({
  required PosController posController,
  required OrderController orderController,
  required RefundController refundController,
  required BarcodeController barcodeController,
  required CashierSettingsController settingsController,
}) {
  final router = Router();
  final pipeline = const Pipeline().addMiddleware(optionalAuthMiddleware());

  // 1. POS & Products
  router.get('/products', pipeline.addHandler((req) => posController.getProducts(req)));
  router.get('/products/search', pipeline.addHandler((req) => posController.getProducts(req)));
  router.get('/products/barcode/<barcode>', pipeline.addHandler((req) {
    final barcode = req.params['barcode'] ?? '';
    return posController.getProductByBarcode(req, barcode);
  }));
  router.get('/categories', pipeline.addHandler((req) => posController.getCategories(req)));
  router.get('/brands', pipeline.addHandler((req) => posController.getBrands(req)));

  // 2. Orders
  router.post('/orders', pipeline.addHandler((req) => orderController.createOrder(req)));
  router.get('/orders', pipeline.addHandler((req) => orderController.getOrders(req)));
  router.get('/orders/<id>', pipeline.addHandler((req) {
    final id = req.params['id'] ?? '';
    return orderController.getOrderById(req, id);
  }));
  router.post('/orders/<id>/cancel', pipeline.addHandler((req) {
    final id = req.params['id'] ?? '';
    return orderController.cancelOrder(req, id);
  }));

  // 3. Refunds
  router.post('/refunds', pipeline.addHandler((req) => refundController.createRefund(req)));
  router.get('/refunds', pipeline.addHandler((req) => refundController.getRefunds(req)));
  router.get('/refunds/<id>', pipeline.addHandler((req) {
    final id = req.params['id'] ?? '';
    return refundController.getRefundById(req, id);
  }));

  // 4. Barcodes
  router.post('/barcodes', pipeline.addHandler((req) => barcodeController.createBarcode(req)));
  router.get('/barcodes', pipeline.addHandler((req) => barcodeController.getBarcodes(req)));

  // 5. Settings
  router.get('/settings', pipeline.addHandler((req) => settingsController.getSettings(req)));
  router.put('/settings', pipeline.addHandler((req) => settingsController.updateSettings(req)));

  return router;
}
