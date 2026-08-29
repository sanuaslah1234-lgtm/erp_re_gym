import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/order_provider.dart';
import 'package:erp_software/frontend/screens/cashier/orders/order_details_screen.dart';
import 'package:erp_software/frontend/screens/cashier/orders/widgets/order_filter_bar.dart';
import 'package:erp_software/frontend/screens/cashier/orders/widgets/order_list.dart';
import 'package:erp_software/frontend/screens/cashier/pos/pos_screen.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/receipt_dialog.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

class PosOrdersScreen extends StatefulWidget {
  const PosOrdersScreen({super.key});

  @override
  State<PosOrdersScreen> createState() => _PosOrdersScreenState();
}

class _PosOrdersScreenState extends State<PosOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<OrderProvider>(context, listen: false).fetchOrders(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'POS Orders'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Title & + New Sale Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sales Management',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage invoices and customer sales.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PosScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text(
                                '+ New Sale',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Filter Bar
                        OrderFilterBar(
                          selectedStatus: orderProvider.selectedStatus,
                          selectedPaymentMethod: orderProvider.selectedPaymentMethod,
                          onSearchChanged: (val) => orderProvider.setFilterSearch(val, authProvider.token),
                          onStatusChanged: (val) => orderProvider.setFilterStatus(val, authProvider.token),
                          onPaymentMethodChanged: (val) => orderProvider.setFilterPaymentMethod(val, authProvider.token),
                        ),
                        const SizedBox(height: 20),

                        // Order List Table
                        orderProvider.isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                            : OrderList(
                                orders: orderProvider.orders,
                                onOrderTap: (order) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
                                  );
                                },
                                onPrintReceipt: (order) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => ReceiptDialog(order: order),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


