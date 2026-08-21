import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';


// Conditional import for web download
import 'package:erp_software/core/utils/web_download_stub.dart'
    if (dart.library.html) 'package:erp_software/core/utils/web_download_html.dart';

class ExportPrintHelper {
  static void exportCsv({
    required BuildContext context,
    required String filename,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(headers.map((h) => '"${h.replaceAll('"', '""')}"').join(','));
    for (final row in rows) {
      buffer.writeln(row.map((cell) => '"${cell.toString().replaceAll('"', '""')}"').join(','));
    }

    final csvContent = buffer.toString();
    final fileNameWithExt = filename.endsWith('.csv') ? filename : '$filename.csv';

    try {
      if (kIsWeb) {
        triggerWebDownload(csvContent, fileNameWithExt);
      } else {
        // Desktop / Mobile fallback
        debugPrint('--- EXPORT FILE: $fileNameWithExt ---\n$csvContent');
      }
      ErpToast.showSuccess(
        context,
        'File downloaded successfully as $fileNameWithExt',
        title: 'Export Completed',
      );
    } catch (e) {
      ErpToast.showError(
        context,
        'Failed to export file: $e',
        title: 'Export Error',
      );
    }
  }

  static void showPrintPage({
    required BuildContext context,
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 900,
            height: 650,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.print_rounded, color: Color(0xFF2563EB), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Print Preview - $title',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Generated on ${DateTime.now().toString().split('.').first}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (kIsWeb) {
                              triggerWebPrint();
                            } else {
                              ErpToast.showInfo(context, 'Printing document...');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.print, size: 18),
                          label: const Text('Print Document'),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Table Printable Layout
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columns: headers
                            .map((h) => DataColumn(
                                  label: Text(
                                    h,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                ))
                            .toList(),
                        rows: rows.map((r) {
                          return DataRow(
                            cells: r
                                .map((c) => DataCell(Text(
                                      c.toString(),
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                    )))
                                .toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
