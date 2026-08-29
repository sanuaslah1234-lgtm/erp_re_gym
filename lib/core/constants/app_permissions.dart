/// Application-wide RBAC Roles and Permissions Catalog
/// 
/// Namespace conventions:
/// - `erp.*` : Enterprise Resource Planning (Sales, Inventory, HR, Finance, Settings)
/// - `gym.*` : Gym & Fitness Management (Members, Plans, Attendance, Workouts, Schedules)
class AppRoles {
  static const String superAdmin = 'SUPER_ADMIN';
  static const String erpManager = 'ERP_MANAGER';
  static const String erpCashier = 'ERP_CASHIER';
  static const String inventoryManager = 'INVENTORY_MANAGER';
  static const String gymManager = 'GYM_MANAGER';
  static const String gymReceptionist = 'GYM_RECEPTIONIST';
  static const String gymTrainer = 'GYM_TRAINER';

  static const List<String> allRoles = [
    superAdmin,
    erpManager,
    erpCashier,
    inventoryManager,
    gymManager,
    gymReceptionist,
    gymTrainer,
  ];
}

class AppPermissions {
  // ===========================================================================
  // ERP Permissions (18 Total)
  // ===========================================================================
  static const String erpDashboardView = 'erp.dashboard.view';
  static const String erpUsersManage = 'erp.users.manage';
  static const String erpRolesManage = 'erp.roles.manage';
  static const String erpEmployeesManage = 'erp.employees.manage';
  static const String erpCustomersManage = 'erp.customers.manage';
  static const String erpSuppliersManage = 'erp.suppliers.manage';
  static const String erpProductsManage = 'erp.products.manage';
  static const String erpCategoriesManage = 'erp.categories.manage';
  static const String erpInventoryManage = 'erp.inventory.manage';
  static const String erpWarehouseManage = 'erp.warehouse.manage';
  static const String erpPurchaseManage = 'erp.purchase.manage';
  static const String erpSalesManage = 'erp.sales.manage';
  static const String erpPosManage = 'erp.pos.manage';
  static const String erpInvoicesManage = 'erp.invoices.manage';
  static const String erpPaymentsManage = 'erp.payments.manage';
  static const String erpReportsView = 'erp.reports.view';
  static const String erpAuditLogsView = 'erp.audit_logs.view';
  static const String erpSettingsManage = 'erp.settings.manage';

  // ===========================================================================
  // Gym Permissions (11 Total)
  // ===========================================================================
  static const String gymDashboardView = 'gym.dashboard.view';
  static const String gymMembersManage = 'gym.members.manage';
  static const String gymPlansManage = 'gym.plans.manage';
  static const String gymMembershipsManage = 'gym.memberships.manage';
  static const String gymTrainersManage = 'gym.trainers.manage';
  static const String gymAttendanceManage = 'gym.attendance.manage';
  static const String gymPaymentsManage = 'gym.payments.manage';
  static const String gymWorkoutsManage = 'gym.workouts.manage';
  static const String gymSchedulesManage = 'gym.schedules.manage';
  static const String gymReportsView = 'gym.reports.view';
  static const String gymSettingsManage = 'gym.settings.manage';

  /// All ERP permissions
  static const List<String> allErpPermissions = [
    erpDashboardView,
    erpUsersManage,
    erpRolesManage,
    erpEmployeesManage,
    erpCustomersManage,
    erpSuppliersManage,
    erpProductsManage,
    erpCategoriesManage,
    erpInventoryManage,
    erpWarehouseManage,
    erpPurchaseManage,
    erpSalesManage,
    erpPosManage,
    erpInvoicesManage,
    erpPaymentsManage,
    erpReportsView,
    erpAuditLogsView,
    erpSettingsManage,
  ];

  /// All Gym permissions
  static const List<String> allGymPermissions = [
    gymDashboardView,
    gymMembersManage,
    gymPlansManage,
    gymMembershipsManage,
    gymTrainersManage,
    gymAttendanceManage,
    gymPaymentsManage,
    gymWorkoutsManage,
    gymSchedulesManage,
    gymReportsView,
    gymSettingsManage,
  ];

  /// Union of all permissions (29 Total)
  static const List<String> allPermissions = [
    ...allErpPermissions,
    ...allGymPermissions,
  ];

  /// Canonical Role -> Permissions mapping definition
  static const Map<String, List<String>> rolePermissionsMap = {
    // 1. SUPER_ADMIN: Full access to all ERP + Gym permissions
    AppRoles.superAdmin: allPermissions,

    // 2. ERP_MANAGER: Full ERP permissions, no gym permissions
    AppRoles.erpManager: allErpPermissions,

    // 3. ERP_CASHIER: POS + Invoicing & Payments only
    AppRoles.erpCashier: [
      erpPosManage,
      erpPaymentsManage,
      erpInvoicesManage,
      erpSalesManage,
    ],

    // 4. INVENTORY_MANAGER: Stock, Warehouse, Products & Purchasing only
    AppRoles.inventoryManager: [
      erpInventoryManage,
      erpWarehouseManage,
      erpProductsManage,
      erpCategoriesManage,
      erpSuppliersManage,
      erpPurchaseManage,
    ],

    // 5. GYM_MANAGER: Full Gym permissions, no ERP access
    AppRoles.gymManager: allGymPermissions,

    // 6. GYM_RECEPTIONIST: Members, Memberships, Attendance & Payments (Gym side only)
    AppRoles.gymReceptionist: [
      gymDashboardView,
      gymMembersManage,
      gymMembershipsManage,
      gymAttendanceManage,
      gymPaymentsManage,
    ],

    // 7. GYM_TRAINER: Assigned Members, Workouts, Attendance & Schedules
    AppRoles.gymTrainer: [
      gymMembersManage,
      gymWorkoutsManage,
      gymAttendanceManage,
      gymSchedulesManage,
    ],
  };

  /// Returns effective permissions for a role name
  static List<String> getPermissionsForRole(String role) {
    final normalized = role.toUpperCase().trim();
    return rolePermissionsMap[normalized] ?? [];
  }
}
