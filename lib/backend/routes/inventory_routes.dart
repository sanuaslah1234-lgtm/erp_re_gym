import 'package:erp_software/backend/controllers/inventory_controller.dart';
import 'package:shelf_router/shelf_router.dart';

Router inventoryRoutes(
  InventoryController controller,
) {
  final router = Router();

  router.post(
    '/inventory',
    controller.createInventory,
  );

  router.get(
    '/inventory',
    controller.getInventory,
  );

  router.get(
    '/inventory/<id>',
    controller.getInventoryById,
  );

  router.put(
    '/inventory/<id>',
    controller.updateInventory,
  );

  router.delete(
    '/inventory/<id>',
    controller.deleteInventory,
  );

  router.patch(
    '/inventory/<id>/quantity',
    controller.updateQuantity,
  );

  return router;
}