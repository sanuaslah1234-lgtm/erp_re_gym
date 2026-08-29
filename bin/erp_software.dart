import 'dart:async';
import 'dart:io';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/backend/database/migration_runner.dart';
import 'package:erp_software/backend/server.dart';
import 'package:erp_software/core/config/app_config.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:erp_software/backend/controllers/auth_controller.dart';
import 'package:erp_software/backend/controllers/customer_controller.dart';
import 'package:erp_software/backend/controllers/employee_controller.dart';
import 'package:erp_software/backend/controllers/inventory_controller.dart';
import 'package:erp_software/backend/controllers/product_controller.dart';
import 'package:erp_software/backend/controllers/warehouse_controller.dart';

// Unused imports removed
import 'package:erp_software/backend/routes/app_router.dart';

import 'package:erp_software/backend/services/auth_service.dart';
import 'package:erp_software/backend/services/customer_service.dart';
import 'package:erp_software/backend/services/employee_service.dart';
import 'package:erp_software/backend/services/inventory_service.dart';
import 'package:erp_software/backend/services/product_service.dart';
import 'package:erp_software/backend/services/warehouse_service.dart';
import 'package:erp_software/backend/services/product_management_service.dart';

import 'package:erp_software/backend/controllers/product_management_controller.dart';
import 'package:erp_software/backend/repositories/product_management_repository.dart';
import 'package:erp_software/backend/repositories/auth_repository.dart';

// Admin Imports
import 'package:erp_software/backend/admin/audit_log/services/audit_log_service.dart';
import 'package:erp_software/backend/admin/branch/services/branch_service.dart';
import 'package:erp_software/backend/admin/landing_page/services/landing_page_service.dart';
import 'package:erp_software/backend/admin/manager/services/manager_service.dart';
import 'package:erp_software/backend/admin/reports/services/reports_service.dart';
import 'package:erp_software/backend/admin/settings/services/settings_service.dart';

import 'package:erp_software/backend/admin/audit_log/controllers/audit_log_controller.dart';
import 'package:erp_software/backend/admin/branch/controllers/branch_controller.dart';
import 'package:erp_software/backend/admin/landing_page/controllers/landing_page_controller.dart';
import 'package:erp_software/backend/admin/manager/controllers/manager_controller.dart';
import 'package:erp_software/backend/admin/reports/controllers/reports_controller.dart';
import 'package:erp_software/backend/admin/settings/controllers/settings_controller.dart';

import 'package:erp_software/backend/admin/audit_log/repositories/audit_log_repository.dart';
import 'package:erp_software/backend/admin/branch/repositories/branch_repository.dart';
import 'package:erp_software/backend/admin/landing_page/repositories/landing_page_repository.dart';
import 'package:erp_software/backend/admin/manager/repositories/manager_repository.dart';
import 'package:erp_software/backend/admin/reports/repositories/reports_repository.dart';
import 'package:erp_software/backend/admin/settings/repositories/settings_repository.dart';

import 'package:erp_software/backend/services/gym_service.dart';
import 'package:erp_software/backend/controllers/gym_controller.dart';

