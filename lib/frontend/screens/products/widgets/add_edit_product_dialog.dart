import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class AddEditProductDialog extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _barcodeCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _purchasePriceCtrl;
  late TextEditingController _sellingPriceCtrl;
  late TextEditingController _taxCtrl;
  late TextEditingController _openingStockCtrl;
  late TextEditingController _minimumStockCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _descCtrl;

  dynamic _selectedCategoryId;
  dynamic _selectedSupplierId;
  String _selectedUnit = 'pcs';
  bool _isActive = true;

  final List<String> _units = ['pcs', 'kg', 'g', 'ltr', 'ml', 'box', 'pack', 'set'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _codeCtrl = TextEditingController(text: p?.productCode ?? 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}');
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _purchasePriceCtrl = TextEditingController(text: p?.purchasePrice.toString() ?? '0');
    _sellingPriceCtrl = TextEditingController(text: p?.sellingPrice.toString() ?? '0');
    _taxCtrl = TextEditingController(text: p?.taxPercentage.toString() ?? '0');
    _openingStockCtrl = TextEditingController(text: p?.openingStock.toString() ?? '0');
    _minimumStockCtrl = TextEditingController(text: p?.minimumStock.toString() ?? '5');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');

    _selectedCategoryId = p?.categoryId;
    _selectedSupplierId = p?.supplierId;
    _selectedUnit = p?.unit ?? 'pcs';
    _isActive = p?.isActive ?? true;
  }


  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _barcodeCtrl.dispose();
    _brandCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _taxCtrl.dispose();
    _openingStockCtrl.dispose();
    _minimumStockCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<ProductManagementProvider>(context, listen: false);

    final product = ProductModel(
      id: widget.product?.id,
      productCode: _codeCtrl.text.trim(),
      barcode: _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      categoryId: _selectedCategoryId,
      supplierId: _selectedSupplierId,
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      unit: _selectedUnit,
      purchasePrice: double.tryParse(_purchasePriceCtrl.text) ?? 0.0,
      sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0.0,
      taxPercentage: double.tryParse(_taxCtrl.text) ?? 0.0,
      openingStock: double.tryParse(_openingStockCtrl.text) ?? 0.0,
      minimumStock: double.tryParse(_minimumStockCtrl.text) ?? 5.0,
      imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      isActive: _isActive,
    );

    final success = await provider.saveProduct(authProvider.token, product);
    if (success && mounted) {
      ErpToast.showSuccess(
        context,
        widget.product == null ? 'Product saved successfully to PostgreSQL database!' : 'Product updated successfully!',
        title: 'Product Saved',
      );
      Navigator.pop(context);
    } else if (provider.errorMessage != null && mounted) {
      ErpToast.showError(context, provider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product == null ? 'Add New Product' : 'Edit Product',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(labelText: 'Product Name *', border: OutlineInputBorder()),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _codeCtrl,
                              decoration: const InputDecoration(labelText: 'SKU / Product Code *', border: OutlineInputBorder()),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<dynamic>(
                              initialValue: _selectedCategoryId,
                              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                              items: provider.categories
                                  .map((c) => DropdownMenuItem<dynamic>(value: c.id, child: Text(c.name)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedCategoryId = v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<dynamic>(
                              initialValue: _selectedSupplierId,
                              decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder()),
                              items: provider.suppliers
                                  .map((s) => DropdownMenuItem<dynamic>(value: s.id, child: Text(s.name)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedSupplierId = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandCtrl,
                              decoration: const InputDecoration(labelText: 'Brand', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedUnit,
                              decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u.toUpperCase()))).toList(),
                              onChanged: (v) => setState(() => _selectedUnit = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _purchasePriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Purchase Price (\$) *', border: OutlineInputBorder()),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _sellingPriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Selling Price (\$) *', border: OutlineInputBorder()),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _taxCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Tax / GST (%)', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _openingStockCtrl,
                              keyboardType: TextInputType.number,
                              enabled: widget.product == null,
                              decoration: const InputDecoration(labelText: 'Opening Stock', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _minimumStockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Minimum Stock Alert', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Checkbox(
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v ?? true),
                          ),
                          const Text('Product Active Status', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: provider.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
                    label: Text(widget.product == null ? 'Save Product' : 'Update Product'),
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
