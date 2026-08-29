import 'purchase_record_model.dart';
import 'purchase_summary_model.dart';

class PurchaseReportResult {
  final PurchaseSummaryModel summary;
  final List<PurchaseRecordModel> records;

  const PurchaseReportResult({required this.summary, required this.records});
}