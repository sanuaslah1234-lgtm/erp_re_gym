import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/order_provider.dart';
import 'package:erp_software/frontend/screens/cashier/orders/order_details_screen.dart';
import 'package:erp_software/frontend/screens/cashier/orders/widgets/order_filter_bar.dart';
import 'package:erp_software/frontend/screens/cashier/orders/widgets/order_list.dart';
import 'package:erp_software/frontend/screens/cashier/orders/new_sale_dialog.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/receipt_dialog.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Sales Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Title & + New Sale Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sales Management',
                                    style: TextStyle(
                                      fontSize: 22,
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
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await showDialog(
                                  context: context,
                                  builder: (_) => const NewSaleDialog(),
                                );
                                if (result == true && mounted) {
                                  final auth = Provider.of<AuthProvider>(context, listen: false);
                                  Provider.of<OrderProvider>(context, listen: false).fetchOrders(auth.token);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        const SizedBox(height: 16),

                        // Filter Bar
                        OrderFilterBar(
                          selectedStatus: orderProvider.selectedStatus,
                          selectedPaymentMethod: orderProvider.selectedPaymentMethod,
                          onSearchChanged: (val) => orderProvider.setFilterSearch(val, authProvider.token),
                          onStatusChanged: (val) => orderProvider.setFilterStatus(val, authProvider.token),
                          onPaymentMethodChanged: (val) => orderProvider.setFilterPaymentMethod(val, authProvider.token),
                        ),
                        const SizedBox(height: 20),

                        // Error Banner
                        if (orderProvider.errorMessage != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                            child: Text(orderProvider.errorMessage!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12)),
                          ),

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


