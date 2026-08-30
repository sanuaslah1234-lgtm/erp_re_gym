import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? existingProduct;

  const AddProductScreen({super.key, this.existingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _purchasePriceController = TextEditingController(text: '0.00');
  final TextEditingController _sellingPriceController = TextEditingController(text: '0.00');
  final TextEditingController _taxController = TextEditingController(text: '18');
  final TextEditingController _discountController = TextEditingController(text: '5');

  final TextEditingController _openingStockController = TextEditingController(text: '0');
  final TextEditingController _lowStockAlertController = TextEditingController(text: '10');
  final TextEditingController _warehouseController = TextEditingController(text: 'Main Warehouse');

  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedUnit;
  String _selectedStatus = 'Active';

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _nameController.text = p.name;
      _codeController.text = p.productCode;
      _skuController.text = p.barcode ?? p.productCode;
      _descriptionController.text = p.description ?? '';
      _purchasePriceController.text = p.purchasePrice.toStringAsFixed(2);
      _sellingPriceController.text = p.sellingPrice.toStringAsFixed(2);
      _taxController.text = p.taxPercentage.toStringAsFixed(0);
      _openingStockController.text = p.openingStock.toStringAsFixed(0);
      _lowStockAlertController.text = p.minimumStock.toStringAsFixed(0);
      _selectedCategory = p.categoryName;
      _selectedBrand = p.brand;
      _selectedUnit = p.unit;
      _selectedStatus = p.isActive ? 'Active' : 'Inactive';
    } else {
      _codeController.text = 'PRD001';
      _skuController.text = 'SKU-${1000 + DateTime.now().millisecond}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _openingStockController.dispose();
    _lowStockAlertController.dispose();
    _warehouseController.dispose();
    super.dispose();
  }

  void _handleSaveProduct(ProductManagementProvider provider, AuthProvider authProvider) async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final sku = _skuController.text.trim();

    if (name.isEmpty) {
      ErpToast.showError(context, 'Product Name is required!');
      return;
    }

    final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0.0;
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    final minStock = double.tryParse(_lowStockAlertController.text) ?? 5.0;
    final openingStock = double.tryParse(_openingStockController.text) ?? 0.0;

    final catObj = provider.categories.where((c) => c.name == _selectedCategory).firstOrNull;

    final product = ProductModel(
      id: widget.existingProduct?.id,
      productCode: code.isNotEmpty ? code : sku,
      barcode: sku,
      name: name,
      categoryId: catObj?.id,
      categoryName: _selectedCategory ?? 'Unassigned',
      brand: _selectedBrand ?? 'General',
      unit: _selectedUnit ?? 'pcs',
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      taxPercentage: tax,
      openingStock: openingStock,
      stockQuantity: widget.existingProduct?.stockQuantity ?? openingStock,
      minimumStock: minStock,
      description: _descriptionController.text.trim(),
      isActive: _selectedStatus == 'Active',
    );

    try {
      await provider.saveProduct(authProvider.token, product);
      if (mounted) {
        ErpToast.showSuccess(context, 'Product saved successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(isDrawer: true)) : null,
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
                        // Page Header with Save Product button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Add Product',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Create a new product for inventory',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _handleSaveProduct(provider, authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.save_outlined, size: 18),
                              label: const Text('Save Product'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Two Columns Layout (Product Info & Pricing vs Product Image & Quick Tips)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Main Form Column
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  // Card 1: Product Information
                                  _buildCardContainer(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle(Icons.widgets_outlined, 'Product Information'),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInputField('Product Name', _nameController, hint: 'Apple iPhone 15'),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildInputField('Product Code', _codeController, hint: 'PRD001'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInputField('SKU', _skuController, hint: 'SKU-1001'),
                                            ),
                                            const SizedBox(width: 16),

                                            // Category Dropdown
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                                  const SizedBox(height: 6),
                                                  DropdownButtonFormField<String>(
                                                    initialValue: _selectedCategory,
                                                    hint: const Text('Choose Category', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                                                    decoration: const InputDecoration(isDense: true),
                                                    items: provider.categories.map((c) {
                                                      return DropdownMenuItem<String>(
                                                        value: c.name,
                                                        child: Text(c.name),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      setState(() => _selectedCategory = val);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        Row(
                                          children: [
                                            // Brand Dropdown
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Brand', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                                  const SizedBox(height: 6),
                                                  DropdownButtonFormField<String>(
                                                    initialValue: _selectedBrand,
                                                    hint: const Text('Select Brand', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                                                    decoration: const InputDecoration(isDense: true),
                                                    items: provider.brands.map((b) {
                                                      return DropdownMenuItem<String>(
                                                        value: b.name,
                                                        child: Text(b.name),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      setState(() => _selectedBrand = val);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Unit Dropdown
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                                  const SizedBox(height: 6),
                                                  DropdownButtonFormField<String>(
                                                    initialValue: _selectedUnit,
                                                    hint: const Text('Choose Unit', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                                                    decoration: const InputDecoration(isDense: true),
                                                    items: provider.units.map((u) {
                                                      return DropdownMenuItem<String>(
                                                        value: u.name,
                                                        child: Text('${u.name} (${u.shortSymbol})'),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      setState(() => _selectedUnit = val);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Status
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                                  const SizedBox(height: 6),
                                                  DropdownButtonFormField<String>(
                                                    initialValue: _selectedStatus,
                                                    decoration: const InputDecoration(isDense: true),
                                                    items: const [
                                                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                                                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                                                    ],
                                                    onChanged: (val) {
                                                      if (val != null) setState(() => _selectedStatus = val);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Spacer(),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Description
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                            const SizedBox(height: 6),
                                            TextField(
                                              controller: _descriptionController,
                                              maxLines: 4,
                                              decoration: const InputDecoration(
                                                hintText: 'Write product description...',
                                                isDense: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Card 2: Pricing
                                  _buildCardContainer(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Pricing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInputField('Purchase Price (Cost)', _purchasePriceController, hint: '0.00'),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildInputField('Selling Price', _sellingPriceController, hint: '0.00'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInputField('Tax (%)', _taxController, hint: '18'),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildInputField('Discount', _discountController, hint: '5'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Card 3: Inventory
                                  _buildCardContainer(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Inventory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Note: Inventory counts are managed via Purchases and Stock Adjustments.',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInputField('Opening Stock (Read-only)', _openingStockController, readOnly: true),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildInputField('Low Stock Alert', _lowStockAlertController, hint: '10'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInputField('Warehouse', _warehouseController),
                                            ),
                                            const SizedBox(width: 16),
                                            const Spacer(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isMobile) const SizedBox(width: 20),

                            // Right Column (Product Image & Quick Tips)
                            if (!isMobile)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    // Card 4: Product Image
                                    _buildCardContainer(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Product Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                          const SizedBox(height: 16),
                                          Container(
                                            width: double.infinity,
                                            height: 180,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.upload_file_outlined, size: 36, color: Color(0xFF4F46E5)),
                                                const SizedBox(height: 10),
                                                const Text('Click or Drag Image here', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                                const Text('PNG, JPG up to 5MB', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                const SizedBox(height: 14),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    ErpToast.showInfo(context, 'Image upload selected');
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF4F46E5),
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  ),
                                                  child: const Text('Upload Image', style: TextStyle(fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Card 5: Quick Tips
                                    _buildCardContainer(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Quick Tips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                          SizedBox(height: 14),
                                          _TipItem(text: 'Use a unique SKU.'),
                                          SizedBox(height: 8),
                                          _TipItem(text: 'Upload a high-quality product image.'),
                                          SizedBox(height: 8),
                                          _TipItem(text: 'Set low stock alerts.'),
                                          SizedBox(height: 8),
                                          _TipItem(text: 'Verify pricing before saving.'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {String? hint, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
          ),
        ),
      ],
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }
}
