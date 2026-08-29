import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/audit_log_model.dart';
import 'action_badge.dart';

class AuditLogCardList extends StatelessWidget {
  final List<AuditLogModel> logs;
  final void Function(AuditLogModel log) onViewTimeline;

  const AuditLogCardList({super.key, required this.logs, required this.onViewTimeline});

  String _dateLabel(DateTime? dt) {
    if (dt == null) return '-';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day} at $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(log.employeeName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                  ActionBadge(action: log.action),
                ],
              ),
              const SizedBox(height: 4),
              Text(_dateLabel(log.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.pageBackground, borderRadius: BorderRadius.circular(6)),
                  child: Text(log.module, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(log.description, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
              ]),
              if (log.employeeDbId != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => onViewTimeline(log),
                    icon: const Icon(Icons.timeline, size: 14),
                    label: const Text('View Timeline', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
