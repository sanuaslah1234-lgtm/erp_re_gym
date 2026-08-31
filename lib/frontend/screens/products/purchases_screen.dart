import 'package:flutter/material.dart';
import 'package:erp_software/core/models/purchase_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/screens/products/widgets/purchase_management_dialog.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:provider/provider.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ProductManagementProvider>(context, listen: false).loadAllData(auth.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final provider = Provider.of<ProductManagementProvider>(context);
    final purchases = provider.purchases.where((p) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return p.invoiceNumber.toLowerCase().contains(q) || (p.supplierName?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile ? Drawer(child: ErpSidebar(activeItem: 'Purchases', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Purchases'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Purchases', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                SizedBox(height: 4),
                                Text('Manage purchase orders and history', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAddPurchase(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New Purchase'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
                          child: Row(children: [
                            Expanded(child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: InputDecoration(hintText: 'Search purchases...', prefixIcon: const Icon(Icons.search, size: 18), isDense: true, filled: true, fillColor: AppColors.surfaceSecondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            )),
                            const SizedBox(width: 8),
                            Text('${purchases.length} purchase${purchases.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        if (provider.isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                        else if (purchases.isEmpty)
                          Container(
                            width: double.infinity, padding: const EdgeInsets.all(50),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                            child: Column(children: [
                              const Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 14),
                              const Text('No purchases found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 5),
                              const Text('Create your first purchase order to get started.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ]),
                          )
                        else
                          _buildTable(purchases),
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

  Widget _buildTable(List<PurchaseModel> purchases) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 900,
          child: Column(children: [
            Container(
              height: 44, padding: const EdgeInsets.symmetric(horizontal: 20), color: AppColors.surfaceSecondary,
              child: const Row(children: [
                SizedBox(width: 120, child: Text('INVOICE #', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 160, child: Text('SUPPLIER', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 120, child: Text('DATE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('TOTAL', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 130, child: Text('PAYMENT', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 80, child: Text('ACTION', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...List.generate(purchases.length, (index) {
              final p = purchases[index];
              final isLast = index == purchases.length - 1;
              final dateStr = '${p.purchaseDate.day}/${p.purchaseDate.month}/${p.purchaseDate.year}';
              final isPaid = p.paymentStatus == 'paid';
              return Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight))),
                child: Row(children: [
                  SizedBox(width: 120, child: Text(p.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 160, child: Text(p.supplierName ?? 'General', style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 120, child: Text(dateStr, style: const TextStyle(color: AppColors.textSecondary))),
                  SizedBox(width: 100, child: Text('\$${p.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                  const SizedBox(width: 100),
                  SizedBox(width: 130, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isPaid ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(p.paymentStatus.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isPaid ? AppColors.success : AppColors.warning)),
                  )),
                  SizedBox(width: 80, child: Row(children: [
                    _iconBtn(Icons.edit_outlined, () => _showEditDialog(context, p)),
                    const SizedBox(width: 4),
                    _iconBtn(Icons.delete_outline, () => _showDeleteDialog(context, p), danger: true),
                  ])),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }

  void _showAddPurchase(BuildContext context) {
    showDialog(context: context, builder: (_) => const PurchaseManagementDialog());
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool danger = false}) {
    return Material(
      color: danger ? AppColors.dangerLight : AppColors.neutralLight,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(7), child: SizedBox(width: 28, height: 28, child: Icon(icon, size: 14, color: danger ? AppColors.danger : AppColors.neutralDark))),
    );
  }

  void _showEditDialog(BuildContext context, PurchaseModel p) {
    final invoiceCtrl = TextEditingController(text: p.invoiceNumber);
    final supplierCtrl = TextEditingController(text: p.supplierName ?? '');
    final totalCtrl = TextEditingController(text: p.totalAmount.toString());
    String paymentStatus = p.paymentStatus;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(width: 480, padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Edit Purchase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
          ]),
          const Divider(height: 20),
          TextField(controller: invoiceCtrl, decoration: const InputDecoration(labelText: 'Invoice Number *', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText: 'Supplier Name', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Amount *', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: paymentStatus,
            decoration: const InputDecoration(labelText: 'Payment Status', border: OutlineInputBorder(), isDense: true),
            items: const [
              DropdownMenuItem(value: 'paid', child: Text('Paid')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'partial', child: Text('Partial')),
            ],
            onChanged: (v) => setDialogState(() => paymentStatus = v ?? paymentStatus),
          ),
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(
            onPressed: () async {
              if (invoiceCtrl.text.trim().isEmpty) { ErpToast.showError(ctx, 'Invoice number is required'); return; }
              try {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final provider = Provider.of<ProductManagementProvider>(context, listen: false);
                await provider.updatePurchase(auth.token, p.id, PurchaseModel(
                  id: p.id,
                  invoiceNumber: invoiceCtrl.text.trim(),
                  supplierName: supplierCtrl.text.trim().isEmpty ? null : supplierCtrl.text.trim(),
                  totalAmount: double.tryParse(totalCtrl.text) ?? p.totalAmount,
                  paymentStatus: paymentStatus,
                  purchaseDate: p.purchaseDate,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) ErpToast.showSuccess(context, 'Purchase updated');
              } catch (e) {
                if (mounted) ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
              }
            },
            icon: const Icon(Icons.save, size: 16), label: const Text('Save'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
          )),
        ])),
      ),
    ));
  }

  void _showDeleteDialog(BuildContext context, PurchaseModel p) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Purchase'),
      content: Text('Delete purchase "${p.invoiceNumber}"? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            try {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final provider = Provider.of<ProductManagementProvider>(context, listen: false);
              await provider.deletePurchase(auth.token, p.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) ErpToast.showSuccess(context, 'Purchase deleted');
            } catch (e) {
              if (mounted) ErpToast.showError(ctx, e.toString().replaceAll('Exception: ', ''));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
