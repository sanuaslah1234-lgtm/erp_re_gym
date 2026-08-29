import 'package:shelf_router/shelf_router.dart';

import '../controllers/product_controller.dart';

Router productRoutes(
  ProductController controller,
) {
  final router = Router();

  router.post(
    '/products',
    controller.createProduct,
  );

  router.get(
    '/products',
    controller.getProducts,
  );

  router.get(
    '/products/<id>',
    controller.getProductById,
  );

  router.put(
    '/products/<id>',
    controller.updateProduct,
  );

  router.delete(
    '/products/<id>',
    controller.deleteProduct,
  );

  return router;
}