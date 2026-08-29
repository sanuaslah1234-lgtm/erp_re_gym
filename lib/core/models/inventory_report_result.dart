import 'inventory_record_model.dart';
import 'inventory_summary_model.dart';

class InventoryReportResult {
  final InventorySummaryModel summary;
  final List<InventoryRecordModel> records;

  const InventoryReportResult({required this.summary, required this.records});
}