Future<void> main() async {
  print('Starting ERP Backend...');

  // Initialize DB Connection
  final postgresService = PostgresService();
  try {
    await postgresService.connect();
    
    // Run Migrations
    print('Checking migrations...');
    final migrationRunner = MigrationRunner(postgresService);
    await migrationRunner.runMigrations();
    
  } catch (e) {
    print('Startup failed: $e');
    print('Ensure PostgreSQL is running and .env is configured correctly.');
    exit(1);
  }

  // Initialize Repositories (Add others as needed)
  final authRepository = AuthRepository(postgresService);

  // Initialize Services
  final customerService = CustomerService(postgresService);
  final inventoryService = InventoryService(postgresService);
  final productService = ProductService(postgresService);
  final warehouseService = WarehouseService(postgresService);
  final employeeService = EmployeeService(postgresService);

  final authService = AuthService(
    authRepository: authRepository,
    employeeRepository: employeeService,
  );

  // Initialize Admin Repositories
  final auditLogRepository = AuditLogRepository(postgresService.connection);
  final branchRepository = BranchRepository(postgresService.connection);
  final landingPageRepository = LandingPageRepository(postgresService.connection);
  final managerRepository = ManagerRepository(postgresService.connection);
  final reportsRepository = ReportsRepository(postgresService.connection);
  final settingsRepository = SettingsRepository(postgresService.connection);

  // Initialize Admin Services
  final auditLogService = AuditLogService(auditLogRepository);
  final branchService = BranchService(branchRepository);
  final landingPageService = LandingPageService(landingPageRepository);
  final managerService = ManagerService(managerRepository);
  final reportsService = ReportsService(reportsRepository);
  final settingsService = SettingsService(settingsRepository);

  // Initialize Controllers
  final authController = AuthController(authService);
  final customerController = CustomerController(customerService);
  final inventoryController = InventoryController(inventoryService);
  final productController = ProductController(productService);
  final warehouseController = WarehouseController(warehouseService);
  final employeeController = EmployeeController(employeeService);

  // Initialize Admin Controllers
  final auditLogController = AuditLogController(auditLogService);
  final branchController = BranchController(branchService);
  final landingPageController = LandingPageController(landingPageService);
  final managerController = ManagerController(managerService);
  final reportsController = ReportsController(reportsService);
  final settingsController = SettingsController(settingsService);

  final productManagementRepository = ProductManagementRepository(postgresService);
  final productManagementService = ProductManagementService(productManagementRepository);
  final productManagementController = ProductManagementController(productManagementService);

  // Initialize Gym Service & Controller
  final gymService = GymService(postgresService);
  final gymController = GymController(gymService);

  // Setup App Router
  final appRouter = AppRouter(
    authController: authController,
    customerController: customerController,
    employeeController: employeeController,
    inventoryController: inventoryController,
    productController: productController,
    warehouseController: warehouseController,
    productManagementController: productManagementController,
    gymController: gymController,
    auditLogController: auditLogController,
    branchController: branchController,
    landingPageController: landingPageController,
    managerController: managerController,
    reportsController: reportsController,
    settingsController: settingsController,
  );

  // Setup Server
  final server = BackendServer(postgresService);
  server.setupRoutes(appRouter);

  // Start Server
  final port = AppConfig.apiPort;
  await _freePortIfHeld(port);
  final shelfServer = await shelf_io.serve(server.handler, '0.0.0.0', port);
  print('✅ ERP Backend running securely on http://localhost:${shelfServer.port}');

  // Keep server alive indefinitely
  Timer.periodic(const Duration(hours: 24), (_) {});
  final completer = Completer<void>();
  try {
    if (!Platform.isWindows) {
      ProcessSignal.sigint.watch().listen((_) {
        print('Shutting down server...');
        shelfServer.close(force: true);
        if (!completer.isCompleted) completer.complete();
      });
      ProcessSignal.sigterm.watch().listen((_) {
        print('Shutting down server...');
        shelfServer.close(force: true);
        if (!completer.isCompleted) completer.complete();
      });
    }
  } catch (_) {}
  await completer.future;
}

Future<void> _freePortIfHeld(int port) async {
  try {
    if (Platform.isWindows) {
      final result = await Process.run('netstat', ['-ano']);
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        if (line.contains(':$port') && line.contains('LISTENING')) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.isNotEmpty) {
            final pidStr = parts.last;
            final processId = int.tryParse(pidStr);
            if (processId != null && processId > 0 && processId != pid) {
              stdout.writeln('Port $port is currently held by a stale process (PID $pidStr). Automatically freeing port $port...');
              await Process.run('taskkill', ['/F', '/PID', pidStr]);
              await Future.delayed(const Duration(milliseconds: 600));
            }
          }
        }
      }
    }
  } catch (_) {}
}
