import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/employee_provider.dart';
import 'package:erp_software/frontend/providers/cashier/pos_provider.dart';
import 'package:erp_software/frontend/providers/cashier/order_provider.dart';
import 'package:erp_software/frontend/providers/cashier/refund_provider.dart';
import 'package:erp_software/frontend/providers/cashier/barcode_provider.dart';
import 'package:erp_software/frontend/providers/cashier/cashier_settings_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/screens/auth/login_screen.dart';
import 'package:erp_software/frontend/screens/employee/employee_list_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<EmployeeProvider>(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider<PosProvider>(create: (_) => PosProvider()),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
        ChangeNotifierProvider<RefundProvider>(create: (_) => RefundProvider()),
        ChangeNotifierProvider<BarcodeProvider>(create: (_) => BarcodeProvider()),
        ChangeNotifierProvider<CashierSettingsProvider>(create: (_) => CashierSettingsProvider()),
        ChangeNotifierProvider<ProductManagementProvider>(create: (_) => ProductManagementProvider()),
      ],
      child: MaterialApp(
        title: 'ERP Software',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
            primary: const Color(0xFF2563EB),
            secondary: const Color(0xFF3B82F6),
            surface: const Color(0xFFF8FAFC),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C5CE7),
            brightness: Brightness.dark,
            primary: const Color(0xFFA29BFE),
            secondary: const Color(0xFF81ECEC),
            surface: const Color(0xFF1E1E2E),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
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
      return const EmployeeListScreen();
    } else {
      return const LoginScreen();
    }
  }
}
