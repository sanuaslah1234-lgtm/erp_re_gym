import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/config/app_config.dart';
import 'package:erp_software/core/models/inventory_model.dart';
import 'package:erp_software/frontend/services/inventory_service.dart';
import 'package:erp_software/frontend/screens/products/widgets/stock_movement_dialog.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/frontend/widgets/inventory/inventory_stats.dart';
import 'package:erp_software/frontend/widgets/inventory/inventory_filters.dart';
import 'package:erp_software/theme/app_colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<InventoryModel> _items = [];
  bool _isLoading = true;
  String? _error;

  String _search = '';
  String? _selectedWarehouseId;
  String _selectedStatus = 'All Statuses';
  String _selectedSort = 'Latest';
  List<Map<String, String>> _warehouses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWarehouses();
      _loadInventory();
    });
  }

  Future<void> _loadInventory() async {
    final isFirstLoad = _items.isEmpty && _error == null;
    if (isFirstLoad) {
      setState(() { _isLoading = true; _error = null; });
    }

    try {
      final items = await _inventoryService.getInventory(
        search: _search.isNotEmpty ? _search : null,
        warehouseId: _selectedWarehouseId,
        status: _selectedStatus != 'All Statuses' ? _selectedStatus : null,
      );
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        if (isFirstLoad) {
          setState(() {
            _error = e.toString().replaceAll('Exception: ', '');
            _isLoading = false;
          });
        } else {
          _isLoading = false;
          setState(() {});
          ErpToast.showError(context, 'Failed to refresh inventory: ${e.toString().replaceAll('Exception: ', '')}');
        }
      }
    }
  }

  Future<void> _loadWarehouses() async {
    try {
      final res = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/warehouses'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data = decoded is List ? decoded : (decoded is Map ? (decoded['data'] ?? []) : []);
        if (mounted) {
          setState(() {
            _warehouses = data.map<Map<String, String>>((e) => {'id': e['id'].toString(), 'name': (e['name'] ?? '').toString()}).toList();
          });
        }
      }
    } catch (_) {}
  }

  List<InventoryModel> get _filteredItems {
    var list = List<InventoryModel>.from(_items);
    switch (_selectedSort) {
      case 'A-Z':
        list.sort((a, b) => a.product.compareTo(b.product));
        break;
      case 'Z-A':
        list.sort((a, b) => b.product.compareTo(a.product));
        break;
      case 'Quantity Low':
        list.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'Quantity High':
        list.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      default:
        break;
    }
    return list;
  }

  void _showStockAdjustmentDialog() {
    showDialog(
      context: context,
      builder: (_) => const StockMovementDialog(),
    ).then((_) => _loadInventory());
  }

  void _showAddStockDialog(InventoryModel item) {
    final qtyCtrl = TextEditingController(text: '0');
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Stock: ${item.product}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 20),
              Text('Current stock: ${item.quantity}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity to Add *', border: OutlineInputBorder(), isDense: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Reason', hintText: 'e.g. New shipment received', border: OutlineInputBorder(), isDense: true),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final qty = int.tryParse(qtyCtrl.text) ?? 0;
                    if (qty <= 0) { ErpToast.showError(ctx, 'Quantity must be greater than 0'); return; }
                    try {
                      final wid = item.warehouseId.isNotEmpty && item.warehouseId != 'default'
                          ? item.warehouseId
                          : (_selectedWarehouseId ?? '1');
                      if (item.id == '0' || item.id.isEmpty) {
                        // Create inventory first, then add stock
                        await _inventoryService.createInventory(
                          productId: item.productId.toString(),
                          warehouseId: wid,
                          quantity: qty,
                          minStock: 10,
                          maxStock: 1000,
                          reorderLevel: 20,
                        );
                      } else {
                        await _inventoryService.updateQuantity(id: item.id, quantity: item.quantity + qty);
                      }
                      if (!mounted) return;
                      if (ctx.mounted) Navigator.pop(ctx);
                      ErpToast.showSuccess(context, 'Stock updated: +$qty for ${item.product}');
                      _loadInventory();
                    } catch (e) {
                      if (!mounted) return;
                      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Stock'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddInventoryDialog() async {
    // Fetch products, warehouses, and existing inventory
    List<Map<String, dynamic>> products = [];
    List<Map<String, dynamic>> warehouses = [];
    try {
      final resProd = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/products'));
      if (resProd.statusCode == 200) {
        final decoded = jsonDecode(resProd.body);
        final List data = decoded is List ? decoded : (decoded is Map ? (decoded['data'] ?? []) : []);
        products = data.map<Map<String, dynamic>>((e) => {'id': e['id'].toString(), 'name': (e['name'] ?? '').toString()}).toList();
      }
    } catch (_) {}
    try {
      final resWh = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/warehouses'));
      if (resWh.statusCode == 200) {
        final decoded = jsonDecode(resWh.body);
        final List data = decoded is List ? decoded : (decoded is Map ? (decoded['data'] ?? []) : []);
        warehouses = data.map<Map<String, dynamic>>((e) => {'id': e['id'].toString(), 'name': (e['name'] ?? '').toString()}).toList();
      }
    } catch (_) {}
    if (!mounted) return;

    String? selectedProductId;
    String? selectedWarehouseId;
    final qtyCtrl = TextEditingController(text: '0');
    final minCtrl = TextEditingController(text: '10');
    final maxCtrl = TextEditingController(text: '1000');
    final reorderCtrl = TextEditingController(text: '20');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Inventory Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(height: 20),
                // Product dropdown
                const Text('Product *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedProductId,
                  isExpanded: true,
                  isDense: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  hint: const Text('Select Product'),
                  items: products.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(value: p['id']!, child: Text(p['name']!, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setDialogState(() => selectedProductId = v),
                ),
                const SizedBox(height: 12),
                // Warehouse dropdown
                const Text('Warehouse *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedWarehouseId,
                  isExpanded: true,
                  isDense: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  hint: const Text('Select Warehouse'),
                  items: warehouses.map<DropdownMenuItem<String>>((w) => DropdownMenuItem<String>(value: w['id']!, child: Text(w['name']!, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setDialogState(() => selectedWarehouseId = v),
                ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                            isDense: true))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Min Stock',
                            border: OutlineInputBorder(),
                            isDense: true))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Max Stock',
                            border: OutlineInputBorder(),
                            isDense: true))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: reorderCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Reorder Level',
                            border: OutlineInputBorder(),
                            isDense: true))),
              ]),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (selectedProductId == null || selectedWarehouseId == null) {
                      ErpToast.showWarning(ctx, 'Please select a product and warehouse');
                      return;
                    }
                    try {
                      await _inventoryService.createInventory(
                        productId: selectedProductId!,
                        warehouseId: selectedWarehouseId!,
                        quantity: int.tryParse(qtyCtrl.text) ?? 0,
                        minStock: int.tryParse(minCtrl.text) ?? 10,
                        maxStock: int.tryParse(maxCtrl.text) ?? 1000,
                        reorderLevel: int.tryParse(reorderCtrl.text) ?? 20,
                      );
                      if (!mounted) return;
                      if (ctx.mounted) Navigator.pop(ctx);
                      ErpToast.showSuccess(context, 'Inventory record created');
                      _loadInventory();
                    } catch (e) {
                      if (!mounted) return;
                      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  void _showEditDialog(InventoryModel item) {
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final minCtrl = TextEditingController(text: item.minimumStock.toString());
    final maxCtrl = TextEditingController(text: item.maximumStock.toString());
    final reorderCtrl = TextEditingController(text: item.reorderLevel.toString());

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit: ${item.product}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 20),
              TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      isDense: true)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Min Stock',
                            border: OutlineInputBorder(),
                            isDense: true))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Max Stock',
                            border: OutlineInputBorder(),
                            isDense: true))),
              ]),
              const SizedBox(height: 12),
              TextField(
                  controller: reorderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Reorder Level',
                      border: OutlineInputBorder(),
                      isDense: true)),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      if (item.id == '0' || item.id.isEmpty) {
                        await _inventoryService.createInventory(
                          productId: item.productId.toString(),
                          warehouseId: '1',
                          quantity: int.tryParse(qtyCtrl.text) ?? 0,
                          minStock: int.tryParse(minCtrl.text) ?? 10,
                          maxStock: int.tryParse(maxCtrl.text) ?? 1000,
                          reorderLevel: int.tryParse(reorderCtrl.text) ?? 20,
                        );
                      } else {
                        await _inventoryService.updateInventory(
                          id: item.id,
                          productId: item.productId,
                          warehouseId: item.warehouseId,
                          quantity: int.tryParse(qtyCtrl.text) ?? item.quantity,
                          minStock: int.tryParse(minCtrl.text) ?? item.minimumStock,
                          maxStock: int.tryParse(maxCtrl.text) ?? item.maximumStock,
                          reorderLevel: int.tryParse(reorderCtrl.text) ?? item.reorderLevel,
                        );
                      }
                      if (!mounted) return;
                      if (ctx.mounted) Navigator.pop(ctx);
                      ErpToast.showSuccess(context, 'Inventory saved');
                      _loadInventory();
                    } catch (e) {
                      if (!mounted) return;
                      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
                    }
                  },
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(InventoryModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Inventory Record'),
        content: Text('Remove inventory for "${item.product}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                if (item.id == '0' || item.id.isEmpty) {
                  Navigator.pop(ctx);
                  ErpToast.showInfo(context, '${item.product} has no inventory record yet. Use Add Stock or Edit to create one.');
                  return;
                }
                await _inventoryService.deleteInventory(item.id);
                if (!mounted) return;
                if (ctx.mounted) Navigator.pop(ctx);
                ErpToast.showSuccess(context, 'Inventory record deleted');
                _loadInventory();
              } catch (e) {
                if (!mounted) return;
                ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
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
                SizedBox(width: 180, child: Text('PRODUCT', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('SKU', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 140, child: Text('WAREHOUSE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 80, child: Text('QTY', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('MIN / MAX', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 80, child: Text('STATUS', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 160, child: Text('ACTION', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...List.generate(_filteredItems.length, (index) {
              final item = _filteredItems[index];
              final isLast = index == _filteredItems.length - 1;
              final isOut = item.status == 'Out of Stock';
              final isLow = item.status == 'Low Stock';
              final statusColor = isOut ? AppColors.danger : (isLow ? AppColors.warning : AppColors.success);
              final statusBg = isOut ? AppColors.dangerLight : (isLow ? AppColors.warningLight : AppColors.successLight);
              return Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight))),
                child: Row(children: [
                  SizedBox(width: 180, child: Text(item.product, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 100, child: Text(item.sku ?? '-', style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 140, child: Text(item.warehouse, style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 80, child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                  SizedBox(width: 100, child: Text('${item.minimumStock} / ${item.maximumStock}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                  SizedBox(width: 80, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(item.status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor)),
                  )),
                  SizedBox(width: 160, child: Row(children: [
                    _actionBtn(Icons.add_circle_outline, 'Add Stock', () => _showAddStockDialog(item), AppColors.success),
                    const SizedBox(width: 4),
                    _actionBtn(Icons.edit_outlined, 'Edit', () => _showEditDialog(item), AppColors.primary),
                    const SizedBox(width: 4),
                    _actionBtn(Icons.delete_outline, 'Delete', () => _showDeleteConfirmation(item), AppColors.danger),
                  ])),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap, Color color) {
    return Tooltip(
      message: label,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(7),
          child: SizedBox(width: 28, height: 28, child: Icon(icon, size: 14, color: color)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalRecords = _filteredItems.length;
    final healthyStock = _filteredItems.where((i) => i.status == 'In Stock').length;
    final lowStock = _filteredItems.where((i) => i.status == 'Low Stock').length;
    final outOfStock = _filteredItems.where((i) => i.status == 'Out of Stock').length;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Inventory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Header
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Inventory / Stock',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            const Text('Manage stock levels, adjustments, and audit trail',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _showStockAdjustmentDialog,
                                    icon: const Icon(Icons.swap_horiz, size: 16),
                                    label: const Text('Stock Adjust'),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.warningDark,
                                        side: const BorderSide(color: AppColors.warning),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _showAddInventoryDialog,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add Stock'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stats
                        InventoryStats(
                          totalRecords: totalRecords,
                          healthyStock: healthyStock,
                          lowStock: lowStock,
                          outOfStock: outOfStock,
                        ),
                        const SizedBox(height: 20),

                        // Filters
                        InventoryFilters(
                          search: _search,
                          selectedWarehouseId: _selectedWarehouseId,
                          selectedStatus: _selectedStatus,
                          selectedSort: _selectedSort,
                          warehouses: _warehouses,
                          onSearchChanged: (val) {
                            _search = val;
                            _loadInventory();
                          },
                          onWarehouseChanged: (val) {
                            _selectedWarehouseId = val;
                            _loadInventory();
                          },
                          onStatusChanged: (val) {
                            _selectedStatus = val ?? 'All Statuses';
                            _loadInventory();
                          },
                          onSortChanged: (val) {
                            _selectedSort = val ?? 'Latest';
                            setState(() {});
                          },
                          onRefresh: _loadInventory,
                        ),
                        const SizedBox(height: 20),

                        // Content
                        if (_isLoading)
                          const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator()))
                        else if (_error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                                color: AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.danger)),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
                                const SizedBox(height: 12),
                                Text(_error!,
                                    style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                    onPressed: _loadInventory,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry')),
                              ],
                            ),
                          )
                        else
                          _buildInventoryTable(),
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
