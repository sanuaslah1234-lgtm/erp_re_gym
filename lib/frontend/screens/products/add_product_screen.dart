import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/config/app_config.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
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
  String? _selectedWarehouseId;
  List<Map<String, dynamic>> _warehouses = [];

  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedUnit;
  String _selectedStatus = 'Active';

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
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
      final rand = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
      _codeController.text = 'PRD-$rand';
      _skuController.text = 'SKU-$rand';
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
    super.dispose();
  }

  Future<void> _loadWarehouses() async {
    try {
      final res = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/warehouses'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data = decoded is List ? decoded : (decoded is Map ? (decoded['data'] ?? []) : []);
        if (mounted) {
          setState(() {
            _warehouses = data.cast<Map<String, dynamic>>();
            // Auto-select if only one warehouse
            if (_warehouses.length == 1 && _selectedWarehouseId == null) {
              _selectedWarehouseId = _warehouses[0]['id'].toString();
            }
          });
        }
      }
    } catch (_) {}
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
    final catId = catObj?.id ?? widget.existingProduct?.categoryId;

    final product = ProductModel(
      id: widget.existingProduct?.id,
      productCode: code.isNotEmpty ? code : sku,
      barcode: sku.isNotEmpty ? sku : (code.isNotEmpty ? code : null),
      name: name,
      categoryId: catId,
      categoryName: _selectedCategory ?? widget.existingProduct?.categoryName ?? 'Unassigned',
      brand: _selectedBrand ?? widget.existingProduct?.brand ?? 'General',
      unit: _selectedUnit ?? widget.existingProduct?.unit ?? 'pcs',
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
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Header with Save Product button
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Add Product',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Create a new product for inventory',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _handleSaveProduct(provider, authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.save_outlined, size: 16),
                              label: Text(isMobile ? 'Save' : 'Save Product'),
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
                                        _buildResponsiveRow(
                                          isMobile,
                                          _buildInputField('Product Name', _nameController, hint: 'Apple iPhone 15'),
                                          _buildInputField('Product Code', _codeController, hint: 'PRD001'),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildResponsiveRow(
                                          isMobile,
                                          _buildInputField('SKU', _skuController, hint: 'SKU-1001'),
                                          // Category Dropdown
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<String>(
                                                isExpanded: true,
                                                initialValue: (_selectedCategory != null && provider.categories.any((c) => c.name == _selectedCategory))
                                                    ? _selectedCategory
                                                    : (_selectedCategory != null && _selectedCategory!.isNotEmpty ? _selectedCategory : null),
                                                hint: const Text('Choose Category', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                                                decoration: const InputDecoration(isDense: true),
                                                items: () {
                                                  final items = provider.categories.map((c) => c.name).toSet().toList();
                                                  if (_selectedCategory != null && _selectedCategory!.isNotEmpty && !items.contains(_selectedCategory)) {
                                                    items.insert(0, _selectedCategory!);
                                                  }
                                                  return items.map((name) => DropdownMenuItem<String>(value: name, child: Text(name, overflow: TextOverflow.ellipsis))).toList();
                                                }(),
                                                onChanged: (val) {
                                                  setState(() => _selectedCategory = val);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        _buildResponsiveRow(
                                          isMobile,
                                          // Brand Dropdown
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Brand', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<String>(
                                                isExpanded: true,
                                                initialValue: (_selectedBrand != null && provider.brands.any((b) => b.name == _selectedBrand))
                                                    ? _selectedBrand
                                                    : (_selectedBrand != null && _selectedBrand!.isNotEmpty ? _selectedBrand : null),
                                                hint: const Text('Select Brand', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                                                decoration: const InputDecoration(isDense: true),
                                                items: () {
                                                  final items = provider.brands.map((b) => b.name).toSet().toList();
                                                  if (_selectedBrand != null && _selectedBrand!.isNotEmpty && !items.contains(_selectedBrand)) {
                                                    items.insert(0, _selectedBrand!);
                                                  }
                                                  return items.map((name) => DropdownMenuItem<String>(value: name, child: Text(name, overflow: TextOverflow.ellipsis))).toList();
                                                }(),
                                                onChanged: (val) {
                                                  setState(() => _selectedBrand = val);
                                                },
                                              ),
                                            ],
                                          ),
                                          // Unit Dropdown
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<String>(
                                                isExpanded: true,
                                                initialValue: (_selectedUnit != null && provider.units.any((u) => u.name == _selectedUnit))
                                                    ? _selectedUnit
                                                    : (_selectedUnit != null && _selectedUnit!.isNotEmpty ? _selectedUnit : null),
                                                hint: const Text('Choose Unit', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                                                decoration: const InputDecoration(isDense: true),
                                                items: () {
                                                  final items = provider.units.map((u) => u.name).toSet().toList();
                                                  if (_selectedUnit != null && _selectedUnit!.isNotEmpty && !items.contains(_selectedUnit)) {
                                                    items.insert(0, _selectedUnit!);
                                                  }
                                                  return items.map((name) => DropdownMenuItem<String>(value: name, child: Text(name, overflow: TextOverflow.ellipsis))).toList();
                                                }(),
                                                onChanged: (val) {
                                                  setState(() => _selectedUnit = val);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Status
                                        _buildResponsiveRow(
                                          isMobile,
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<String>(
                                                isExpanded: true,
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
                                        _buildResponsiveRow(
                                          isMobile,
                                          _buildInputField('Purchase Price (Cost)', _purchasePriceController, hint: '0.00'),
                                          _buildInputField('Selling Price', _sellingPriceController, hint: '0.00'),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildResponsiveRow(
                                          isMobile,
                                          _buildInputField('Tax (%)', _taxController, hint: '18'),
                                          _buildInputField('Discount', _discountController, hint: '5'),
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
                                        _buildResponsiveRow(
                                          isMobile,
                                          _buildInputField('Opening Stock (Read-only)', _openingStockController, readOnly: true),
                                          _buildInputField('Low Stock Alert', _lowStockAlertController, hint: '10'),
                                        ),
                                        const SizedBox(height: 16),
                                        // Warehouse Dropdown
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Warehouse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                            const SizedBox(height: 6),
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              value: _selectedWarehouseId,
                                              hint: const Text('Select Warehouse', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                                              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                              items: _warehouses.map<DropdownMenuItem<String>>((w) => DropdownMenuItem<String>(
                                                value: w['id'].toString(),
                                                child: Text(w['name']?.toString() ?? '', overflow: TextOverflow.ellipsis),
                                              )).toList(),
                                              onChanged: (val) => setState(() => _selectedWarehouseId = val),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isMobile) ...[
                                    const SizedBox(height: 20),
                                    _buildProductImageCard(),
                                    const SizedBox(height: 20),
                                    _buildQuickTipsCard(),
                                  ],
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
                                    _buildProductImageCard(),
                                    const SizedBox(height: 20),
                                    _buildQuickTipsCard(),
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

  Widget _buildResponsiveRow(bool isMobile, Widget first, [Widget? second]) {
    if (isMobile || second == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          first,
          if (second != null) ...[
            const SizedBox(height: 16),
            second,
          ],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second),
      ],
    );
  }

  Widget _buildProductImageCard() {
    return _buildCardContainer(
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
    );
  }

  Widget _buildQuickTipsCard() {
    return _buildCardContainer(
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
