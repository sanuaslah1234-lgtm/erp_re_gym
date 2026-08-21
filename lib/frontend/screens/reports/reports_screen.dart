import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/erp_topbar.dart';
import 'package:provider/provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final provider = Provider.of<ProductManagementProvider>(context, listen: false);
      provider.loadAllData(authProvider.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    final stockVal = provider.stockReport['totalStockValue'] ?? 0.0;
    final retailVal = provider.stockReport['totalRetailValue'] ?? 0.0;
    final totalProd = provider.stockReport['totalProducts'] ?? 0;
    final lowStockCount = provider.stockReport['lowStockCount'] ?? 0;

    final totalSales = provider.profitLossReport['totalSales'] ?? 0.0;
    final totalPurchases = provider.profitLossReport['totalPurchases'] ?? 0.0;
    final totalExpenses = provider.profitLossReport['totalExpenses'] ?? 0.0;
    final netProfit = provider.profitLossReport['netProfit'] ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Reports'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ERP Financial & Inventory Reports',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 20),

                              // KPI Metric Cards
                              Row(
                                children: [
                                  _buildKpiCard('Total Stock Value', '\$${stockVal.toStringAsFixed(2)}', Icons.inventory_2, const Color(0xFF2563EB)),
                                  const SizedBox(width: 16),
                                  _buildKpiCard('Total Retail Value', '\$${retailVal.toStringAsFixed(2)}', Icons.store, const Color(0xFF10B981)),
                                  const SizedBox(width: 16),
                                  _buildKpiCard('Total Products', '$totalProd Items', Icons.shopping_bag, const Color(0xFF8B5CF6)),
                                  const SizedBox(width: 16),
                                  _buildKpiCard('Low Stock Items', '$lowStockCount Items', Icons.warning_amber_rounded, const Color(0xFFEF4444)),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Financial Summary Card
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Profit & Loss Summary (Real PostgreSQL Data)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildFinancialColumn('Total Sales', '\$${totalSales.toStringAsFixed(2)}', const Color(0xFF10B981)),
                                        _buildFinancialColumn('Total Purchases', '\$${totalPurchases.toStringAsFixed(2)}', const Color(0xFF3B82F6)),
                                        _buildFinancialColumn('Total Expenses', '\$${totalExpenses.toStringAsFixed(2)}', const Color(0xFFF59E0B)),
                                        _buildFinancialColumn('Net Profit', '\$${netProfit.toStringAsFixed(2)}', netProfit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Low Stock Warning List Table
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Low Stock Warning Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                                    const SizedBox(height: 12),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: provider.products.where((p) => p.isLowStock).length,
                                      separatorBuilder: (_, __) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final lowProd = provider.products.where((p) => p.isLowStock).toList()[index];
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(lowProd.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Text('SKU: ${lowProd.productCode} | Minimum Required: ${lowProd.minimumStock} ${lowProd.unit}'),
                                          trailing: Text(
                                            'Current Stock: ${lowProd.stockQuantity}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
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

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
