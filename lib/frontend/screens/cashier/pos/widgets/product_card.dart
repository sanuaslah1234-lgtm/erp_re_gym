import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product.dart';
import 'package:erp_software/frontend/widgets/common/barcode_widget.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stockQuantity <= 0;
    final barcodeData = product.barcode ?? product.productCode;

    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOutOfStock ? Colors.red.shade200 : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Area Container
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: Container(
                height: 75,
                width: double.infinity,
                color: const Color(0xFFF8FAFC),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices_other_rounded,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          product.name,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SKU: ${product.productCode}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Barcode Lines Visualization
                        BarcodeWidget(
                          data: barcodeData,
                          height: 18,
                          showText: false,
                          color: const Color(0xFF1E293B),
                        ),
                      ],
                    ),

                    // Price and Stock / Add Button Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${product.sellingPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Stock: ${product.stockQuantity.toInt()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isOutOfStock ? Colors.red : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: isOutOfStock ? Colors.grey.shade300 : const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


