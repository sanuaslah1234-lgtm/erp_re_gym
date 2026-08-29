class SupplierModel {
  final dynamic id;
  final String supplierCode;
  final String name;
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
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      gstVatNumber: json['gstVatNumber'] ?? json['gst_vat_number'] ?? json['tax_number'],
      status: (json['status'] ?? 'active').toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierCode': supplierCode,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'gstVatNumber': gstVatNumber,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
