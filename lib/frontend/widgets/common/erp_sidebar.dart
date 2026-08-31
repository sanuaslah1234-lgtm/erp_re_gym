import 'package:flutter/material.dart';
import 'package:erp_software/core/constants/app_permissions.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/screens/cashier/cashier_dashboard_screen.dart';
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
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/frontend/admin/branch/providers/branch_provider.dart';

class ErpSidebar extends StatefulWidget {
  final String activeItem;
  final ValueChanged<String>? onSelect;
  final bool isDrawer;

  const ErpSidebar({
    super.key,
    this.activeItem = 'Employees / Staff',
    this.onSelect,
    this.isDrawer = false,
  });

  @override
  State<ErpSidebar> createState() => _ErpSidebarState();
}

class _ErpSidebarState extends State<ErpSidebar> {
  late String _activeItem;

  @override
  void initState() {
    super.initState();
    _activeItem = _normalizeItemName(widget.activeItem);
  }

  @override
  void didUpdateWidget(covariant ErpSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeItem != widget.activeItem) {
      setState(() {
        _activeItem = _normalizeItemName(widget.activeItem);
      });
    }
  }

  String _normalizeItemName(String name) {
    if (name == 'POS') return 'POS Terminal';
    if (name == 'Barcode Print') return 'Barcode Printing';
    if (name == 'POS Orders') return 'Sales Orders';
    if (name == 'Employees') return 'Employees / Staff';
    if (name == 'Stock') return 'Inventory / Stock';
    if (name == 'Warehouse') return 'Warehouse Management';
    if (name == 'Units') return 'Units of Measure';
    if (name == 'Goods Vendors & Suppliers') return 'Suppliers';
    if (name == 'Store Outlets & Branches') return 'Branches';
    if (name == 'Expenses & Accounts') return 'Expenses';
    if (name == 'Reports & Analytics') return 'Reports';
    if (name == 'Gym Members') return 'Members';
    if (name == 'Gym Trainers') return 'Trainers';
    if (name == 'Gym Attendance') return 'Attendance';
    if (name == 'Gym Payments') return 'Payments';
    if (name == 'Workout Plans') return 'Workouts';
    if (name == 'Gym Schedules') return 'Schedules';
    return name;
  }

  void _handleItemTap(String title) {
    final target = _normalizeItemName(title);
    final current = _normalizeItemName(widget.activeItem);

    setState(() {
      _activeItem = target;
    });

    if (widget.onSelect != null) {
      widget.onSelect!(title);
    }
    if (widget.isDrawer) {
      Navigator.of(context).maybePop();
    }

    // Gym Module Navigation
    if (target == 'Gym Dashboard') {
      if (current != 'Gym Dashboard') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymDashboardScreen()),
        );
      }
    } else if (target == 'Members') {
      if (current != 'Members') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymMembersScreen()),
        );
      }
    } else if (target == 'Memberships') {
      if (current != 'Memberships') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymMembershipsScreen()),
        );
      }
    } else if (target == 'Membership Plans') {
      if (current != 'Membership Plans') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymPlansScreen()),
        );
      }
    } else if (target == 'Trainers') {
      if (current != 'Trainers') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymTrainersScreen()),
        );
      }
    } else if (target == 'Attendance') {
      if (current != 'Attendance') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymAttendanceScreen()),
        );
      }
    } else if (target == 'Payments') {
      if (current != 'Payments') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymPaymentsScreen()),
        );
      }
    } else if (target == 'Workouts') {
      if (current != 'Workouts') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymWorkoutsScreen()),
        );
      }
    } else if (target == 'Schedules') {
      if (current != 'Schedules') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymSchedulesScreen()),
        );
      }
    } else if (target == 'Gym Reports') {
      if (current != 'Gym Reports') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GymReportsScreen()),
        );
      }
    }
    // Retail Module Navigation
    else if (target == 'Employees / Staff') {
      if (current != 'Employees / Staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmployeesScreen()),
        );
      }
    } else if (target == 'Inventory / Stock') {
      if (current != 'Inventory / Stock') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InventoryScreen()),
        );
      }
    } else if (target == 'Warehouse Management') {
      if (current != 'Warehouse Management') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WarehouseScreen()),
        );
      }
    } else if (target == 'Suppliers') {
      if (current != 'Suppliers') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuppliersScreen()),
        );
      }
    } else if (target == 'Purchases') {
      if (current != 'Purchases') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PurchasesScreen()),
        );
      }
    } else if (target == 'Products') {
      if (current != 'Products') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProductManagementScreen()),
        );
      }
    } else if (target == 'Categories') {
      if (current != 'Categories') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
        );
      }
    } else if (target == 'Brands') {
      if (current != 'Brands') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BrandsScreen()),
        );
      }
    } else if (target == 'Units of Measure') {
      if (current != 'Units of Measure') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UnitsScreen()),
        );
      }
    } else if (target == 'Customers') {
      if (current != 'Customers') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomersScreen()),
        );
      }
    } else if (target == 'Expenses') {
      if (current != 'Expenses') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExpensesAccountsScreen()),
        );
      }
    } else if (target == 'Reports') {
      if (current != 'Reports') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReportsScreen()),
        );
      }
    } else if (target == 'Invoices') {
      if (current != 'Invoices') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InvoicesScreen()),
        );
      }
    } else if (target == 'Branches') {
      if (current != 'Branches') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return ChangeNotifierProvider(
            create: (_) => BranchProvider(token: auth.token)..fetchBranches(),
            child: const StoreBranchesScreen(),
          );
        }),
        );
      }
    } else if (target == 'Sales Orders') {
      if (current != 'Sales Orders') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PosOrdersScreen()),
        );
      }
    } else if (target == 'Dashboard' || target == 'POS Terminal' || target == 'Barcode Printing' || target == 'Settings') {
      final tab = target == 'Dashboard' ? 'POS Terminal' : target;
      if (current != tab) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CashierDashboardScreen(initialTab: tab)),
        );
      }
    } else if (target == 'Designations & Roles') {
      if (current != 'Designations & Roles') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DesignationsRolesScreen()),
        );
      }
    } else {
      ErpToast.showInfo(
        context,
        '$title module selected',
        title: 'ERP Management',
      );
    }
  }

  void _handleSignOut() {
    if (widget.isDrawer) {
      Navigator.of(context).maybePop();
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    ErpToast.showInfo(
      context,
      'Signed out successfully',
      title: 'Session Ended',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      color: const Color(0xFFEBF3FB),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final canGym = auth.canAccessGym();
                  final canErp = auth.canAccessErp();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    children: [
                      // Gym Management Module Section (Two-Branch Navigation)
                      if (canGym) ...[
                        _buildGroupHeader('GYM MANAGEMENT'),
                        if (auth.can(AppPermissions.gymDashboardView))
                          _buildMenuItem(Icons.grid_view_rounded, 'Gym Dashboard'),
                        if (auth.can(AppPermissions.gymMembersManage))
                          _buildMenuItem(Icons.groups_rounded, 'Members'),
                        if (auth.can(AppPermissions.gymMembershipsManage))
                          _buildMenuItem(Icons.card_membership_rounded, 'Memberships'),
                        if (auth.can(AppPermissions.gymPlansManage))
                          _buildMenuItem(Icons.add_card_rounded, 'Membership Plans'),
                        if (auth.can(AppPermissions.gymTrainersManage))
                          _buildMenuItem(Icons.sports_gymnastics_rounded, 'Trainers'),
                        if (auth.can(AppPermissions.gymAttendanceManage))
                          _buildMenuItem(Icons.how_to_reg_rounded, 'Attendance'),
                        if (auth.can(AppPermissions.gymPaymentsManage))
                          _buildMenuItem(Icons.payments_rounded, 'Payments'),
                        if (auth.can(AppPermissions.gymWorkoutsManage))
                          _buildMenuItem(Icons.fitness_center_rounded, 'Workouts'),
                        if (auth.can(AppPermissions.gymSchedulesManage))
                          _buildMenuItem(Icons.schedule_rounded, 'Schedules'),
                        if (auth.can(AppPermissions.gymReportsView))
                          _buildMenuItem(Icons.bar_chart_rounded, 'Gym Reports'),
                        const SizedBox(height: 14),
                      ],

                      // ERP Management Module Section (Two-Branch Navigation)
                      if (canErp) ...[
                        _buildGroupHeader('ERP MANAGEMENT'),
                        if (auth.can(AppPermissions.erpPosManage))
                          _buildMenuItem(Icons.desktop_windows_outlined, 'POS Terminal'),
                        if (auth.can(AppPermissions.erpPosManage) || auth.can(AppPermissions.erpProductsManage))
                          _buildMenuItem(Icons.label_outlined, 'Barcode Printing'),
                        if (auth.can(AppPermissions.erpProductsManage))
                          _buildMenuItem(Icons.inventory_2_outlined, 'Products'),
                        if (auth.can(AppPermissions.erpCategoriesManage)) ...[
                          _buildMenuItem(Icons.category_outlined, 'Categories'),
                          _buildMenuItem(Icons.sell_outlined, 'Brands'),
                          _buildMenuItem(Icons.straighten_outlined, 'Units of Measure'),
                        ],
                        if (auth.can(AppPermissions.erpInventoryManage))
                          _buildMenuItem(Icons.unarchive_outlined, 'Inventory / Stock'),
                        if (auth.can(AppPermissions.erpWarehouseManage))
                          _buildMenuItem(Icons.warehouse_outlined, 'Warehouse Management'),
                        if (auth.can(AppPermissions.erpCustomersManage))
                          _buildMenuItem(Icons.people_outline_rounded, 'Customers'),
                        if (auth.can(AppPermissions.erpSuppliersManage))
                          _buildMenuItem(Icons.local_shipping_outlined, 'Goods Vendors & Suppliers'),
                        if (auth.can(AppPermissions.erpPurchaseManage))
                          _buildMenuItem(Icons.shopping_cart_outlined, 'Purchases'),
                        if (auth.can(AppPermissions.erpSalesManage))
                          _buildMenuItem(Icons.shopping_bag_outlined, 'Sales Orders'),
                        if (auth.can(AppPermissions.erpInvoicesManage))
                          _buildMenuItem(Icons.receipt_long_outlined, 'Invoices'),
                        if (auth.can(AppPermissions.erpSettingsManage))
                          _buildMenuItem(Icons.store_outlined, 'Store Outlets & Branches'),
                        if (auth.can(AppPermissions.erpRolesManage))
                          _buildMenuItem(Icons.badge_outlined, 'Designations & Roles'),
                        if (auth.can(AppPermissions.erpPaymentsManage))
                          _buildMenuItem(Icons.attach_money_rounded, 'Expenses & Accounts'),
                        if (auth.can(AppPermissions.erpEmployeesManage))
                          _buildMenuItem(Icons.person_outline_rounded, 'Employees / Staff'),
                        if (auth.can(AppPermissions.erpReportsView))
                          _buildMenuItem(Icons.analytics_outlined, 'Reports & Analytics'),
                        if (auth.can(AppPermissions.erpSettingsManage))
                          _buildMenuItem(Icons.settings_outlined, 'Settings'),
                        const SizedBox(height: 16),
                      ],
                    ],
                  );
                },
              ),
            ),

            // Bottom Section: Sign Out Button
            const Divider(height: 1, color: Color(0xFFCBD5E1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _handleSignOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: Color(0xFFEF4444),
                        ),
                        SizedBox(width: 14),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 10, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2563EB),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    final normalized = _normalizeItemName(title);
    final isActive = normalized == _activeItem;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleItemTap(title),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1D61F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1D61F2).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : const Color(0xFF334155),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
