import 'package:erp_software/core/models/cashier/product.dart';

class CartItem {
  final Product product;
  double quantity;
  double discount; // discount percentage (0-100)
  double tax; // tax percentage

  CartItem({
    required this.product,
    this.quantity = 1.0,
    this.discount = 0.0,
    double? tax,
  }) : tax = tax ?? product.taxPercentage;

  double get subtotal => quantity * product.sellingPrice;
  double get discountAmount => subtotal * (discount / 100.0);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (tax / 100.0);
  double get total => taxableAmount + taxAmount;

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'product_code': product.productCode,
      'product_name': product.name,
      'barcode': product.barcode,
      'quantity': quantity,
      'unit_price': product.sellingPrice,
      'discount': discount,
      'tax': tax,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': total,
    };
  }
}
