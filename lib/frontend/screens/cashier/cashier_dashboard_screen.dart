import 'package:flutter/material.dart';
import 'package:erp_software/frontend/screens/cashier/pos/pos_screen.dart';
import 'package:erp_software/frontend/screens/cashier/orders/pos_orders_screen.dart';
import 'package:erp_software/frontend/screens/cashier/barcode/barcode_print_screen.dart';
import 'package:erp_software/frontend/screens/cashier/refunds/refunds_screen.dart';
import 'package:erp_software/frontend/screens/cashier/settings/cashier_settings_screen.dart';

class CashierDashboardScreen extends StatefulWidget {
  final String initialTab;

  const CashierDashboardScreen({super.key, this.initialTab = 'POS Terminal'});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant CashierDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _activeTab = widget.initialTab;
      });
    }
  }

  Widget _buildActiveTabScreen() {
    switch (_activeTab) {
      case 'POS':
      case 'POS Terminal':
        return const PosScreen();
      case 'POS Orders':
      case 'Sales Orders':
        return const PosOrdersScreen();
      case 'Barcode Print':
      case 'Barcode Printing':
        return const BarcodePrintScreen();
      case 'Refunds':
        return const RefundsScreen();
      case 'Settings':
        return const CashierSettingsScreen();
      default:
        return const PosScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildActiveTabScreen();
  }
}
