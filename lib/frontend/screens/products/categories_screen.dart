import 'package:flutter/material.dart';
import 'package:erp_software/core/models/category_model.dart';
import 'package:erp_software/core/utils/export_print_helper.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _showAddSection = false;

  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categorySlugController = TextEditingController();
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
    _categoryNameController.dispose();
    _categorySlugController.dispose();
    super.dispose();
  }

  void _handleSaveCategory(ProductManagementProvider provider, AuthProvider authProvider) async {
    final name = _categoryNameController.text.trim();
    final slug = _categorySlugController.text.trim();

    if (name.isEmpty) {
      ErpToast.showError(context, 'Category Name is required!');
      return;
    }

    final category = CategoryModel(
      name: name,
      description: slug.isNotEmpty ? slug : name.toLowerCase().replaceAll(' ', '-'),
      status: _selectedStatus.toLowerCase(),
    );

    await provider.addCategory(authProvider.token, category);

    _categoryNameController.clear();
    _categorySlugController.clear();
    setState(() {
      _showAddSection = false;
    });

    if (mounted) {
      ErpToast.showSuccess(context, 'Product category created successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    final filteredCategories = provider.categories.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || (c.description != null && c.description!.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Categories', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Categories'),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage your product categories',
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
                                      title: 'Categories',
                                      headers: ['Category', 'Category Slug', 'No of Products', 'Status'],
                                      rows: filteredCategories
                                          .map((c) => [c.name, c.description ?? c.name.toLowerCase(), c.productCount.toString(), c.status.toUpperCase()])
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
                                      filename: 'categories_export',
                                      headers: ['Category', 'Category Slug', 'No of Products', 'Status'],
                                      rows: filteredCategories
                                          .map((c) => [c.name, c.description ?? c.name.toLowerCase(), c.productCount, c.status])
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
                                  onPressed: () {
                                    setState(() {
                                      _showAddSection = !_showAddSection;
                                    });
                                  },
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
                        ),
                        const SizedBox(height: 20),

                        // Inline Add New Category Section
                        if (_showAddSection) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Add New Category',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Create a new product category',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                                      onPressed: () {
                                        setState(() {
                                          _showAddSection = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: isMobile ? double.infinity : 260,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Category Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                          const SizedBox(height: 6),
                                          TextField(
                                            controller: _categoryNameController,
                                            onChanged: (val) {
                                              _categorySlugController.text = val.toLowerCase().replaceAll(' ', '-');
                                            },
                                            decoration: const InputDecoration(
                                              hintText: 'e.g. Smartphones',
                                              isDense: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: isMobile ? double.infinity : 240,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Category Slug *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                          const SizedBox(height: 6),
                                          TextField(
                                            controller: _categorySlugController,
                                            decoration: const InputDecoration(
                                              hintText: 'e.g. smartphones',
                                              isDense: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: isMobile ? double.infinity : 180,
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
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _showAddSection = false;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _handleSaveCategory(provider, authProvider),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F172A),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      ),
                                      icon: const Icon(Icons.save_outlined, size: 18),
                                      label: const Text('Save Category'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Main Categories Data Table Card
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
                              // Search & Actions Bar inside Card
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: const BoxConstraints(maxWidth: 300),
                                        child: TextField(
                                          onChanged: (val) {
                                            setState(() {
                                              _searchQuery = val;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            hintText: 'Search...',
                                            prefixIcon: Icon(Icons.search, size: 18),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
                                      onPressed: () => provider.loadAllData(authProvider.token),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),

                              // Table
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: isMobile ? 800 : null,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                    columns: const [
                                      DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      DataColumn(label: Text('Category Slug', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      DataColumn(label: Text('No of Products', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                    ],
                                    rows: filteredCategories.map((c) {
                                      return DataRow(cells: [
                                        DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                        DataCell(Text(c.description ?? c.name.toLowerCase(), style: const TextStyle(color: Color(0xFF64748B)))),
                                        DataCell(Text(c.productCount.toString(), style: const TextStyle(color: Color(0xFF64748B)))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD1FAE5),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              c.status.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF10B981),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                                            onSelected: (val) {
                                              if (val == 'delete') {
                                                provider.deleteCategory(authProvider.token, c.id!);
                                                ErpToast.showSuccess(context, 'Category deleted successfully');
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
                              ),

                              // Bottom Pagination
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    const Text('Showing ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        children: [
                                          Text('10 / Pages', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                                          Icon(Icons.keyboard_arrow_down, size: 14),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left, size: 18)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right, size: 18)),
                                  ],
                                ),
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
