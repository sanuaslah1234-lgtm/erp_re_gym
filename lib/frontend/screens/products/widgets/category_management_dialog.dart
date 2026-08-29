import 'package:flutter/material.dart';
import 'package:erp_software/core/models/category_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/product_management_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class CategoryManagementDialog extends StatefulWidget {
  const CategoryManagementDialog({super.key});

  @override
  State<CategoryManagementDialog> createState() => _CategoryManagementDialogState();
}

class _CategoryManagementDialogState extends State<CategoryManagementDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<ProductManagementProvider>(context, listen: false);

    try {
      await provider.addCategory(
        authProvider.token,
        CategoryModel(name: name, description: _descCtrl.text.trim()),
      );
      if (mounted) {
        _nameCtrl.clear();
        _descCtrl.clear();
        ErpToast.showSuccess(context, 'Category "$name" added!');
      }
    } catch (e) {
      if (mounted) ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductManagementProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 550,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Category Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 20),

            // Form to Add Category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Category Name *', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Categories List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: provider.categories.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final cat = provider.categories[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(cat.description ?? 'No description'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${cat.productCount} Products', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ),
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
