import 'package:shelf_router/shelf_router.dart';

import '../controllers/warehouse_controller.dart';

Router warehouseRoutes(
  WarehouseController controller,
) {
  final router = Router();

  router.post(
    '/warehouses',
    controller.createWarehouse,
  );

  router.get(
    '/warehouses',
    controller.getWarehouses,
  );

  router.get(
    '/warehouses/<id>',
    controller.getWarehouseById,
  );

  router.put(
    '/warehouses/<id>',
    controller.updateWarehouse,
  );

  router.delete(
    '/warehouses/<id>',
    controller.deleteWarehouse,
  );

  return router;
}