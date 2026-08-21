import 'package:flutter/material.dart';
import 'package:erp_software/backend/models/supplier_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class SupplierManagementDialog extends StatefulWidget {
  const SupplierManagementDialog({super.key});

  @override
  State<SupplierManagementDialog> createState() => _SupplierManagementDialogState();
}

class _SupplierManagementDialogState extends State<SupplierManagementDialog> {
  final _codeCtrl = TextEditingController(text: 'SUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  Future<void> _addSupplier() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<ProductManagementProvider>(context, listen: false);

    final success = await provider.addSupplier(
      authProvider.token,
      SupplierModel(
        supplierCode: _codeCtrl.text.trim(),
        name: name,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        gstVatNumber: _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
      ),
    );

    if (success && mounted) {
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _emailCtrl.clear();
      _gstCtrl.clear();
      _codeCtrl.text = 'SUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      ErpToast.showSuccess(context, 'Supplier "$name" added!');
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
        width: 650,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Supplier Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 20),

            // Form to Add Supplier
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(labelText: 'Code *', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Supplier Name *', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addSupplier,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Suppliers List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: provider.suppliers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sup = provider.suppliers[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${sup.name} (${sup.supplierCode})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Phone: ${sup.phone ?? 'N/A'} | Email: ${sup.email ?? 'N/A'}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
