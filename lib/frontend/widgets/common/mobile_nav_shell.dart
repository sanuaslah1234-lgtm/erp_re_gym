import 'package:flutter/material.dart';
import 'package:erp_software/core/constants/app_permissions.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/screens/cashier/pos/pos_screen.dart';
import 'package:erp_software/frontend/screens/cashier/barcode/barcode_print_screen.dart';
import 'package:erp_software/frontend/screens/cashier/settings/cashier_settings_screen.dart';
import 'package:erp_software/frontend/screens/cashier/orders/pos_orders_screen.dart';
import 'package:erp_software/frontend/screens/customers/customers_screen.dart';
import 'package:erp_software/frontend/screens/employees/employee_screen.dart';
import 'package:erp_software/frontend/screens/products/brands_screen.dart';
import 'package:erp_software/frontend/screens/products/categories_screen.dart';
import 'package:erp_software/frontend/screens/inventory/inventory_screen.dart';
import 'package:erp_software/frontend/screens/warehouse/warehouse_screen.dart';
import 'package:erp_software/frontend/screens/products/product_management_screen.dart';
import 'package:erp_software/frontend/screens/products/suppliers_screen.dart';
import 'package:erp_software/frontend/screens/products/purchases_screen.dart';
import 'package:erp_software/frontend/screens/invoices/invoices_screen.dart';
import 'package:erp_software/frontend/screens/admin/store_branches_screen.dart';
import 'package:erp_software/frontend/screens/settings/designations_roles_screen.dart';
import 'package:erp_software/frontend/screens/settings/expenses_accounts_screen.dart';
import 'package:erp_software/frontend/screens/products/units_screen.dart';
import 'package:erp_software/frontend/screens/reports/reports_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_dashboard_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_members_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_memberships_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_plans_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_trainers_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_attendance_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_payments_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_workouts_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_schedules_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_reports_screen.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

/// Global key to access the shell's ScaffoldState (for opening drawer)
final GlobalKey<ScaffoldState> appScaffoldKey = GlobalKey<ScaffoldState>();

/// Callback to navigate from inside sub-screens
void Function(String)? _globalNavigateTo;

/// Navigate to a screen by title from anywhere
void navigateToScreen(String title) {
  _globalNavigateTo?.call(title);
}

/// Centralized mobile navigation shell with drawer sidebar.
/// Uses body replacement instead of Navigator.push so the drawer always works.
class MobileNavShell extends StatefulWidget {
  const MobileNavShell({super.key});

  @override
  State<MobileNavShell> createState() => _MobileNavShellState();
}

class _MobileNavShellState extends State<MobileNavShell> {
  String _currentTitle = 'Employees';
  Widget _currentBody = const EmployeesScreen();

  @override
  void initState() {
    super.initState();
    _globalNavigateTo = _navigateTo;
  }

  @override
  void dispose() {
    if (_globalNavigateTo == _navigateTo) {
      _globalNavigateTo = null;
    }
    super.dispose();
  }

