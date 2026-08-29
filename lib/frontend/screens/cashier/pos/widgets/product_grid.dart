import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No products found', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    if (screenWidth < 600) {
      crossAxisCount = 2;
    } else if (screenWidth < 1100) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.1,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}
