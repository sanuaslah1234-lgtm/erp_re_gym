import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/cashier/barcode_provider.dart';
import 'package:erp_software/frontend/widgets/common/barcode_widget.dart';
import 'package:provider/provider.dart';

class BarcodeProductsTable extends StatelessWidget {
  const BarcodeProductsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BarcodeProvider>(context);
    final products = provider.filteredProducts;

    final allSelected = products.isNotEmpty && products.every((p) => provider.checkedProductIds.contains(p.id));

    return Column(
      children: [
        // Search & Category Filter Row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    onChanged: (val) => provider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search by name, SKU or barcode...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Category Dropdown
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedCategory,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('Category: All')),
                      DropdownMenuItem(value: 'Electronics', child: Text('Category: Electronics')),
                      DropdownMenuItem(value: 'Groceries', child: Text('Category: Groceries')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.setSelectedCategory(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table Header
        Container(
          color: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Checkbox(
                  value: allSelected,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (val) => provider.toggleAllCheckboxes(val),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(flex: 3, child: Text('PRODUCT INFO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              const Expanded(flex: 2, child: Text('SKU / BARCODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              const Expanded(flex: 2, child: Text('PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              const Expanded(flex: 2, child: Text('PRINT QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              const Expanded(flex: 3, child: Text('LIVE BARCODE', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            ],
          ),
        ),

        // Table Rows Body
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text('No products found', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))))
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isChecked = provider.checkedProductIds.contains(product.id);
                    final printItem = provider.selectedProducts.firstWhere(
                      (item) => item.product.id == product.id,
                      orElse: () => BarcodePrintItem(product: product, quantity: 1),
                    );
                    final barcodeData = product.barcode ?? product.productCode;

                    final initials = product.name.length >= 2 ? product.name.substring(0, 2).toUpperCase() : 'PR';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Checkbox(
                              value: isChecked,
                              activeColor: const Color(0xFF2563EB),
                              onChanged: (val) => provider.toggleProductCheck(product.id, val),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // PRODUCT INFO (Avatar + Title + Subtitle)
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        product.name.toLowerCase(),
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // SKU / BARCODE
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    product.productCode,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  barcodeData,
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),

                          // PRICE
                          Expanded(
                            flex: 2,
                            child: Text(
                              '₹${product.sellingPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                          ),

                          // PRINT QTY (Stepper)
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => provider.updateQuantity(product.id, printItem.quantity - 1),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6),
                                          child: Icon(Icons.remove, size: 14, color: Color(0xFF64748B)),
                                        ),
                                      ),
                                      Container(
                                        width: 32,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        color: const Color(0xFFF8FAFC),
                                        child: Text(
                                          '${printItem.quantity}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => provider.updateQuantity(product.id, printItem.quantity + 1),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6),
                                          child: Icon(Icons.add, size: 14, color: Color(0xFF64748B)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // LIVE BARCODE
                          Expanded(
                            flex: 3,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: BarcodeWidget(
                                data: barcodeData,
                                height: 32,
                                showText: false,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

