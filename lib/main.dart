import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'frontend/admin/audit_log/providers/audit_log_provider.dart';
import 'frontend/admin/landing_page/providers/landing_page_provider.dart';
import 'frontend/admin/branch/providers/branch_provider.dart';
import 'frontend/admin/manager/providers/manager_provider.dart';
import 'frontend/admin/reports/providers/inventory_reports_provider.dart';
import 'frontend/admin/reports/providers/purchase_reports_provider.dart';
import 'frontend/admin/reports/providers/reports_provider.dart';
import 'frontend/admin/settings/providers/settings_provider.dart';
import 'frontend/providers/auth_provider.dart';
import 'frontend/providers/cashier/barcode_provider.dart';
import 'frontend/providers/cashier/cashier_settings_provider.dart';
import 'frontend/providers/cashier/order_provider.dart';
import 'frontend/providers/cashier/pos_provider.dart';
import 'frontend/providers/cashier/refund_provider.dart';
import 'frontend/providers/employee_provider.dart';
import 'frontend/providers/product_management_provider.dart';
import 'frontend/screens/auth/login_screen.dart';
import 'frontend/widgets/common/mobile_nav_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('custom_api_base_url');
    if (savedUrl != null && savedUrl.trim().isNotEmpty) {
      AppConstants.setBaseUrl(savedUrl);
    }
  } catch (_) {}
  runApp(const ErpApp());
}

class ErpApp extends StatelessWidget {
  const ErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ProductManagementProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => BarcodeProvider()),
        ChangeNotifierProvider(create: (_) => RefundProvider()),
        ChangeNotifierProvider(create: (_) => CashierSettingsProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseReportsProvider()),
        ChangeNotifierProvider(create: (_) => InventoryReportsProvider()),
        ChangeNotifierProvider(create: (_) => ManagerProvider()),
        ChangeNotifierProvider(create: (_) => AuditLogProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LandingPageProvider()),
      ],
      child: MaterialApp(
        title: 'Retail ERP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapperScreen(),
      ),
    );
  }
}

class AuthWrapperScreen extends StatelessWidget {
  const AuthWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const MobileNavShell();
    } else {
      return const LoginScreen();
    }
  }
}