  void _navigateTo(String title) {
    final screen = _getScreenForTitle(title);
    setState(() {
      _currentTitle = title;
      _currentBody = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: appScaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _MobileDrawer(onNavigate: _navigateTo, currentTitle: _currentTitle),
      // No AppBar here — sub-screens provide their own with HamburgerButton
      body: _currentBody,
    );
  }

  Widget _getScreenForTitle(String title) {
    switch (title) {
      case 'Gym Dashboard': return const GymDashboardScreen();
      case 'Members': return const GymMembersScreen();
      case 'Memberships': return const GymMembershipsScreen();
      case 'Plans': return const GymPlansScreen();
      case 'Trainers': return const GymTrainersScreen();
      case 'Attendance': return const GymAttendanceScreen();
      case 'Payments': return const GymPaymentsScreen();
      case 'Workouts': return const GymWorkoutsScreen();
      case 'Schedules': return const GymSchedulesScreen();
      case 'Gym Reports': return const GymReportsScreen();
      case 'Employees': return const EmployeesScreen();
      case 'Inventory': return const InventoryScreen();
      case 'Warehouse': return const WarehouseScreen();
      case 'Suppliers': return const SuppliersScreen();
      case 'Purchases': return const PurchasesScreen();
      case 'Products': return const ProductManagementScreen();
      case 'Categories': return const CategoriesScreen();
      case 'Brands': return const BrandsScreen();
      case 'Units': return const UnitsScreen();
      case 'Customers': return const CustomersScreen();
      case 'Expenses': return const ExpensesAccountsScreen();
      case 'Reports': return const ReportsScreen();
      case 'Invoices': return const InvoicesScreen();
      case 'Sales Orders': return const PosOrdersScreen();
      case 'POS Terminal': return const PosScreen();
      case 'Barcode Printing': return const BarcodePrintScreen();
      case 'Settings': return const CashierSettingsScreen();
      case 'Roles': return const DesignationsRolesScreen();
      case 'Branches': return const StoreBranchesScreen();
      default: return const EmployeesScreen();
    }
  }
}

class _MobileDrawer extends StatelessWidget {
  final void Function(String) onNavigate;
  final String currentTitle;
  const _MobileDrawer({required this.onNavigate, required this.currentTitle});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = (screenWidth * 0.78).clamp(250.0, 300.0);

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: const Color(0xFFEBF3FB),
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(context),
              const Divider(height: 1, color: Color(0xFFD0DAE5)),
              Expanded(
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      children: [
                        if (auth.canAccessGym()) ...[
                          _buildGroupHeader('GYM MANAGEMENT'),
                          if (auth.can(AppPermissions.gymDashboardView))
                            _buildItem(context, Icons.grid_view_rounded, 'Gym Dashboard'),
                          if (auth.can(AppPermissions.gymMembersManage))
                            _buildItem(context, Icons.groups_rounded, 'Members'),
                          if (auth.can(AppPermissions.gymMembershipsManage))
                            _buildItem(context, Icons.card_membership_rounded, 'Memberships'),
                          if (auth.can(AppPermissions.gymPlansManage))
                            _buildItem(context, Icons.add_card_rounded, 'Plans'),
                          if (auth.can(AppPermissions.gymTrainersManage))
                            _buildItem(context, Icons.sports_gymnastics_rounded, 'Trainers'),
                          if (auth.can(AppPermissions.gymAttendanceManage))
                            _buildItem(context, Icons.how_to_reg_rounded, 'Attendance'),
                          if (auth.can(AppPermissions.gymPaymentsManage))
                            _buildItem(context, Icons.payments_rounded, 'Payments'),
                          if (auth.can(AppPermissions.gymWorkoutsManage))
                            _buildItem(context, Icons.fitness_center_rounded, 'Workouts'),
                          if (auth.can(AppPermissions.gymSchedulesManage))
                            _buildItem(context, Icons.schedule_rounded, 'Schedules'),
                          if (auth.can(AppPermissions.gymReportsView))
                            _buildItem(context, Icons.bar_chart_rounded, 'Gym Reports'),
                          const SizedBox(height: 6),
                        ],
                        if (auth.canAccessErp()) ...[
                          _buildGroupHeader('ERP MANAGEMENT'),
                          if (auth.can(AppPermissions.erpPosManage))
                            _buildItem(context, Icons.point_of_sale_rounded, 'POS Terminal'),
                          if (auth.can(AppPermissions.erpPosManage) || auth.can(AppPermissions.erpProductsManage))
                            _buildItem(context, Icons.label_outlined, 'Barcode Printing'),
                          if (auth.can(AppPermissions.erpProductsManage))
                            _buildItem(context, Icons.inventory_2_outlined, 'Products'),
                          if (auth.can(AppPermissions.erpCategoriesManage)) ...[
                            _buildItem(context, Icons.category_outlined, 'Categories'),
                            _buildItem(context, Icons.sell_outlined, 'Brands'),
                            _buildItem(context, Icons.straighten_outlined, 'Units'),
                          ],
                          if (auth.can(AppPermissions.erpInventoryManage))
                            _buildItem(context, Icons.warehouse_outlined, 'Inventory'),
                          if (auth.can(AppPermissions.erpWarehouseManage))
                            _buildItem(context, Icons.storefront_outlined, 'Warehouse'),
                          if (auth.can(AppPermissions.erpCustomersManage))
                            _buildItem(context, Icons.people_outline_rounded, 'Customers'),
                          if (auth.can(AppPermissions.erpSuppliersManage))
                            _buildItem(context, Icons.local_shipping_outlined, 'Suppliers'),
                          if (auth.can(AppPermissions.erpPurchaseManage))
                            _buildItem(context, Icons.shopping_cart_outlined, 'Purchases'),
                          if (auth.can(AppPermissions.erpSalesManage))
                            _buildItem(context, Icons.receipt_long_outlined, 'Sales Orders'),
                          if (auth.can(AppPermissions.erpInvoicesManage))
                            _buildItem(context, Icons.description_outlined, 'Invoices'),
                          if (auth.can(AppPermissions.erpSettingsManage))
                            _buildItem(context, Icons.store_outlined, 'Branches'),
                          if (auth.can(AppPermissions.erpRolesManage))
                            _buildItem(context, Icons.badge_outlined, 'Roles'),
                          if (auth.can(AppPermissions.erpPaymentsManage))
                            _buildItem(context, Icons.attach_money_rounded, 'Expenses'),
                          if (auth.can(AppPermissions.erpEmployeesManage))
                            _buildItem(context, Icons.person_outline_rounded, 'Employees'),
                          if (auth.can(AppPermissions.erpReportsView))
                            _buildItem(context, Icons.analytics_outlined, 'Reports'),
                          if (auth.can(AppPermissions.erpSettingsManage))
                            _buildItem(context, Icons.settings_outlined, 'Settings'),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: Color(0xFFD0DAE5)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.of(context).maybePop();
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      auth.logout();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                          SizedBox(width: 10),
                          Text('Sign Out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final emp = auth.employee;
        final userName = emp?.fullName?.isNotEmpty == true ? emp!.fullName : (user?.email.split('@').first ?? '');
        final userRole = user?.role.toUpperCase() ?? '';
        final initials = userName!.length >= 2 ? userName.substring(0, 2).toUpperCase() : 'U';

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(userRole, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 4),
      child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.8)),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title) {
    final isActive = currentTitle == title;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: isActive ? AppColors.primary.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.of(context).maybePop();
            onNavigate(title);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: isActive ? AppColors.primary : AppColors.neutralDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? AppColors.primary : AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
