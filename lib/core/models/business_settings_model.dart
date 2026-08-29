class BusinessSettingsModel {
  final String? companyLogoBase64;
  final String companyName;
  final String legalTradeName;
  final String taxVatNumber;
  final String officialEmail;
  final String businessPhone;
  final String headquartersAddress;
  final DateTime? updatedAt;

  const BusinessSettingsModel({
    this.companyLogoBase64,
    this.companyName = '',
    this.legalTradeName = '',
    this.taxVatNumber = '',
    this.officialEmail = '',
    this.businessPhone = '',
    this.headquartersAddress = '',
    this.updatedAt,
  });

  factory BusinessSettingsModel.fromJson(Map<String, dynamic> json) => BusinessSettingsModel.fromMap(json);
  factory BusinessSettingsModel.fromMap(Map<String, dynamic> json) {
    return BusinessSettingsModel(
      companyLogoBase64: json['company_logo_base64']?.toString(),
      companyName: json['company_name']?.toString() ?? '',
      legalTradeName: json['legal_trade_name']?.toString() ?? '',
      taxVatNumber: json['tax_vat_number']?.toString() ?? '',
      officialEmail: json['official_email']?.toString() ?? '',
      businessPhone: json['business_phone']?.toString() ?? '',
      headquartersAddress: json['headquarters_address']?.toString() ?? '',
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => toRequestJson();
  Map<String, dynamic> toRequestJson() {
    return {
      'company_logo_base64': companyLogoBase64,
      'company_name': companyName,
      'legal_trade_name': legalTradeName,
      'tax_vat_number': taxVatNumber,
      'official_email': officialEmail,
      'business_phone': businessPhone,
      'headquarters_address': headquartersAddress,
    };
  }

  BusinessSettingsModel copyWith({
    String? companyLogoBase64,
    String? companyName,
    String? legalTradeName,
    String? taxVatNumber,
    String? officialEmail,
    String? businessPhone,
    String? headquartersAddress,
  }) {
    return BusinessSettingsModel(
      companyLogoBase64: companyLogoBase64 ?? this.companyLogoBase64,
      companyName: companyName ?? this.companyName,
      legalTradeName: legalTradeName ?? this.legalTradeName,
      taxVatNumber: taxVatNumber ?? this.taxVatNumber,
      officialEmail: officialEmail ?? this.officialEmail,
      businessPhone: businessPhone ?? this.businessPhone,
      headquartersAddress: headquartersAddress ?? this.headquartersAddress,
      updatedAt: updatedAt,
    );
  }
}