import 'package:flutter/foundation.dart';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/core/models/sales_record_model.dart';
import 'package:erp_software/core/models/sales_summary_model.dart';
import '../services/reports_api_service.dart';

enum DateShortcut { today, yesterday, last7Days, last30Days, thisMonth, custom }

class ReportsProvider extends ChangeNotifier {
  final ReportsApiService _api;

  ReportsProvider({ReportsApiService? api}) : _api = api ?? ReportsApiService();

  // ---- filters ----
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();
  DateShortcut activeShortcut = DateShortcut.last30Days;
  String selectedCustomer = 'All Customers';
  String recordsSearch = '';

  // ---- data ----
  List<String> customers = ['All Customers'];
  SalesSummaryModel summary = SalesSummaryModel.empty();
  List<SalesRecordModel> _records = [];

  // ---- ui state ----
  bool isLoading = false;
  String? errorMessage;

  List<SalesRecordModel> get records {
    if (recordsSearch.trim().isEmpty) return _records;
    final q = recordsSearch.toLowerCase();
    return _records
        .where((r) =>
            r.orderNumber.toLowerCase().contains(q) ||
            r.customerName.toLowerCase().contains(q) ||
            r.status.toLowerCase().contains(q))
        .toList();
  }

  Future<void> init() async {
    await Future.wait([loadCustomers(), fetchReport()]);
  }

  Future<void> loadCustomers() async {
    try {
      final fetched = await _api.getCustomers();
      customers = ['All Customers', ...fetched];
      notifyListeners();
    } catch (_) {
      // Non-critical — dropdown just falls back to "All Customers" only.
    }
  }

  Future<void> fetchReport() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getSalesReport(
        from: fromDate,
        to: toDate,
        customer: selectedCustomer,
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
        // fromDate/toDate already set by the date pickers directly.
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

  void setCustomer(String value) {
    selectedCustomer = value;
    fetchReport();
  }

  void setRecordsSearch(String value) {
    recordsSearch = value;
    notifyListeners();
  }
}
