import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/core/utils/export_print_helper.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/screens/products/add_product_screen.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final provider = Provider.of<ProductManagementProvider>(context, listen: false);
      provider.loadAllData(authProvider.token);
    });
  }

  void _openAddProductScreen([ProductModel? product]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(existingProduct: product),
      ),
    );
  }

  Future<void> _deleteProduct(String? token, dynamic id) async {
    try {
      final provider = Provider.of<ProductManagementProvider>(context, listen: false);
      await provider.deleteProduct(token, id);
      if (!mounted) return;
      ErpToast.showSuccess(context, 'Product deleted');
    } catch (e) {
      if (!mounted) return;
      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    final products = provider.products;
    final totalProducts = products.length;
    final inStock = products.where((p) => p.stockQuantity > p.minimumStock).length;
    final lowStock = products.where((p) => p.stockQuantity > 0 && p.stockQuantity <= p.minimumStock).length;
    final noStock = products.where((p) => p.stockQuantity == 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Products', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Products'),
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
                        // Page Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Products',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ExportPrintHelper.showPrintPage(
                                      context: context,
                                      title: 'Products List',
                                      headers: ['Code', 'Product', 'SKU', 'Category', 'Brand', 'Unit', 'Qty', 'Selling Price', 'Purchase Price', 'Status'],
                                      rows: products
                                          .map((p) => [
                                                p.barcode ?? '#${p.id}',
                                                p.name,
                                                p.productCode,
                                                p.categoryName ?? 'N/A',
                                                p.brand ?? 'N/A',
                                                p.unit,
                                                p.stockQuantity.toInt().toString(),
                                                '\$${p.sellingPrice.toStringAsFixed(2)}',
                                                '\$${p.purchasePrice.toStringAsFixed(2)}',
                                                p.stockQuantity == 0 ? 'No Stock' : (p.isLowStock ? 'Low Stock' : 'In Stock')
                                              ])
                                          .toList(),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF334155),
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.print_outlined, size: 16),
                                  label: const Text('Print'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ExportPrintHelper.exportCsv(
                                      context: context,
                                      filename: 'products_export',
                                      headers: ['Code', 'Product', 'SKU', 'Category', 'Brand', 'Unit', 'Qty', 'Selling Price', 'Purchase Price', 'Status'],
                                      rows: products
                                          .map((p) => [
                                                p.barcode ?? '#${p.id}',
                                                p.name,
                                                p.productCode,
                                                p.categoryName ?? 'N/A',
                                                p.brand ?? 'N/A',
                                                p.unit,
                                                p.stockQuantity,
                                                p.sellingPrice,
                                                p.purchasePrice,
                                                p.stockQuantity == 0 ? 'No Stock' : (p.isLowStock ? 'Low Stock' : 'In Stock')
                                              ])
                                          .toList(),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF334155),
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.download_outlined, size: 16),
                                  label: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Export'),
                                      SizedBox(width: 4),
                                      Icon(Icons.keyboard_arrow_down, size: 16),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _openAddProductScreen(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add New'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Metric Stat Cards Row
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final cardWidth = width > 900 ? (width - 48) / 4 : (width - 16) / 2;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildMetricCard('Total Products', totalProducts.toString(), Icons.inventory_2_outlined, const Color(0xFFD1FAE5), const Color(0xFF10B981), cardWidth),
                                _buildMetricCard('In Stock', inStock.toString(), Icons.check_circle_outline, const Color(0xFFDBEAFE), const Color(0xFF2563EB), cardWidth),
                                _buildMetricCard('Low Stock', lowStock.toString(), Icons.warning_amber_rounded, const Color(0xFFFEF3C7), const Color(0xFFF59E0B), cardWidth, badgeText: 'Alerts Active'),
                                _buildMetricCard('No Stock', noStock.toString(), Icons.cancel_outlined, const Color(0xFFFEE2E2), const Color(0xFFEF4444), cardWidth, badgeText: 'Needs reorder'),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Search and Filter Bar Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 260),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Search...',
                                      prefixIcon: Icon(Icons.search, size: 18),
                                      isDense: true,
                                    ),
                                    onChanged: (val) {
                                      provider.setSearchQuery(val);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.calendar_today, size: 14),
                                label: const Text('Today'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  foregroundColor: const Color(0xFF334155),
                                ),
                              ),
                              const Spacer(),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.filter_list, size: 14),
                                label: const Text('Filter'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  foregroundColor: const Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.arrow_downward, size: 14),
                                label: const Text('Sort By'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  foregroundColor: const Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.view_headline, color: Color(0xFF64748B)),
                                onPressed: () {},
                              ),
                               IconButton(
                                 icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
                                 onPressed: () => provider.loadAllData(authProvider.token),
                               ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Products Data Table Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
                            ],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: isMobile ? 1000 : null,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                columns: const [
                                  DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Selling Price', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Purchase Price', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                ],
                                rows: products.map((p) {
                                  final isNoStock = p.stockQuantity == 0;
                                  return DataRow(cells: [
                                    DataCell(Text(p.barcode ?? '#${p.id}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                                    DataCell(
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.image_outlined, size: 18, color: Color(0xFF94A3B8)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(p.productCode, style: const TextStyle(color: Color(0xFF64748B)))),
                                    DataCell(Text(p.categoryName ?? 'N/A', style: const TextStyle(color: Color(0xFF334155)))),
                                    DataCell(Text(p.brand ?? 'N/A', style: const TextStyle(color: Color(0xFF334155)))),
                                    DataCell(Text(p.unit, style: const TextStyle(color: Color(0xFF334155)))),
                                    DataCell(Text(p.stockQuantity.toInt().toString().padLeft(2, '0'), style: const TextStyle(color: Color(0xFF334155)))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isNoStock ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isNoStock ? 'No Stock' : 'In Stock',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isNoStock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text('\$${p.sellingPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                    DataCell(Text('\$${p.purchasePrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF64748B)),
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                                            onPressed: () => _openAddProductScreen(p),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                                            onPressed: () => _deleteProduct(authProvider.token, p.id!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
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

  Widget _buildMetricCard(String title, String value, IconData icon, Color iconBg, Color iconColor, double width, {String? badgeText}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          if (badgeText != null) ...[
            const SizedBox(height: 4),
            Text(badgeText, style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}
