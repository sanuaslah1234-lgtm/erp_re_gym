class SupplierModel {
  final dynamic id;
  final String supplierCode;
  final String name;
  final String? companyName;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstVatNumber;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupplierModel({
    this.id,
    required this.supplierCode,
    required this.name,
    this.companyName,
    this.phone,
    this.email,
    this.address,
    this.gstVatNumber,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      supplierCode: (json['supplierCode'] ?? json['supplier_code'] ?? json['tax_number'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['company_name'] ?? '').toString(),
      companyName: (json['companyName'] ?? json['company_name'] ?? json['name'])?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      gstVatNumber: json['gstVatNumber'] ?? json['gst_vat_number'] ?? json['tax_number'],
      status: (json['status'] ?? 'active').toString(),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_code': supplierCode,
      'name': name,
      'company_name': companyName ?? name,
      'phone': phone,
      'email': email,
      'address': address,
      'gst_vat_number': gstVatNumber,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
