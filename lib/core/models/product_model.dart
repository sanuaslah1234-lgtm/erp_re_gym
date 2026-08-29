class ProductModel {
  final String id;
  final String name;
  final String sku;

  const ProductModel({
    required this.id,
    required this.name,
    required this.sku,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
    );
  }
}