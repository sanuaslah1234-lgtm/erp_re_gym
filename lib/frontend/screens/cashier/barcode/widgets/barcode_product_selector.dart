import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product.dart';

class BarcodeProductSelector extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onSelect;

  const BarcodeProductSelector({
    super.key,
    required this.products,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Products to Print', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final p = products[i];
              return ListTile(
                title: Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Code: ${p.productCode} • Barcode: ${p.barcode ?? "N/A"}'),
                trailing: Text('\$${p.sellingPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                onTap: () => onSelect(p),
              );
            },
          ),
        ],
      ),
    );
  }
}
