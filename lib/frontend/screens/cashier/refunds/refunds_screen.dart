import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/refund_provider.dart';
import 'package:erp_software/frontend/screens/cashier/refunds/refund_details_screen.dart';
import 'package:erp_software/frontend/screens/cashier/refunds/widgets/refund_item_selector.dart';
import 'package:erp_software/frontend/screens/cashier/refunds/widgets/refund_order_search.dart';
import 'package:erp_software/frontend/screens/cashier/refunds/widgets/refund_summary.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class RefundsScreen extends StatefulWidget {
  const RefundsScreen({super.key});

  @override
  State<RefundsScreen> createState() => _RefundsScreenState();
}

class _RefundsScreenState extends State<RefundsScreen> {
  final TextEditingController _orderSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<RefundProvider>(context, listen: false).fetchRefunds(token);
    });
  }

  @override
  void dispose() {
    _orderSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refundProvider = Provider.of<RefundProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Refunds'),
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
                        const Text('POS Refunds & Returns Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 20),

                        // Refund Creation Box
                        RefundOrderSearch(
                          controller: _orderSearchController,
                          onSearch: () {
                            if (_orderSearchController.text.trim().isNotEmpty) {
                              refundProvider.searchOrderForRefund(authProvider.token, _orderSearchController.text.trim());
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        if (refundProvider.targetOrderForRefund != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: RefundItemSelector(
                                  order: refundProvider.targetOrderForRefund!,
                                  refundQuantities: refundProvider.refundQuantities,
                                  onQuantityChanged: (itemKey, qty, maxQty) {
                                    refundProvider.setRefundQuantity(itemKey, qty, maxQty);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: RefundSummaryWidget(
                                  calculatedTotal: refundProvider.calculatedRefundTotal,
                                  refundMethod: refundProvider.refundMethod,
                                  reason: refundProvider.refundReason,
                                  isLoading: refundProvider.isLoading,
                                  onMethodChanged: (m) => refundProvider.setRefundMethod(m),
                                  onReasonChanged: (r) => refundProvider.setRefundReason(r),
                                  onSubmitRefund: () async {
                                    final refund = await refundProvider.processRefund(authProvider.token);
                                    if (refund != null && context.mounted) {
                                      ErpToast.showSuccess(
                                        context,
                                        'Refund ${refund.refundNumber} completed! Stock restored in PostgreSQL.',
                                        title: 'Refund Processed',
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Historical Refunds Table Header
                        const Text('Recent Refund Logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),

                        refundProvider.isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DataTable(
                                  columnSpacing: 28,
                                  columns: const [
                                    DataColumn(label: Text('Refund No', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Order No', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Method', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Processed By', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: refundProvider.refunds.map((r) {
                                    return DataRow(
                                      onSelectChanged: (_) {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => RefundDetailsScreen(refund: r)));
                                      },
                                      cells: [
                                        DataCell(Text(r.refundNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))),
                                        DataCell(Text(r.orderNumber ?? 'Order #${r.orderId}')),
                                        DataCell(Text('\$${r.refundAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(r.refundMethod)),
                                        DataCell(Text(r.reason ?? 'N/A')),
                                        DataCell(Text(r.processorName ?? 'User #${r.processedBy}')),
                                      ],
                                    );
                                  }).toList(),
                                ),
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

