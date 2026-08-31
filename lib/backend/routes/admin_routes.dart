import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:erp_software/core/constants/app_permissions.dart';
import 'package:erp_software/backend/middleware/auth_middleware.dart';

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

  dynamic guard(String perm, Function handler) {
    final mw = requirePermission(perm);
    if (handler is Future<Response> Function(Request, String, String)) {
      return (Request request, String p1, String p2) {
        return mw((Request req) => handler(req, p1, p2))(request);
      };
    } else if (handler is Future<Response> Function(Request, String)) {
      return (Request request, String p1) {
        return mw((Request req) => handler(req, p1))(request);
      };
    } else if (handler is Future<Response> Function(Request)) {
      return (Request request) {
        return mw(handler)(request);
      };
    }

    return (Request request, [String? p1, String? p2]) {
      return mw((Request req) async {
        if (p2 != null) {
          return await (handler as dynamic)(req, p1, p2);
        } else if (p1 != null) {
          return await (handler as dynamic)(req, p1);
        } else {
          final params = req.params;
          if (params.length >= 2) {
            final vals = params.values.toList();
            return await (handler as dynamic)(req, vals[0], vals[1]);
          } else if (params.length == 1) {
            return await (handler as dynamic)(req, params.values.first);
          }
          return await (handler as dynamic)(req);
        }
      })(request);
    };
  }

  // Audit Logs (erp.audit_logs.view)
  router.get('/audit-logs', guard(AppPermissions.erpAuditLogsView, auditLogController.getLogs));

  // Branches (erp.settings.manage)
  router.post('/branches', guard(AppPermissions.erpSettingsManage, branchController.createBranch));
  router.get('/branches', guard(AppPermissions.erpSettingsManage, branchController.getBranches));
  router.get('/branches/<id>', guard(AppPermissions.erpSettingsManage, branchController.getBranchById));
  router.put('/branches/<id>', guard(AppPermissions.erpSettingsManage, branchController.updateBranch));
  router.delete('/branches/<id>', guard(AppPermissions.erpSettingsManage, branchController.deleteBranch));

  // Landing Page (erp.settings.manage)
  router.get('/landing-page', guard(AppPermissions.erpSettingsManage, landingPageController.getSettings));
  router.put('/landing-page', guard(AppPermissions.erpSettingsManage, landingPageController.updateSettings));

  // Managers (erp.employees.manage)
  router.post('/managers', guard(AppPermissions.erpEmployeesManage, managerController.createManager));
  router.get('/managers', guard(AppPermissions.erpEmployeesManage, managerController.getManagers));
  router.get('/managers/<id>', guard(AppPermissions.erpEmployeesManage, managerController.getManagerById));
  router.put('/managers/<id>', guard(AppPermissions.erpEmployeesManage, managerController.updateManager));
  router.delete('/managers/<id>', guard(AppPermissions.erpEmployeesManage, managerController.deleteManager));

  // Reports (erp.reports.view)
  router.get('/reports/sales', guard(AppPermissions.erpReportsView, reportsController.getSalesReport));
  router.get('/reports/inventory', guard(AppPermissions.erpReportsView, reportsController.getInventoryReport));

  // Settings (erp.settings.manage)
  router.get('/settings', guard(AppPermissions.erpSettingsManage, settingsController.getSettings));
  router.put('/settings', guard(AppPermissions.erpSettingsManage, settingsController.updateSettings));

  return router;
}
