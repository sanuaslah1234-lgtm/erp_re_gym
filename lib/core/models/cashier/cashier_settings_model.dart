class CashierSettingsModel {
  final int? id;
  final String storeName;
  final String storeAddress;
  final String phone;
  final String email;
  final String receiptFooter;
  final bool showLogo;
  final bool showTax;
  final bool showCashierName;
  final bool showCustomerName;
  final bool autoPrintReceipt;
  final double defaultTaxPercentage;
  final bool allowNegativeStock;
  final bool requireCustomer;
  final bool allowDiscount;
  final double maximumDiscountPercentage;
  final bool autoClearCart;

  CashierSettingsModel({
    this.id,
    this.storeName = 'ERP Mart Store',
    this.storeAddress = '123 Commerce Way, Tech City',
    this.phone = '+1 (555) 019-2831',
    this.email = 'support@erpmart.com',
    this.receiptFooter = 'Thank you for shopping with us! Please come again.',
    this.showLogo = true,
    this.showTax = true,
    this.showCashierName = true,
    this.showCustomerName = true,
    this.autoPrintReceipt = false,
    this.defaultTaxPercentage = 5.0,
    this.allowNegativeStock = false,
    this.requireCustomer = false,
    this.allowDiscount = true,
    this.maximumDiscountPercentage = 50.0,
    this.autoClearCart = true,
  });

  factory CashierSettingsModel.fromJson(Map<String, dynamic> json) {
    return CashierSettingsModel(
      id: json['id'] as int?,
      storeName: json['storeName'] ?? json['store_name'] ?? 'ERP Mart Store',
      storeAddress: json['storeAddress'] ?? json['store_address'] ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      receiptFooter: json['receiptFooter'] ?? json['receipt_footer'] ?? '',
      showLogo: json['showLogo'] ?? json['show_logo'] ?? true,
      showTax: json['showTax'] ?? json['show_tax'] ?? true,
      showCashierName: json['showCashierName'] ?? json['show_cashier_name'] ?? true,
      showCustomerName: json['showCustomerName'] ?? json['show_customer_name'] ?? true,
      autoPrintReceipt: json['autoPrintReceipt'] ?? json['auto_print_receipt'] ?? false,
      defaultTaxPercentage: (json['defaultTaxPercentage'] ?? json['default_tax_percentage'] ?? 5.0).toDouble(),
      allowNegativeStock: json['allowNegativeStock'] ?? json['allow_negative_stock'] ?? false,
      requireCustomer: json['requireCustomer'] ?? json['require_customer'] ?? false,
      allowDiscount: json['allowDiscount'] ?? json['allow_discount'] ?? true,
      maximumDiscountPercentage: (json['maximumDiscountPercentage'] ?? json['maximum_discount_percentage'] ?? 50.0).toDouble(),
      autoClearCart: json['autoClearCart'] ?? json['auto_clear_cart'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'phone': phone,
      'email': email,
      'receiptFooter': receiptFooter,
      'showLogo': showLogo,
      'showTax': showTax,
      'showCashierName': showCashierName,
      'showCustomerName': showCustomerName,
      'autoPrintReceipt': autoPrintReceipt,
      'defaultTaxPercentage': defaultTaxPercentage,
      'allowNegativeStock': allowNegativeStock,
      'requireCustomer': requireCustomer,
      'allowDiscount': allowDiscount,
      'maximumDiscountPercentage': maximumDiscountPercentage,
      'autoClearCart': autoClearCart,
    };
  }
}
