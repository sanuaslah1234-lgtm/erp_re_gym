import 'package:flutter/foundation.dart';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/core/models/inventory_record_model.dart';
import 'package:erp_software/core/models/inventory_summary_model.dart';
import '../services/reports_api_service.dart';

class InventoryReportsProvider extends ChangeNotifier {
  final ReportsApiService _api;

  InventoryReportsProvider({ReportsApiService? api}) : _api = api ?? ReportsApiService();

  String selectedCategory = 'All Categories';
  String recordsSearch = '';

  List<String> categories = ['All Categories'];
  InventorySummaryModel summary = InventorySummaryModel.empty();
  List<InventoryRecordModel> _records = [];

  bool isLoading = false;
  String? errorMessage;
  bool _initialized = false;

  List<InventoryRecordModel> get records {
    if (recordsSearch.trim().isEmpty) return _records;
    final q = recordsSearch.toLowerCase();
    return _records
        .where((r) => r.sku.toLowerCase().contains(q) || r.itemName.toLowerCase().contains(q))
        .toList();
  }

  Future<void> initIfNeeded() async {
    if (_initialized) return;
    _initialized = true;
    await Future.wait([loadCategories(), fetchReport()]);
  }

  Future<void> loadCategories() async {
    try {
      final fetched = await _api.getCategories();
      categories = ['All Categories', ...fetched];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchReport() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getInventoryReport(category: selectedCategory);
      summary = result.summary;
      _records = result.records;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load report';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String value) {
    selectedCategory = value;
    fetchReport();
  }

  void setRecordsSearch(String value) {
    recordsSearch = value;
    notifyListeners();
  }
}
