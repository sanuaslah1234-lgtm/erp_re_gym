import 'package:flutter/material.dart';
import 'package:erp_software/core/models/unit_model.dart';
import 'package:erp_software/core/utils/export_print_helper.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

enum UnitSortOption {
  nameAsc,
  nameDesc,
  symbolAsc,
  productCountDesc,
  activeFirst,
}

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  bool _showAddSection = false;
  UnitModel? _editingUnit;

  final TextEditingController _unitNameController = TextEditingController();
  final TextEditingController _shortSymbolController = TextEditingController();
  String _selectedStatus = 'Active';
  String _searchQuery = '';
  UnitSortOption _sortOption = UnitSortOption.nameAsc;

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
    _unitNameController.dispose();
    _shortSymbolController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _unitNameController.clear();
    _shortSymbolController.clear();
    _selectedStatus = 'Active';
    _editingUnit = null;
  }

  void _startEdit(UnitModel unit) {
    setState(() {
      _editingUnit = unit;
      _unitNameController.text = unit.name;
      _shortSymbolController.text = unit.shortSymbol;
      _selectedStatus = unit.status.toLowerCase() == 'active' ? 'Active' : 'Inactive';
      _showAddSection = true;
    });
  }

  void _handleSaveUnit(ProductManagementProvider provider, AuthProvider authProvider) async {
    final name = _unitNameController.text.trim();
    final symbol = _shortSymbolController.text.trim();

    if (name.isEmpty) {
      ErpToast.showError(context, 'Unit Name is required!');
      return;
    }
    if (symbol.isEmpty) {
      ErpToast.showError(context, 'Short Code / Symbol is required!');
      return;
    }

    final unitData = UnitModel(
      id: _editingUnit?.id,
      name: name,
      shortSymbol: symbol,
      status: _selectedStatus.toLowerCase(),
    );

    if (_editingUnit != null && _editingUnit!.id != null) {
      await provider.updateUnit(authProvider.token, _editingUnit!.id!, unitData);
      if (mounted) {
        ErpToast.showSuccess(context, 'Measurement unit updated successfully!');
      }
    } else {
      await provider.addUnit(authProvider.token, unitData);
      if (mounted) {
        ErpToast.showSuccess(context, 'Measurement unit created successfully!');
      }
    }

    _resetForm();
    setState(() {
      _showAddSection = false;
    });
  }

  List<UnitModel> _getSortedAndFilteredUnits(List<UnitModel> units) {
    final filtered = units.where((u) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(q) || u.shortSymbol.toLowerCase().contains(q);
    }).toList();

    switch (_sortOption) {
      case UnitSortOption.nameAsc:
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case UnitSortOption.nameDesc:
        filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case UnitSortOption.symbolAsc:
        filtered.sort((a, b) => a.shortSymbol.toLowerCase().compareTo(b.shortSymbol.toLowerCase()));
        break;
      case UnitSortOption.productCountDesc:
        filtered.sort((a, b) => b.productCount.compareTo(a.productCount));
        break;
      case UnitSortOption.activeFirst:
        filtered.sort((a, b) {
          final aActive = a.status.toLowerCase() == 'active' ? 0 : 1;
          final bActive = b.status.toLowerCase() == 'active' ? 0 : 1;
          return aActive.compareTo(bActive);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    final displayedUnits = _getSortedAndFilteredUnits(provider.units);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Units of Measure', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Units of Measure'),
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
                              'Units of Measure',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ExportPrintHelper.showPrintPage(
                                      context: context,
                                      title: 'Units of Measure',
                                      headers: ['Unit Name', 'Short Symbol', 'No of Products', 'Status'],
                                      rows: displayedUnits
                                          .map((u) => [
                                                u.name,
                                                u.shortSymbol,
                                                u.productCount.toString().padLeft(2, '0'),
                                                u.status.toUpperCase()
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
                                      filename: 'units_of_measure',
                                      headers: ['Unit Name', 'Short Symbol', 'No of Products', 'Status'],
                                      rows: displayedUnits
                                          .map((u) => [u.name, u.shortSymbol, u.productCount, u.status])
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
                                      if (_showAddSection && _editingUnit != null) {
                                        _resetForm();
                                      } else {
                                        _showAddSection = !_showAddSection;
                                        if (!_showAddSection) _resetForm();
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add New Unit'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Inline Add / Edit Measurement Unit Section Card
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
                                      children: [
                                        Text(
                                          _editingUnit != null ? 'Edit Measurement Unit' : 'Add Measurement Unit',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _editingUnit != null
                                              ? 'Update details for this measurement unit'
                                              : 'Create a new measurement unit (e.g. Kilogram, Pieces, Litre)',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                                      onPressed: () {
                                        setState(() {
                                          _showAddSection = false;
                                          _resetForm();
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
                                      width: isMobile ? double.infinity : 280,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Unit Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                          const SizedBox(height: 6),
                                          TextField(
                                            controller: _unitNameController,
                                            decoration: const InputDecoration(
                                              hintText: 'Example: Kilogram',
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
                                          const Text('Short Code / Symbol *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                          const SizedBox(height: 6),
                                          TextField(
                                            controller: _shortSymbolController,
                                            decoration: const InputDecoration(
                                              hintText: 'Example: kg',
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
                                          _resetForm();
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _handleSaveUnit(provider, authProvider),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F172A),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      ),
                                      icon: const Icon(Icons.save_outlined, size: 18),
                                      label: Text(_editingUnit != null ? 'Update Unit' : 'Save Unit'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Main Units Data Table Card
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
                                            hintText: 'Search units...',
                                            prefixIcon: Icon(Icons.search, size: 18),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<UnitSortOption>(
                                      onSelected: (option) {
                                        setState(() {
                                          _sortOption = option;
                                        });
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: UnitSortOption.nameAsc,
                                          child: Text('Sort by Name (A-Z)'),
                                        ),
                                        PopupMenuItem(
                                          value: UnitSortOption.nameDesc,
                                          child: Text('Sort by Name (Z-A)'),
                                        ),
                                        PopupMenuItem(
                                          value: UnitSortOption.symbolAsc,
                                          child: Text('Sort by Symbol (A-Z)'),
                                        ),
                                        PopupMenuItem(
                                          value: UnitSortOption.productCountDesc,
                                          child: Text('Sort by No of Products'),
                                        ),
                                        PopupMenuItem(
                                          value: UnitSortOption.activeFirst,
                                          child: Text('Sort by Active First'),
                                        ),
                                      ],
                                      child: OutlinedButton.icon(
                                        onPressed: null, // PopupMenuButton handles tap
                                        icon: const Icon(Icons.arrow_downward, size: 14),
                                        label: const Text('Sort By'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          foregroundColor: const Color(0xFF334155),
                                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
                                      tooltip: 'Refresh Units',
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
                                      DataColumn(label: Text('Unit Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      DataColumn(label: Text('Short Symbol', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      DataColumn(label: Text('No of Products', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                    ],
                                    rows: displayedUnits.map((u) {
                                      final isActive = u.status.toLowerCase() == 'active';
                                      return DataRow(cells: [
                                        DataCell(Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                        DataCell(Text(u.shortSymbol, style: const TextStyle(color: Color(0xFF64748B)))),
                                        DataCell(Text(u.productCount.toString().padLeft(2, '0'), style: const TextStyle(color: Color(0xFF64748B)))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              u.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                                            onSelected: (val) {
                                              if (val == 'edit') {
                                                _startEdit(u);
                                              } else if (val == 'delete') {
                                                if (u.id != null) {
                                                  provider.deleteUnit(authProvider.token, u.id!);
                                                  ErpToast.showSuccess(context, 'Unit deleted successfully');
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
