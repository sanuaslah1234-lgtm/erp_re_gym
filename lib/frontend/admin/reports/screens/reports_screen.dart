import 'package:flutter/material.dart';

import '../widgets/report_tabs.dart';
import 'inventory_reports_view.dart';
import 'purchase_reports_view.dart';
import 'sales_reports_view.dart';

/// Drop this into your app's routing / shell in place of the Reports tab
/// body. Wrap it (or a parent above it) with ChangeNotifierProvider for
/// ReportsProvider, PurchaseReportsProvider, and InventoryReportsProvider
/// — see main.dart.
///
/// Each tab keeps its own state alive via IndexedStack, so switching tabs
/// doesn't lose your filters or re-fetch data you already loaded.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportTab _activeTab = ReportTab.sales;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportTabs(selected: _activeTab, onSelect: (tab) => setState(() => _activeTab = tab)),
          const SizedBox(height: 20),
          IndexedStack(
            index: _activeTab.index,
            children: const [
              SalesReportsView(),
              PurchaseReportsView(),
              InventoryReportsView(),
            ],
          ),
        ],
      ),
    );
  }
}
