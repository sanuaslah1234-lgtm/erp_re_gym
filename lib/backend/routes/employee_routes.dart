import 'package:shelf_router/shelf_router.dart';

import '../controllers/employee_controller.dart';

Router employeeRoutes(
  EmployeeController controller,
) {
  final router = Router();

  router.get(
    '/employees',
    controller.getEmployees,
  );

  router.get(
    '/employees/<id>',
    controller.getEmployee,
  );

  router.post(
    '/employees',
    controller.createEmployee,
  );

  router.put(
    '/employees/<id>',
    controller.updateEmployee,
  );

  router.delete(
    '/employees/<id>',
    controller.deleteEmployee,
  );

  return router;
}
