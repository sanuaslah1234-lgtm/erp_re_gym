import 'package:erp_software/core/models/sales_record_model.dart';
import '../repositories/reports_repository.dart';

class ReportsService {
  final ReportsRepository repository;

  ReportsService(this.repository);

  Future<Map<String, dynamic>> getSalesReport({
    required DateTime from,
    required DateTime to,
    String? customer,
    String? search,
  }) async {
    final summary = await repository.getSalesSummary(
      from: from,
      to: to,
      customer: customer,
    );

    final recordsRaw = await repository.getSalesRecords(
      from: from,
      to: to,
      customer: customer,
      search: search,
    );

    final records = recordsRaw.map((r) => SalesRecordModel.fromMap(r)).toList();

    return {
      'summary': summary,
      'records': records.map((r) => r.toJson()).toList(),
    };
  }

  Future<List<String>> getCustomers() {
    return repository.getDistinctCustomers();
  }

  Future<Map<String, dynamic>> getPurchaseReport({
    required DateTime from,
    required DateTime to,
    String? supplier,
    String? search,
  }) async {
    final summary = await repository.getPurchaseSummary(from: from, to: to, supplier: supplier);
    final records = await repository.getPurchaseRecords(
      from: from,
      to: to,
      supplier: supplier,
      search: search,
    );

    return {'summary': summary, 'records': records};
  }

  Future<List<String>> getSuppliers() {
    return repository.getDistinctSuppliers();
  }

  Future<Map<String, dynamic>> getInventoryReport({
    String? category,
    String? search,
  }) async {
    final summary = await repository.getInventorySummary(category: category);
    final records = await repository.getInventoryRecords(category: category, search: search);

    return {'summary': summary, 'records': records};
  }

  Future<List<String>> getCategories() {
    return repository.getDistinctCategories();
  }
}