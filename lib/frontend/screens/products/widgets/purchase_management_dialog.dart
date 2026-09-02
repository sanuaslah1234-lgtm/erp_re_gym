import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/core/models/purchase_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class PurchaseManagementDialog extends StatefulWidget {
  const PurchaseManagementDialog({super.key});

  @override
  State<PurchaseManagementDialog> createState() => _PurchaseManagementDialogState();
}

class _PurchaseManagementDialogState extends State<PurchaseManagementDialog> {
  final _invoiceCtrl = TextEditingController(text: 'PUR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}');
  final _qtyCtrl = TextEditingController(text: '10');
  final _priceCtrl = TextEditingController(text: '0');
  final _discountCtrl = TextEditingController(text: '0');

  dynamic _selectedSupplierId;
  ProductModel? _selectedProduct;

  @override
  void dispose() {
    _invoiceCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPurchase() async {
    if (_selectedProduct == null) {
      ErpToast.showWarning(context, 'Please select a product for purchase!');
      return;
    }

    final qty = double.tryParse(_qtyCtrl.text) ?? 0.0;
    if (qty <= 0) {
      ErpToast.showWarning(context, 'Quantity must be greater than zero!');
      return;
    }

    final price = double.tryParse(_priceCtrl.text) ?? _selectedProduct!.purchasePrice;
    final discount = double.tryParse(_discountCtrl.text) ?? 0.0;
    final tax = (price * qty) * (_selectedProduct!.taxPercentage / 100);
    final subtotal = price * qty;
    final total = (subtotal + tax) - discount;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<ProductManagementProvider>(context, listen: false);

    final item = PurchaseItemModel(
      productId: _selectedProduct!.id!,
      productName: _selectedProduct!.name,
      productCode: _selectedProduct!.productCode,
      quantity: qty,
      purchasePrice: price,
      taxAmount: tax,
      discountAmount: discount,
      totalAmount: total,
    );

    final purchase = PurchaseModel(
      invoiceNumber: _invoiceCtrl.text.trim(),
      supplierId: _selectedSupplierId,
      subtotal: subtotal,
      taxAmount: tax,
      discountAmount: discount,
      totalAmount: total,
      paymentStatus: 'paid',
      items: [item],
    );

    try {
      await provider.createPurchase(authProvider.token, purchase);
      if (mounted) {
        ErpToast.showSuccess(
          context,
          'Purchase Invoice ${_invoiceCtrl.text} saved!',
          title: 'Stock IN Complete',
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 20),
      child: Container(
        width: isMobile ? double.infinity : 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Create Purchase (Stock IN)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 16),

              if (isMobile) ...[
                TextField(
                  controller: _invoiceCtrl,
                  decoration: const InputDecoration(labelText: 'Invoice Number *', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<dynamic>(
                  initialValue: _selectedSupplierId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder(), isDense: true),
                  items: provider.suppliers.map((s) => DropdownMenuItem<dynamic>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _selectedSupplierId = v),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _invoiceCtrl,
                        decoration: const InputDecoration(labelText: 'Invoice Number *', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<dynamic>(
                        initialValue: _selectedSupplierId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder()),
                        items: provider.suppliers.map((s) => DropdownMenuItem<dynamic>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setState(() => _selectedSupplierId = v),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              DropdownButtonFormField<ProductModel>(
                initialValue: _selectedProduct,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Select Product *', border: OutlineInputBorder(), isDense: true),
                items: provider.products.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text('${p.name} (${p.productCode}) - Stock: ${p.stockQuantity.toInt()}', overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (p) {
                  setState(() {
                    _selectedProduct = p;
                    if (p != null) {
                      _priceCtrl.text = p.purchasePrice.toString();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),

              if (isMobile) ...[
                TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity (Stock IN) *', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Unit Price (\$) *', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Discount (\$) ', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Quantity (Stock IN) *', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Purchase Unit Price (\$) *', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Discount (\$) ', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _submitPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Process Stock IN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
