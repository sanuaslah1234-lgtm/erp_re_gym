import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/product.dart';
import 'package:erp_software/frontend/widgets/common/barcode_widget.dart';

class BarcodePreview extends StatelessWidget {
  final Product product;
  final int labelQuantity;

  const BarcodePreview({
    super.key,
    required this.product,
    required this.labelQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final barcodeData = product.barcode ?? product.productCode;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ERP MART', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Barcode Lines Visual Representation
          BarcodeWidget(
            data: barcodeData,
            height: 40,
            showText: true,
            fontSize: 10,
          ),
          const SizedBox(height: 6),
          Text(
            'PRICE: \$${product.sellingPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}


