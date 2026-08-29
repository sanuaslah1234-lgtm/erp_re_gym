import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/core/models/audit_log_model.dart';
import '../providers/audit_log_provider.dart';
import '../widgets/audit_filters_bar.dart';
import '../widgets/audit_log_card_list.dart';
import '../widgets/audit_log_table.dart';
import '../widgets/audit_stats_cards.dart';
import 'employee_timeline_screen.dart';

/// Drop this into your app's routing / shell in place of the Audit Log
/// tab body. Wrap it (or a parent above it) with
/// ChangeNotifierProvider&lt;AuditLogProvider&gt; — see main.dart.
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditLogProvider>().fetchLogs();
    });
  }

  void _openTimeline(BuildContext context, AuditLogModel log) {
    if (log.employeeDbId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EmployeeTimelineScreen(employeeDbId: log.employeeDbId!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditLogProvider>();
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Audit Logs & Activity History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              OutlinedButton.icon(
                onPressed: provider.isLoading ? null : () => provider.fetchLogs(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Monitor real-time system events. Tap any log with a timeline button to see the full activity history.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          const AuditStatsCards(),
          const SizedBox(height: 20),
          const AuditFiltersBar(),
          const SizedBox(height: 20),
          _body(provider, isNarrow),
        ],
      ),
    );
  }

  Widget _body(AuditLogProvider provider, bool isNarrow) {
    if (provider.isLoading && provider.logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null && provider.logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('Could not load audit logs', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(provider.errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              OutlinedButton(onPressed: () => provider.fetchLogs(), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (provider.logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 44, color: AppColors.textMuted),
              SizedBox(height: 12),
              Text('No logs found', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 4),
              Text('Try changing your filters.', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: isNarrow
          ? AuditLogCardList(logs: provider.logs, onViewTimeline: (log) => _openTimeline(context, log))
          : AuditLogTable(logs: provider.logs, onViewTimeline: (log) => _openTimeline(context, log)),
    );
  }
}
