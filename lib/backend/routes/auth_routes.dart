import 'package:erp_software/backend/controllers/auth_controller.dart';
import 'package:erp_software/backend/middleware/auth_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router setupAuthRoutes(AuthController authController) {
  final router = Router();

  // Public auth routes
  router.post('/login', authController.login);
  router.post('/employee-login', authController.login);
  router.post('/logout', authController.logout);
  router.post('/forgot-password', authController.forgotPassword);
  router.post('/verify-otp', authController.verifyOtp);
  router.post('/reset-password', authController.resetPassword);

  // Protected auth route
  final protectedPipeline = const Pipeline()
      .addMiddleware(authMiddleware())
      .addHandler((Request request) => authController.me(request));

  router.get('/me', protectedPipeline);

  return router;
}
