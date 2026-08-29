class WarehouseModel {
  final String id;
  final String name;

  const WarehouseModel({
    required this.id,
    required this.name,
  });

  factory WarehouseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WarehouseModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
    );
  }
}