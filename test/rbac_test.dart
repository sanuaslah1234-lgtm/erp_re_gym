import 'package:flutter_test/flutter_test.dart';
import 'package:erp_software/core/constants/app_permissions.dart';
import 'package:erp_software/core/models/user_model.dart';
import 'package:erp_software/backend/services/jwt_service.dart';
import 'package:erp_software/backend/middleware/auth_middleware.dart';

void main() {
  group('Unified RBAC - Role & Permission Matrix Tests', () {
    test('Total permission count and namespace isolation', () {
      expect(AppPermissions.allErpPermissions.length, 18);
      expect(AppPermissions.allGymPermissions.length, 11);
      expect(AppPermissions.allPermissions.length, 29);

      for (final p in AppPermissions.allErpPermissions) {
        expect(p.startsWith('erp.'), true, reason: '$p should have erp. prefix');
      }

      for (final p in AppPermissions.allGymPermissions) {
        expect(p.startsWith('gym.'), true, reason: '$p should have gym. prefix');
      }
    });

    test('SUPER_ADMIN has all 29 permissions across ERP and Gym', () {
      final perms = AppPermissions.getPermissionsForRole(AppRoles.superAdmin);
      expect(perms.length, 29);
      expect(perms.contains(AppPermissions.erpDashboardView), true);
      expect(perms.contains(AppPermissions.gymDashboardView), true);
      expect(perms.contains(AppPermissions.gymMembersManage), true);
      expect(perms.contains(AppPermissions.erpPosManage), true);

      final user = UserModel(
        email: 'admin@erp.com',
        role: AppRoles.superAdmin,
      );

      expect(user.isSuperAdmin, true);
      expect(user.can(AppPermissions.erpInventoryManage), true);
      expect(user.can(AppPermissions.gymWorkoutsManage), true);
      expect(user.canAccessErp, true);
      expect(user.canAccessGym, true);
    });

    test('ERP_MANAGER has full ERP access and no Gym permissions', () {
      final perms = AppPermissions.getPermissionsForRole(AppRoles.erpManager);
      expect(perms.length, 18);
      expect(perms.contains(AppPermissions.erpDashboardView), true);
      expect(perms.contains(AppPermissions.erpEmployeesManage), true);
      expect(perms.contains(AppPermissions.erpSalesManage), true);
      expect(perms.contains(AppPermissions.gymDashboardView), false);
      expect(perms.contains(AppPermissions.gymMembersManage), false);

      final user = UserModel(
        email: 'erp_mgr@erp.com',
        role: AppRoles.erpManager,
        permissions: perms,
      );

      expect(user.isSuperAdmin, false);
      expect(user.can(AppPermissions.erpUsersManage), true);
      expect(user.can(AppPermissions.gymPlansManage), false);
      expect(user.canAccessErp, true);
      expect(user.canAccessGym, false);
    });

    test('ERP_CASHIER has POS and Payments only', () {
      final perms = AppPermissions.getPermissionsForRole(AppRoles.erpCashier);
      expect(perms.contains(AppPermissions.erpPosManage), true);
      expect(perms.contains(AppPermissions.erpPaymentsManage), true);
      expect(perms.contains(AppPermissions.erpInvoicesManage), true);
      expect(perms.contains(AppPermissions.erpEmployeesManage), false);
      expect(perms.contains(AppPermissions.erpSettingsManage), false);
      expect(perms.contains(AppPermissions.gymMembersManage), false);

      final user = UserModel(
        email: 'cashier@erp.com',
        role: AppRoles.erpCashier,
        permissions: perms,
      );

      expect(user.can(AppPermissions.erpPosManage), true);
      expect(user.can(AppPermissions.erpInventoryManage), false);
      expect(user.can(AppPermissions.gymPaymentsManage), false);
    });

    test('INVENTORY_MANAGER has stock/products/warehouse/purchasing only', () {
      final perms = AppPermissions.getPermissionsForRole(AppRoles.inventoryManager);
      expect(perms.contains(AppPermissions.erpInventoryManage), true);
      expect(perms.contains(AppPermissions.erpWarehouseManage), true);
      expect(perms.contains(AppPermissions.erpProductsManage), true);
      expect(perms.contains(AppPermissions.erpCategoriesManage), true);
      expect(perms.contains(AppPermissions.erpSuppliersManage), true);
      expect(perms.contains(AppPermissions.erpPurchaseManage), true);
      expect(perms.contains(AppPermissions.erpPosManage), false);
      expect(perms.contains(AppPermissions.erpEmployeesManage), false);
      expect(perms.contains(AppPermissions.gymMembersManage), false);

      final user = UserModel(
        email: 'inventory@erp.com',
        role: AppRoles.inventoryManager,
        permissions: perms,
      );

      expect(user.can(AppPermissions.erpWarehouseManage), true);
      expect(user.can(AppPermissions.erpSalesManage), false);
      expect(user.can(AppPermissions.gymDashboardView), false);
    });

    test('GYM_MANAGER has full Gym access and no ERP access', () {
      final perms = AppPermissions.getPermissionsForRole(AppRoles.gymManager);
      expect(perms.length, 11);
      expect(perms.contains(AppPermissions.gymDashboardView), true);
      expect(perms.contains(AppPermissions.gymMembersManage), true);
      expect(perms.contains(AppPermissions.gymTrainersManage), true);
      expect(perms.contains(AppPermissions.gymWorkoutsManage), true);
      expect(perms.contains(AppPermissions.erpDashboardView), false);
      expect(perms.contains(AppPermissions.erpInventoryManage), false);

      final user = UserModel(
        email: 'gym_mgr@erp.com',
        role: AppRoles.gymManager,
        permissions: perms,
      );

      expect(user.can(AppPermissions.gymTrainersManage), true);
      expect(user.can(AppPermissions.erpPosManage), false);
      expect(user.canAccessGym, true);
      expect(user.canAccessErp, false);
    });

    test('GYM_RECEPTIONIST has front-desk operations but cannot manage trainers or ERP inventory', () {
      final perms = AppPermissions.getPermissionsForRole(AppRoles.gymReceptionist);
      expect(perms.contains(AppPermissions.gymDashboardView), true);
      expect(perms.contains(AppPermissions.gymMembersManage), true);
      expect(perms.contains(AppPermissions.gymMembershipsManage), true);
      expect(perms.contains(AppPermissions.gymAttendanceManage), true);
      expect(perms.contains(AppPermissions.gymPaymentsManage), true);

      // Denied actions
      expect(perms.contains(AppPermissions.gymTrainersManage), false);
      expect(perms.contains(AppPermissions.gymSettingsManage), false);
      expect(perms.contains(AppPermissions.erpInventoryManage), false);
      expect(perms.contains(AppPermissions.erpPosManage), false);

      final user = UserModel(
        email: 'receptionist@erp.com',
        role: AppRoles.gymReceptionist,
        permissions: perms,
      );

      expect(user.can(AppPermissions.gymMembersManage), true);
      expect(user.can(AppPermissions.gymAttendanceManage), true);
      expect(user.can(AppPermissions.gymTrainersManage), false);
      expect(user.can(AppPermissions.erpProductsManage), false);
    });

    test('GYM_TRAINER has assigned workouts/attendance/schedules only, denied ERP routes', () {
      final perms = AppPermissions.getPermissionsForRole(AppRoles.gymTrainer);
      expect(perms.contains(AppPermissions.gymMembersManage), true);
      expect(perms.contains(AppPermissions.gymWorkoutsManage), true);
      expect(perms.contains(AppPermissions.gymAttendanceManage), true);
      expect(perms.contains(AppPermissions.gymSchedulesManage), true);

      // Denied actions
      expect(perms.contains(AppPermissions.gymPlansManage), false);
      expect(perms.contains(AppPermissions.gymTrainersManage), false);
      expect(perms.contains(AppPermissions.gymPaymentsManage), false);
      expect(perms.contains(AppPermissions.gymReportsView), false);
      expect(perms.contains(AppPermissions.erpDashboardView), false);
      expect(perms.contains(AppPermissions.erpEmployeesManage), false);

      final user = UserModel(
        email: 'trainer@erp.com',
        role: AppRoles.gymTrainer,
        permissions: perms,
      );

      expect(user.can(AppPermissions.gymWorkoutsManage), true);
      expect(user.can(AppPermissions.gymPaymentsManage), false);
      expect(user.can(AppPermissions.erpPosManage), false);
    });

    test('JwtPayload and auth middleware helper functions', () {
      final payload = JwtPayload(
        userId: 42,
        email: 'trainer@erp.com',
        role: AppRoles.gymTrainer,
        permissions: AppPermissions.getPermissionsForRole(AppRoles.gymTrainer),
      );

      expect(can(payload, AppPermissions.gymWorkoutsManage), true);
      expect(can(payload, AppPermissions.erpUsersManage), false);

      final superAdminPayload = JwtPayload(
        userId: 1,
        email: 'admin@erp.com',
        role: AppRoles.superAdmin,
        permissions: AppPermissions.allPermissions,
      );

      expect(can(superAdminPayload, AppPermissions.erpUsersManage), true);
      expect(can(superAdminPayload, AppPermissions.gymSettingsManage), true);
      expect(can(superAdminPayload, 'any.custom.permission'), true);
    });

    test('UserModel JSON serialization preserves roleId and permissions', () {
      final user = UserModel(
        id: 10,
        email: 'cashier@erp.com',
        roleId: 3,
        role: AppRoles.erpCashier,
        permissions: [AppPermissions.erpPosManage, AppPermissions.erpPaymentsManage],
      );

      final json = user.toJson();
      expect(json['email'], 'cashier@erp.com');
      expect(json['role_id'], 3);
      expect(json['role'], AppRoles.erpCashier);
      expect((json['permissions'] as List).length, 2);

      final reconstructed = UserModel.fromJson(json);
      expect(reconstructed.roleId, 3);
      expect(reconstructed.role, AppRoles.erpCashier);
      expect(reconstructed.can(AppPermissions.erpPosManage), true);
      expect(reconstructed.can(AppPermissions.erpInventoryManage), false);
    });
  });
}
