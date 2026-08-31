import 'dart:convert';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:postgres/postgres.dart';
import '../utils/response_utils.dart';
import '../database/postgres_service.dart';

import '../controllers/auth_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/employee_controller.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/warehouse_controller.dart';

import '../admin/audit_log/controllers/audit_log_controller.dart';
import '../admin/branch/controllers/branch_controller.dart';
import '../admin/landing_page/controllers/landing_page_controller.dart';
import '../admin/manager/controllers/manager_controller.dart';
import '../admin/reports/controllers/reports_controller.dart';
import '../admin/settings/controllers/settings_controller.dart';

import 'admin_routes.dart';
import 'auth_routes.dart';
import 'customer_routes.dart';
import 'employee_routes.dart';
import 'inventory_routes.dart';
import 'product_routes.dart';
import 'warehouse_routes.dart';

import '../controllers/product_management_controller.dart';
import 'product_management_routes.dart';
import '../controllers/gym_controller.dart';
import 'gym_routes.dart';

class AppRouter {
  final AuthController authController;
  final CustomerController customerController;
  final EmployeeController employeeController;
  final InventoryController inventoryController;
  final ProductController productController;
  final WarehouseController warehouseController;
  final ProductManagementController? productManagementController;
  final GymController? gymController;
  
  final AuditLogController auditLogController;
  final BranchController branchController;
  final LandingPageController landingPageController;
  final ManagerController managerController;
  final ReportsController reportsController;
  final SettingsController settingsController;
  final PostgresService? postgresService;

  AppRouter({
    required this.authController,
    required this.customerController,
    required this.employeeController,
    required this.inventoryController,
    required this.productController,
    required this.warehouseController,
    this.productManagementController,
    this.gymController,
    required this.auditLogController,
    required this.branchController,
    required this.landingPageController,
    required this.managerController,
    required this.reportsController,
    required this.settingsController,
    this.postgresService,
  });

  Router get router {
    final router = Router();

    // Health Check
    router.get('/health', (Request request) {
      return ResponseUtils.success(
        message: 'ERP API is running',
        data: {'database': 'connected'},
      );
    });

    // Feature Routes (Specific Path Mounts First)
    router.mount('/auth', setupAuthRoutes(authController).call);
    
    // Admin Routes mounted at /api/admin
    router.mount('/admin', adminRoutes(
      auditLogController: auditLogController,
      branchController: branchController,
      landingPageController: landingPageController,
      managerController: managerController,
      reportsController: reportsController,
      settingsController: settingsController,
    ).call);

    // Gym Routes mounted at /api/gym
    if (gymController != null) {
      router.mount('/gym', gymRoutes(gymController!).call);
    }

    // Root-prefixed feature routes
    if (productManagementController != null) {
      router.mount('/', setupProductManagementRoutes(productManagementController!).call);
    } else {
      router.mount('/', productRoutes(productController).call);
    }
    router.mount('/', customerRoutes(customerController).call);
    router.mount('/', inventoryRoutes(inventoryController).call);
    router.mount('/', warehouseRoutes(warehouseController).call);
    router.mount('/', employeeRoutes(employeeController).call);

    // Roles & Designations
    router.get('/roles', (Request request) async {
      if (postgresService == null) return ResponseUtils.error(message: 'Database not available');
      try {
        final result = await postgresService!.connection.execute(Sql.named('SELECT id, name, description FROM roles ORDER BY name ASC'));
        final roles = result.map((r) {
          final m = r.toColumnMap();
          return {'id': m['id'].toString(), 'name': m['name']?.toString() ?? '', 'description': m['description']?.toString() ?? ''};
        }).toList();
        return ResponseUtils.success(message: 'Roles retrieved', data: roles);
      } catch (e) {
        return ResponseUtils.error(message: 'Failed to fetch roles', error: e.toString());
      }
    });

    // Expenses & Accounts (payments as expenses)
    router.get('/expenses', (Request request) async {
      if (postgresService == null) return ResponseUtils.error(message: 'Database not available');
      try {
        final result = await postgresService!.connection.execute(Sql.named(
          '''SELECT p.id, p.payment_method, p.amount, p.reference_number, p.created_at,
                  o.order_number
           FROM payments p
           LEFT JOIN pos_orders o ON o.id = p.order_id
           ORDER BY p.created_at DESC'''
        ));
        final expenses = result.map((r) {
          final m = r.toColumnMap();
          return {
            'id': m['id'].toString(),
            'payment_method': m['payment_method']?.toString() ?? 'cash',
            'amount': m['amount'],
            'reference_number': m['reference_number']?.toString(),
            'order_number': m['order_number']?.toString(),
            'created_at': m['created_at']?.toString(),
          };
        }).toList();
        return ResponseUtils.success(message: 'Expenses retrieved', data: expenses);
      } catch (e) {
        return ResponseUtils.error(message: 'Failed to fetch expenses', error: e.toString());
      }
    });

    // Fallback route handler (will catch unmatched /api/* requests)
    router.all('/<ignored|.*>', (Request request) {
      return ResponseUtils.notFound(message: 'API Route not found: /api/${request.params['ignored']}');
    });

    return router;
  }
}
