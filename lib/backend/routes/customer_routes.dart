import 'package:shelf_router/shelf_router.dart';

import '../controllers/customer_controller.dart';

Router customerRoutes(CustomerController controller) {
  final router = Router();

  router.post(
    '/customers',
    controller.createCustomer,
  );

  router.get(
    '/customers',
    controller.getCustomers,
  );

  router.get(
    '/customers/<id>',
    controller.getCustomerById,
  );

  router.put(
    '/customers/<id>',
    controller.updateCustomer,
  );

  router.delete(
    '/customers/<id>',
    controller.deleteCustomer,
  );

  return router;
}