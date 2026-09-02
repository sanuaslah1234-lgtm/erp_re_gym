class AppConstants {
  AppConstants._();

  static String _currentBaseUrl = '';

  /// Update the active Server Base URL in memory
  static void setBaseUrl(String url) {
    _currentBaseUrl = _normalizeUrl(url);
  }

  /// Reset to default
  static void resetBaseUrl() {
    _currentBaseUrl = '';
  }

  static String _normalizeUrl(String url) {
    var trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'http://$trimmed';
    }
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  // ==========================================
  // DYNAMIC API URL RESOLUTION (Pure Dart)
  // ==========================================
  static String get apiBaseUrl {
    if (_currentBaseUrl.isNotEmpty) {
      return _currentBaseUrl;
    }

    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return _normalizeUrl(envUrl);
    }

    // Default to the developer's PC LAN IP so mobile devices connect seamlessly
    return 'http://localhost:5000';
  }

  // ==========================================
  // API ROUTES (Dynamic Getters)
  // ==========================================
  static String get branches => '$apiBaseUrl/api/admin/branches';
  static String get managers => '$apiBaseUrl/api/admin/managers';
  
  static String get auditLogs => '$apiBaseUrl/api/admin/audit-logs';
  static String employeeTimeline(int employeeDbId) => '$apiBaseUrl/api/admin/audit-logs/employee/$employeeDbId';

  static String get settings => '$apiBaseUrl/api/admin/settings';
  static String get settingsReset => '$apiBaseUrl/api/admin/settings/reset';

  static String get landingPage => '$apiBaseUrl/api/admin/landing-page';
  static String get landingPageReset => '$apiBaseUrl/api/admin/landing-page/reset';

  static String get salesReport => '$apiBaseUrl/api/admin/reports/sales';
  static String get reportCustomers => '$apiBaseUrl/api/admin/reports/customers';
  static String get purchaseReport => '$apiBaseUrl/api/admin/reports/purchases';
  static String get reportSuppliers => '$apiBaseUrl/api/admin/reports/suppliers';
  static String get inventoryReport => '$apiBaseUrl/api/admin/reports/inventory';
  static String get reportCategories => '$apiBaseUrl/api/admin/reports/categories';

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
