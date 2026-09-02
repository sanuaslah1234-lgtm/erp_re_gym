import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
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

    final stockVal = provider.stockReport['totalStockValue'] ?? 0.0;
    final retailVal = provider.stockReport['totalRetailValue'] ?? 0.0;
    final totalProd = provider.stockReport['totalProducts'] ?? 0;
    final lowStockCount = provider.stockReport['lowStockCount'] ?? 0;

    final totalSales = provider.profitLossReport['totalSales'] ?? 0.0;
    final totalPurchases = provider.profitLossReport['totalPurchases'] ?? 0.0;
    final totalExpenses = provider.profitLossReport['totalExpenses'] ?? 0.0;
    final netProfit = provider.profitLossReport['netProfit'] ?? 0.0;

    final isMobile = MediaQuery.of(context).size.width < 750;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ERP Financial & Inventory Reports',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 20),

                              // KPI Metric Cards
                              if (isMobile)
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        _buildKpiCard('Total Stock Value', '\$${stockVal.toStringAsFixed(2)}', Icons.inventory_2, const Color(0xFF2563EB)),
                                        const SizedBox(width: 10),
                                        _buildKpiCard('Total Retail Value', '\$${retailVal.toStringAsFixed(2)}', Icons.store, const Color(0xFF10B981)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _buildKpiCard('Total Products', '$totalProd Items', Icons.shopping_bag, const Color(0xFF8B5CF6)),
                                        const SizedBox(width: 10),
                                        _buildKpiCard('Low Stock Items', '$lowStockCount Items', Icons.warning_amber_rounded, const Color(0xFFEF4444)),
                                      ],
                                    ),
                                  ],
                                )
                              else
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
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                                    if (isMobile)
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: _buildFinancialColumn('Total Sales', '\$${totalSales.toStringAsFixed(2)}', const Color(0xFF10B981))),
                                              Expanded(child: _buildFinancialColumn('Total Purchases', '\$${totalPurchases.toStringAsFixed(2)}', const Color(0xFF3B82F6))),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(child: _buildFinancialColumn('Total Expenses', '\$${totalExpenses.toStringAsFixed(2)}', const Color(0xFFF59E0B))),
                                              Expanded(child: _buildFinancialColumn('Net Profit', '\$${netProfit.toStringAsFixed(2)}', netProfit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                            ],
                                          ),
                                        ],
                                      )
                                    else
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
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                                      separatorBuilder: (_, _) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final lowProd = provider.products.where((p) => p.isLowStock).toList()[index];
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(lowProd.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Text('SKU: ${lowProd.productCode} | Min: ${lowProd.minimumStock} ${lowProd.unit}'),
                                          trailing: Text(
                                            'Stock: ${lowProd.stockQuantity}',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
