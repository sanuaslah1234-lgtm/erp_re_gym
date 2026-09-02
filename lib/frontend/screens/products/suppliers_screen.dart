import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/supplier_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:provider/provider.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ProductManagementProvider>(context, listen: false).loadAllData(auth.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);
    final suppliers = provider.suppliers.where((s) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return s.name.toLowerCase().contains(q) || (s.phone?.toLowerCase().contains(q) ?? false) || (s.email?.toLowerCase().contains(q) ?? false);
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Suppliers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Suppliers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  SizedBox(height: 2),
                                  Text('Manage your suppliers and vendors', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _showAddDialog,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Supplier'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Suppliers', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  SizedBox(height: 4),
                                  Text('Manage your suppliers and vendors', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _showAddDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Supplier'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        // Search
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
                          child: Row(children: [
                            Expanded(child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: InputDecoration(hintText: 'Search suppliers...', prefixIcon: const Icon(Icons.search, size: 18), isDense: true, filled: true, fillColor: AppColors.surfaceSecondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            )),
                            const SizedBox(width: 8),
                            Text('${suppliers.length} supplier${suppliers.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        if (provider.isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                        else if (suppliers.isEmpty)
                          Container(
                            width: double.infinity, padding: const EdgeInsets.all(50),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                            child: Column(children: [
                              const Icon(Icons.local_shipping_outlined, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 14),
                              const Text('No suppliers found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 5),
                              const Text('Add your first supplier to get started.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ]),
                          )
                        else
                          _buildTable(suppliers),
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

  Widget _buildTable(List<SupplierModel> suppliers) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 850,
          child: Column(children: [
            Container(
              height: 44, padding: const EdgeInsets.symmetric(horizontal: 20), color: AppColors.surfaceSecondary,
              child: const Row(children: [
                SizedBox(width: 80, child: Text('CODE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 140, child: Text('COMPANY', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 120, child: Text('CONTACT', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 110, child: Text('PHONE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 130, child: Text('EMAIL', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 70, child: Text('STATUS', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 70, child: Text('ACTION', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...List.generate(suppliers.length, (index) {
              final s = suppliers[index];
              final isLast = index == suppliers.length - 1;
              final isActive = s.status == 'active';
              return Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight))),
                child: Row(children: [
                  SizedBox(width: 80, child: Text(s.supplierCode, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 140, child: Text(s.companyName ?? s.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 120, child: Text(s.name, style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 110, child: Text(s.phone ?? '-', style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 130, child: Text(s.email ?? '-', style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 70, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isActive ? AppColors.successLight : AppColors.neutralLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(isActive ? 'ACTIVE' : 'INACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? AppColors.success : AppColors.neutral)),
                  )),
                  SizedBox(width: 70, child: Row(children: [
                    _iconBtn(Icons.edit_outlined, () => _showEditDialog(s)),
                    const SizedBox(width: 4),
                    _iconBtn(Icons.delete_outline, () => _showDeleteDialog(s), danger: true),
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
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(7), child: SizedBox(width: 28, height: 28, child: Icon(icon, size: 14, color: danger ? AppColors.danger : AppColors.neutralDark))),
    );
  }

  void _showAddDialog() {
    final companyNameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final gstCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(width: 480, padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Add Supplier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
        ]),
        const Divider(height: 20),
        TextField(controller: companyNameCtrl, decoration: const InputDecoration(labelText: 'Company Name *', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Contact Person Name', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: gstCtrl, decoration: const InputDecoration(labelText: 'GST/VAT Number', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(
          onPressed: () async {
            if (companyNameCtrl.text.trim().isEmpty) { ErpToast.showError(ctx, 'Company name is required'); return; }
            try {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final provider = Provider.of<ProductManagementProvider>(context, listen: false);
              await provider.addSupplier(auth.token, SupplierModel(
                supplierCode: 'SUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                name: companyNameCtrl.text.trim(),
                companyName: companyNameCtrl.text.trim(),
                phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                gstVatNumber: gstCtrl.text.trim().isEmpty ? null : gstCtrl.text.trim(),
              ));
              if (!mounted) return;
              if (ctx.mounted) Navigator.pop(ctx);
              ErpToast.showSuccess(context, 'Supplier created');
            } catch (e) {
              if (!mounted) return;
              ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
            }
          },
          icon: const Icon(Icons.add, size: 16), label: const Text('Create'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
        )),
      ])),
    ));
  }

  void _showEditDialog(SupplierModel s) {
    final companyNameCtrl = TextEditingController(text: s.companyName ?? s.name);
    final nameCtrl = TextEditingController(text: s.name);
    final phoneCtrl = TextEditingController(text: s.phone ?? '');
    final emailCtrl = TextEditingController(text: s.email ?? '');
    final addressCtrl = TextEditingController(text: s.address ?? '');
    final gstCtrl = TextEditingController(text: s.gstVatNumber ?? '');

    showDialog(context: context, builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(width: 480, padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Edit Supplier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
        ]),
        const Divider(height: 20),
        TextField(controller: companyNameCtrl, decoration: const InputDecoration(labelText: 'Company Name *', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Contact Person Name', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 12),
        TextField(controller: gstCtrl, decoration: const InputDecoration(labelText: 'GST/VAT Number', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(
          onPressed: () async {
            if (companyNameCtrl.text.trim().isEmpty) { ErpToast.showError(ctx, 'Company name is required'); return; }
            try {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final provider = Provider.of<ProductManagementProvider>(context, listen: false);
              await provider.updateSupplier(auth.token, s.id, SupplierModel(
                id: s.id, supplierCode: s.supplierCode,
                name: nameCtrl.text.trim().isEmpty ? companyNameCtrl.text.trim() : nameCtrl.text.trim(),
                companyName: companyNameCtrl.text.trim(),
                phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                gstVatNumber: gstCtrl.text.trim().isEmpty ? null : gstCtrl.text.trim(),
                status: s.status,
              ));
              if (!mounted) return;
              if (ctx.mounted) Navigator.pop(ctx);
              ErpToast.showSuccess(context, 'Supplier updated');
            } catch (e) {
              if (!mounted) return;
              ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
            }
          },
          icon: const Icon(Icons.save, size: 16), label: const Text('Save'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
        )),
      ])),
    ));
  }

  void _showDeleteDialog(SupplierModel s) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Supplier'),
      content: Text('Delete "${s.name}"? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            try {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final provider = Provider.of<ProductManagementProvider>(context, listen: false);
              await provider.deleteSupplier(auth.token, s.id);
              if (!mounted) return;
              if (ctx.mounted) Navigator.pop(ctx);
              ErpToast.showSuccess(context, 'Supplier deleted');
            } catch (e) {
              if (!mounted) return;
              ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
