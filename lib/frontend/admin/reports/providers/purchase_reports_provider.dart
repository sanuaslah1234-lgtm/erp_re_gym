import 'package:flutter/foundation.dart';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/core/models/purchase_record_model.dart';
import 'package:erp_software/core/models/purchase_summary_model.dart';
import '../services/reports_api_service.dart';
import 'reports_provider.dart' show DateShortcut;

class PurchaseReportsProvider extends ChangeNotifier {
  final ReportsApiService _api;

  PurchaseReportsProvider({ReportsApiService? api}) : _api = api ?? ReportsApiService();

  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();
  DateShortcut activeShortcut = DateShortcut.last30Days;
  String selectedSupplier = 'All Suppliers';
  String recordsSearch = '';

  List<String> suppliers = ['All Suppliers'];
  PurchaseSummaryModel summary = PurchaseSummaryModel.empty();
  List<PurchaseRecordModel> _records = [];

  bool isLoading = false;
  String? errorMessage;
  bool _initialized = false;

  List<PurchaseRecordModel> get records {
    if (recordsSearch.trim().isEmpty) return _records;
    final q = recordsSearch.toLowerCase();
    return _records
        .where((r) =>
            r.poNumber.toLowerCase().contains(q) ||
            r.supplierName.toLowerCase().contains(q) ||
            r.status.toLowerCase().contains(q))
        .toList();
  }

  /// Only fetches the first time this tab is opened — avoids refetching
  /// every time the user switches back to this tab.
  Future<void> initIfNeeded() async {
    if (_initialized) return;
    _initialized = true;
    await Future.wait([loadSuppliers(), fetchReport()]);
  }

  Future<void> loadSuppliers() async {
    try {
      final fetched = await _api.getSuppliers();
      suppliers = ['All Suppliers', ...fetched];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchReport() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getPurchaseReport(
        from: fromDate,
        to: toDate,
        supplier: selectedSupplier,
      );
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

  void applyShortcut(DateShortcut shortcut) {
    final now = DateTime.now();
    activeShortcut = shortcut;

    switch (shortcut) {
      case DateShortcut.today:
        fromDate = DateTime(now.year, now.month, now.day);
        toDate = now;
        break;
      case DateShortcut.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        fromDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        toDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case DateShortcut.last7Days:
        fromDate = now.subtract(const Duration(days: 7));
        toDate = now;
        break;
      case DateShortcut.last30Days:
        fromDate = now.subtract(const Duration(days: 30));
        toDate = now;
        break;
      case DateShortcut.thisMonth:
        fromDate = DateTime(now.year, now.month, 1);
        toDate = now;
        break;
      case DateShortcut.custom:
        break;
    }

    fetchReport();
  }

  void setCustomDateRange({DateTime? from, DateTime? to}) {
    activeShortcut = DateShortcut.custom;
    if (from != null) fromDate = from;
    if (to != null) toDate = to;
    fetchReport();
  }

  void setSupplier(String value) {
    selectedSupplier = value;
    fetchReport();
  }

  void setRecordsSearch(String value) {
    recordsSearch = value;
    notifyListeners();
  }
}
