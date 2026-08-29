import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.product.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${item.product.sellingPrice.toStringAsFixed(2)} / ${item.product.unit}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity stepper
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => onQuantityChanged(item.quantity - 1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.remove, size: 14, color: Color(0xFF475569)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      color: const Color(0xFFF1F5F9),
                      child: Text(
                        item.quantity.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    InkWell(
                      onTap: () => onQuantityChanged(item.quantity + 1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.add, size: 14, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),

              if (item.discount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.discount.toStringAsFixed(0)}% Off',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
