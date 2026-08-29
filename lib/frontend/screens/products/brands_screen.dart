import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/brand_model.dart';
import 'package:erp_software/core/utils/export_print_helper.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  int? _editingBrandId;

  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedStatus = 'Active';
  String _searchQuery = '';

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
  void dispose() {
    _brandNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _brandNameController.clear();
    _descriptionController.clear();
    _selectedStatus = 'Active';
    _editingBrandId = null;
  }

  void _openRightSideBrandForm({BrandModel? editBrand}) {
    if (editBrand != null) {
      _editingBrandId = editBrand.id;
      _brandNameController.text = editBrand.name;
      _descriptionController.text = editBrand.description ?? '';
      _selectedStatus = editBrand.status.toLowerCase() == 'inactive' ? 'Inactive' : 'Active';
    } else {
      _resetForm();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        final provider = Provider.of<ProductManagementProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isMobile = MediaQuery.of(context).size.width < 800;

        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 440,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 16, spreadRadius: 4),
                ],
              ),
              child: StatefulBuilder(
                builder: (panelContext, setPanelState) {
                  return Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  editBrand != null ? 'Edit Brand' : 'Add New Brand',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  editBrand != null ? 'Update product brand details' : 'Create a new product brand',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                              onPressed: () {
                                _resetForm();
                                Navigator.pop(dialogContext);
                              },
                            ),
                          ],
                        ),
                      ),

                      // Form Body
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Brand Name
                              const Text('Brand Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _brandNameController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. Apple',
                                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Status Dropdown
                              const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedStatus,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                                  isDense: true,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setPanelState(() => _selectedStatus = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

                              // Description
                              const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _descriptionController,
                                maxLines: 4,
                                maxLength: 500,
                                onChanged: (val) => setPanelState(() {}),
                                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                                decoration: InputDecoration(
                                  hintText: 'Enter brand description',
                                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_descriptionController.text.length}/500',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Footer Action Buttons
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _resetForm();
                                  Navigator.pop(dialogContext);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final name = _brandNameController.text.trim();
                                  final desc = _descriptionController.text.trim();

                                  if (name.isEmpty) {
                                    ErpToast.showError(dialogContext, 'Brand Name is required!');
                                    return;
                                  }

                                  final brandData = BrandModel(
                                    id: _editingBrandId,
                                    name: name,
                                    description: desc.isNotEmpty ? desc : null,
                                    status: _selectedStatus.toLowerCase(),
                                  );

                                  if (_editingBrandId != null) {
                                    await provider.updateBrand(authProvider.token, _editingBrandId!, brandData);
                                    if (dialogContext.mounted) {
                                      ErpToast.showSuccess(dialogContext, 'Product brand updated successfully!');
                                    }
                                  } else {
                                    await provider.addBrand(authProvider.token, brandData);
                                    if (dialogContext.mounted) {
                                      ErpToast.showSuccess(dialogContext, 'Product brand created successfully!');
                                    }
                                  }

                                  _resetForm();
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.save_outlined, size: 18),
                                label: Text(editBrand != null ? 'Update Brand' : 'Save Brand'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final filteredBrands = provider.brands.where((b) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.name.toLowerCase().contains(q) || (b.description != null && b.description!.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Brands', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Brands'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Header
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Brands',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Manage your product brands',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          ExportPrintHelper.showPrintPage(
                                            context: context,
                                            title: 'Brands',
                                            headers: ['Brand', 'Description', 'No of Products', 'Status'],
                                            rows: filteredBrands
                                                .map((b) => [b.name, b.description ?? '', b.productCount.toString().padLeft(2, '0'), b.status.toUpperCase()])
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
                                            filename: 'brands_export',
                                            headers: ['Brand', 'Description', 'No of Products', 'Status'],
                                            rows: filteredBrands
                                                .map((b) => [b.name, b.description ?? '', b.productCount, b.status])
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
                                        onPressed: () => _openRightSideBrandForm(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0F172A),
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
                              );
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Brands',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Manage your product brands',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        ExportPrintHelper.showPrintPage(
                                          context: context,
                                          title: 'Brands',
                                          headers: ['Brand', 'Description', 'No of Products', 'Status'],
                                          rows: filteredBrands
                                              .map((b) => [b.name, b.description ?? '', b.productCount.toString().padLeft(2, '0'), b.status.toUpperCase()])
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
                                          filename: 'brands_export',
                                          headers: ['Brand', 'Description', 'No of Products', 'Status'],
                                          rows: filteredBrands
                                              .map((b) => [b.name, b.description ?? '', b.productCount, b.status])
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
                                      onPressed: () => _openRightSideBrandForm(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F172A),
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
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Main Brands Data Table Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            children: [
                              // Search & Count Bar
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: isMobile ? 180 : 260,
                                      child: TextField(
                                        onChanged: (val) {
                                          setState(() {
                                            _searchQuery = val;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Search brands...',
                                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFC),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${filteredBrands.length} Brand${filteredBrands.length == 1 ? '' : 's'}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
                                      onPressed: () => provider.loadAllData(authProvider.token),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),

                              // Data Table
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final availableW = (constraints.maxWidth.isFinite && constraints.maxWidth > 0) ? constraints.maxWidth : 850.0;
                                  final minWidth = isMobile ? 750.0 : math.max(availableW, 750.0);
                                  final contentW = math.max(minWidth - 104.0, 600.0);
                                  final colBrandW = isMobile ? 140.0 : contentW * 0.22;
                                  final colDescW = isMobile ? 220.0 : contentW * 0.38;
                                  final colProdW = isMobile ? 120.0 : contentW * 0.16;
                                  final colStatusW = isMobile ? 100.0 : contentW * 0.14;
                                  final colActionW = isMobile ? 70.0 : contentW * 0.10;

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: minWidth,
                                      child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                        horizontalMargin: 20,
                                        columnSpacing: 16,
                                        columns: [
                                          DataColumn(label: SizedBox(width: colBrandW, child: const Text('Brand', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))),
                                          DataColumn(label: SizedBox(width: colDescW, child: const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))),
                                          DataColumn(label: SizedBox(width: colProdW, child: const Text('No of Products', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))),
                                          DataColumn(label: SizedBox(width: colStatusW, child: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))),
                                          DataColumn(label: SizedBox(width: colActionW, child: const Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))),
                                        ],
                                        rows: filteredBrands.map((b) {
                                          final isActive = b.status.toLowerCase() == 'active';
                                          final descText = (b.description != null && b.description!.trim().isNotEmpty) ? b.description! : '—';
                                          final prodCountStr = b.productCount.toString().padLeft(2, '0');

                                          return DataRow(cells: [
                                            DataCell(SizedBox(width: colBrandW, child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis))),
                                            DataCell(SizedBox(width: colDescW, child: Text(descText, style: const TextStyle(color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis))),
                                            DataCell(SizedBox(width: colProdW, child: Text(prodCountStr, style: const TextStyle(color: Color(0xFF64748B))))),
                                            DataCell(
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    b.status.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              PopupMenuButton<String>(
                                                icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                                                onSelected: (val) async {
                                                  if (val == 'edit') {
                                                    _openRightSideBrandForm(editBrand: b);
                                                  } else if (val == 'delete') {
                                                    if (b.id != null) {
                                                      await provider.deleteBrand(authProvider.token, b.id!);
                                                      if (context.mounted) {
                                                        ErpToast.showSuccess(context, 'Brand deleted successfully');
                                                      }
                                                    }
                                                  }
                                                },
                                                itemBuilder: (_) => [
                                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                                ],
                                              ),
                                            ),
                                          ]);
                                        }).toList(),
                                      ),
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
}
