import 'package:erp_software/core/models/sales_record_model.dart';
import 'package:erp_software/core/models/sales_summary_model.dart';

class SalesReportResult {
  final SalesSummaryModel summary;
  final List<SalesRecordModel> records;

  const SalesReportResult({required this.summary, required this.records});
}