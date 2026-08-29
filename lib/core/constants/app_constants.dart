class AppConstants {
  AppConstants._();

  // ==========================================
  // API URL CONFIGURATION
  // ==========================================
  // ⚠️ IMPORTANT — You can pass this at compile time:
  // flutter run --dart-define=API_BASE_URL=http://your-ip:5000
  //
  // Defaults:
  //  - Web / Desktop           -> http://localhost:5000
  //  - Android Emulator        -> http://10.0.2.2:5000
  //  - iOS Simulator           -> http://localhost:5000
  //  - Real device on same WiFi-> http://<your-pc-lan-ip>:5000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  // ==========================================
  // API ROUTES
  // ==========================================
  static const String branches = '$apiBaseUrl/api/admin/branches';
  static const String managers = '$apiBaseUrl/api/admin/managers';
  
  static const String auditLogs = '$apiBaseUrl/api/admin/audit-logs';
  static String employeeTimeline(int employeeDbId) => '$apiBaseUrl/api/admin/audit-logs/employee/$employeeDbId';

  static const String settings = '$apiBaseUrl/api/admin/settings';
  static const String settingsReset = '$apiBaseUrl/api/admin/settings/reset';

  static const String landingPage = '$apiBaseUrl/api/admin/landing-page';
  static const String landingPageReset = '$apiBaseUrl/api/admin/landing-page/reset';

  static const String salesReport = '$apiBaseUrl/api/admin/reports/sales';
  static const String reportCustomers = '$apiBaseUrl/api/admin/reports/customers';
  static const String purchaseReport = '$apiBaseUrl/api/admin/reports/purchases';
  static const String reportSuppliers = '$apiBaseUrl/api/admin/reports/suppliers';
  static const String inventoryReport = '$apiBaseUrl/api/admin/reports/inventory';
  static const String reportCategories = '$apiBaseUrl/api/admin/reports/categories';

  static const String loginRoute = '/api/auth/login';
  static const String logoutRoute = '/api/auth/logout';
  static const String meRoute = '/api/auth/me';
  static const String employeesRoute = '/api/employees';

  // Auth Headers
  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // ==========================================
  // ROLES & PERMISSIONS
  // ==========================================
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleCashier = 'cashier';
  static const String roleWarehouse = 'warehouse';
  static const String roleEmployee = 'employee';

  // ==========================================
  // ORDER STATUSES
  // ==========================================
  static const String orderStatusPending = 'pending';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCancelled = 'cancelled';
  static const String orderStatusRefunded = 'refunded';

  // ==========================================
  // PAGINATION DEFAULTS
  // ==========================================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
