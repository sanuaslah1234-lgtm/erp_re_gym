import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class StockMovementDialog extends StatefulWidget {
  const StockMovementDialog({super.key});

  @override
  State<StockMovementDialog> createState() => _StockMovementDialogState();
}

class _StockMovementDialogState extends State<StockMovementDialog> {
  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  ProductModel? _selectedProduct;
  String _movementType = 'DAMAGE_OUT';

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _recordAdjustment() async {
    if (_selectedProduct == null) {
      ErpToast.showWarning(context, 'Please select a product!');
      return;
    }

    final qty = double.tryParse(_qtyCtrl.text) ?? 0.0;
    if (qty <= 0) {
      ErpToast.showWarning(context, 'Quantity must be greater than zero!');
      return;
    }

    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      ErpToast.showWarning(context, 'Reason / Notes required!');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<ProductManagementProvider>(context, listen: false);

    try {
      await provider.recordStockAdjustment(
        authProvider.token,
        productId: _selectedProduct!.id!,
        movementType: _movementType,
        quantity: qty,
        reason: reason,
      );
      if (mounted) {
        ErpToast.showSuccess(
          context,
          'Stock adjustment recorded!',
          title: 'Stock Adjusted',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40, vertical: 24),
      child: Container(
        width: isMobile ? double.infinity : 750,
        height: isMobile ? MediaQuery.of(context).size.height * 0.85 : 600,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isMobile ? 'Stock Movement & Damage' : 'Stock Movement Audit & Damage Record',
                    style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 20),

            // Record Damage / Adjustment Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Record Stock Damage / Manual Adjustment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  if (isMobile) ...[
                    DropdownButtonFormField<ProductModel>(
                      isExpanded: true,
                      initialValue: _selectedProduct,
                      decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder(), isDense: true),
                      items: {for (var p in provider.products) p.id: p}.values.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stock: ${p.stockQuantity})', overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (p) => setState(() => _selectedProduct = p),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _movementType,
                      decoration: const InputDecoration(labelText: 'Movement Type', border: OutlineInputBorder(), isDense: true),
                      items: const [
                        DropdownMenuItem(value: 'DAMAGE_OUT', child: Text('DAMAGE (Stock OUT)')),
                        DropdownMenuItem(value: 'ADJUSTMENT_IN', child: Text('ADJUSTMENT (Stock IN)')),
                        DropdownMenuItem(value: 'ADJUSTMENT_OUT', child: Text('ADJUSTMENT (Stock OUT)')),
                      ],
                      onChanged: (v) => setState(() => _movementType = v!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _reasonCtrl,
                            decoration: const InputDecoration(labelText: 'Reason / Notes *', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _recordAdjustment,
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Record'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ProductModel>(
                            isExpanded: true,
                            initialValue: _selectedProduct,
                            decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder(), isDense: true),
                            items: {for (var p in provider.products) p.id: p}.values.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stock: ${p.stockQuantity})', overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (p) => setState(() => _selectedProduct = p),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _movementType,
                            decoration: const InputDecoration(labelText: 'Movement Type', border: OutlineInputBorder(), isDense: true),
                            items: const [
                              DropdownMenuItem(value: 'DAMAGE_OUT', child: Text('DAMAGE (Stock OUT)')),
                              DropdownMenuItem(value: 'ADJUSTMENT_IN', child: Text('ADJUSTMENT (Stock IN)')),
                              DropdownMenuItem(value: 'ADJUSTMENT_OUT', child: Text('ADJUSTMENT (Stock OUT)')),
                            ],
                            onChanged: (v) => setState(() => _movementType = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _reasonCtrl,
                            decoration: const InputDecoration(labelText: 'Reason / Notes *', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _recordAdjustment,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Record'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text('Stock Movements Audit Trail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: provider.stockMovements.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sm = provider.stockMovements[index];
                  final isStockOut = sm.movementType.contains('OUT');
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isStockOut ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                      child: Icon(
                        isStockOut ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isStockOut ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                    ),
                    title: Text('${sm.productName} (${sm.productCode})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Ref: ${sm.referenceId ?? "N/A"} | Notes: ${sm.notes ?? "None"}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isStockOut ? "-" : "+"}${sm.quantity}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isStockOut ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                        ),
                        Text('Stock: ${sm.previousStock} → ${sm.newStock}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
