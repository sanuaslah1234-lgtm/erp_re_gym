import 'package:shelf_router/shelf_router.dart';

import '../admin/audit_log/controllers/audit_log_controller.dart';
import '../admin/branch/controllers/branch_controller.dart';
import '../admin/landing_page/controllers/landing_page_controller.dart';
import '../admin/manager/controllers/manager_controller.dart';
import '../admin/reports/controllers/reports_controller.dart';
import '../admin/settings/controllers/settings_controller.dart';

Router adminRoutes({
  required AuditLogController auditLogController,
  required BranchController branchController,
  required LandingPageController landingPageController,
  required ManagerController managerController,
  required ReportsController reportsController,
  required SettingsController settingsController,
}) {
  final router = Router();

  // Audit Logs
  router.get('/audit-logs', auditLogController.getLogs);

  // Branches
  router.post('/branches', branchController.createBranch);
  router.get('/branches', branchController.getBranches);
  router.put('/branches/<id>', branchController.updateBranch);
  router.delete('/branches/<id>', branchController.deleteBranch);

  // Landing Page
  router.get('/landing-page', landingPageController.getSettings);
  router.put('/landing-page', landingPageController.updateSettings);

  // Managers
  router.post('/managers', managerController.createManager);
  router.get('/managers', managerController.getManagers);
  router.get('/managers/<id>', managerController.getManagerById);
  router.put('/managers/<id>', managerController.updateManager);
  router.delete('/managers/<id>', managerController.deleteManager);

  // Reports
  router.get('/reports/sales', reportsController.getSalesReport);
  router.get('/reports/inventory', reportsController.getInventoryReport);

  // Settings
  router.get('/settings', settingsController.getSettings);
  router.put('/settings', settingsController.updateSettings);

  return router;
}
