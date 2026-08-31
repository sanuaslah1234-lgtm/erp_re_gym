import 'package:flutter/material.dart';
import 'package:erp_software/core/models/warehouse_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/services/warehouse/warehouse_api_service.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:provider/provider.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final WarehouseApiService _api = WarehouseApiService();
  List<WarehouseModel> _warehouses = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      _warehouses = await _api.fetchWarehouses(token);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }
    if (mounted) setState(() { _isLoading = false; });
  }

  List<WarehouseModel> get _filtered {
    if (_search.isEmpty) return _warehouses;
    final q = _search.toLowerCase();
    return _warehouses.where((w) => w.name.toLowerCase().contains(q) || (w.code?.toLowerCase().contains(q) ?? false)).toList();
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Add Warehouse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ]),
              const Divider(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Warehouse Name *', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code', hintText: 'Auto-generated if empty', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) { ErpToast.showError(ctx, 'Warehouse name is required'); return; }
                    try {
                      final token = Provider.of<AuthProvider>(context, listen: false).token;
                      await _api.createWarehouse(token, WarehouseModel(id: '', name: nameCtrl.text.trim(), code: codeCtrl.text.trim().isEmpty ? null : codeCtrl.text.trim(), address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(), phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim()));
                      if (!mounted) return;
                      if (ctx.mounted) Navigator.pop(ctx);
                      ErpToast.showSuccess(context, 'Warehouse created');
                      _load();
                    } catch (e) {
                      if (!mounted) return;
                      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
                    }
                  },
                  icon: const Icon(Icons.add, size: 16), label: const Text('Create'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(WarehouseModel wh) {
    final nameCtrl = TextEditingController(text: wh.name);
    final codeCtrl = TextEditingController(text: wh.code ?? '');
    final addressCtrl = TextEditingController(text: wh.address ?? '');
    final phoneCtrl = TextEditingController(text: wh.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Edit Warehouse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ]),
              const Divider(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Warehouse Name *', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) { ErpToast.showError(ctx, 'Warehouse name is required'); return; }
                    try {
                      final token = Provider.of<AuthProvider>(context, listen: false).token;
                      await _api.updateWarehouse(token, wh.id, WarehouseModel(id: wh.id, name: nameCtrl.text.trim(), code: codeCtrl.text.trim().isEmpty ? null : codeCtrl.text.trim(), address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(), phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim()));
                      if (!mounted) return;
                      if (ctx.mounted) Navigator.pop(ctx);
                      ErpToast.showSuccess(context, 'Warehouse updated');
                      _load();
                    } catch (e) {
                      if (!mounted) return;
                      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
                    }
                  },
                  icon: const Icon(Icons.save, size: 16), label: const Text('Save'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(WarehouseModel wh) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Warehouse'),
        content: Text('Delete "${wh.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final token = Provider.of<AuthProvider>(context, listen: false).token;
                await _api.deleteWarehouse(token, wh.id);
                if (!mounted) return;
                if (ctx.mounted) Navigator.pop(ctx);
                ErpToast.showSuccess(context, 'Warehouse deleted');
                _load();
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile ? Drawer(child: ErpSidebar(activeItem: 'Warehouse Management', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Warehouse Management'),
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
                                Text('Warehouse Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                SizedBox(height: 4),
                                Text('Manage warehouses and storage locations', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _showAddDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Warehouse'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats
                        Row(children: [
                          _statCard('Total', '${_warehouses.length}', Icons.warehouse_outlined, AppColors.primary, AppColors.primarySoft),
                          const SizedBox(width: 16),
                          _statCard('Active', '${_warehouses.where((w) => w.isActive).length}', Icons.check_circle_outline, AppColors.success, AppColors.successLight),
                          const SizedBox(width: 16),
                          _statCard('Inactive', '${_warehouses.where((w) => !w.isActive).length}', Icons.pause_circle_outline, AppColors.warning, AppColors.warningLight),
                        ]),
                        const SizedBox(height: 20),
                        // Search
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
                          child: Row(children: [
                            Expanded(child: TextField(onChanged: (v) => setState(() => _search = v), decoration: InputDecoration(hintText: 'Search warehouses...', prefixIcon: const Icon(Icons.search, size: 18), isDense: true, filled: true, fillColor: AppColors.surfaceSecondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
                            const SizedBox(width: 8),
                            Text('${_filtered.length} warehouse${_filtered.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.refresh, color: AppColors.textSecondary), onPressed: _load),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        // Content
                        if (_isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                        else if (_error != null)
                          _buildError()
                        else if (_filtered.isEmpty)
                          _buildEmpty()
                        else
                          _buildTable(),
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

  Widget _buildError() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.danger)),
      child: Column(children: [
        const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        const Icon(Icons.warehouse_outlined, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 14),
        const Text('No warehouses found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 5),
        const Text('Create your first warehouse to get started.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 800,
          child: Column(children: [
            Container(
              height: 44, padding: const EdgeInsets.symmetric(horizontal: 20), color: AppColors.surfaceSecondary,
              child: const Row(children: [
                SizedBox(width: 180, child: Text('NAME', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('CODE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                Expanded(child: Text('ADDRESS', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 120, child: Text('PHONE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 80, child: Text('STATUS', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 80, child: Text('ACTION', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...List.generate(_filtered.length, (index) {
              final wh = _filtered[index];
              final isLast = index == _filtered.length - 1;
              return Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight))),
                child: Row(children: [
                  SizedBox(width: 180, child: Text(wh.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 100, child: Text(wh.code ?? '-', style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  Expanded(child: Text(wh.address ?? '-', style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 120, child: Text(wh.phone ?? '-', style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 80, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: wh.isActive ? AppColors.successLight : AppColors.neutralLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(wh.isActive ? 'ACTIVE' : 'INACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: wh.isActive ? AppColors.success : AppColors.neutral)),
                  )),
                  SizedBox(width: 80, child: Row(children: [
                    _iconBtn(Icons.edit_outlined, () => _showEditDialog(wh)),
                    _iconBtn(Icons.delete_outline, () => _showDeleteDialog(wh), danger: true),
                  ])),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool danger = false}) {
    return Material(
      color: danger ? AppColors.dangerLight : AppColors.neutralLight,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(7),
        child: SizedBox(width: 28, height: 28, child: Icon(icon, size: 14, color: danger ? AppColors.danger : AppColors.neutralDark)),
      ),
    );
  }
}
