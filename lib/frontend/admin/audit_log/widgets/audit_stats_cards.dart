import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/audit_log_provider.dart';

class AuditStatsCards extends StatelessWidget {
  const AuditStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditLogProvider>();
    final stats = provider.stats;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : (width < 1000 ? 2 : 4);

    final cards = [
      _StatCard(
        value: stats.totalLogs.toString(),
        label: 'Total Logs',
        icon: Icons.show_chart,
        color: AppColors.primary,
      ),
      _StatCard(
        value: stats.employeeEvents.toString(),
        label: 'Employee Events',
        icon: Icons.person_outline,
        color: AppColors.success,
      ),
      _StatCard(
        value: stats.authEvents.toString(),
        label: 'Auth Events',
        icon: Icons.shield_outlined,
        color: AppColors.warning,
      ),
      _StatCard(
        value: stats.today.toString(),
        label: 'Today',
        icon: Icons.access_time,
        color: AppColors.danger,
      ),
    ];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: crossAxisCount == 1 ? 3.6 : 2.6,
      children: cards,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
