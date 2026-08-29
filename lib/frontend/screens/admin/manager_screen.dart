import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../../admin/manager/providers/manager_provider.dart';
import '../../admin/manager/widgets/manager_card_list.dart';
import '../../admin/manager/widgets/manager_data_table.dart';
import '../../admin/manager/widgets/manager_toolbar.dart';

/// Drop this into your app's routing / shell in place of the Manager tab
/// body. Wrap it (or a parent above it) with
/// ChangeNotifierProvider&lt;ManagerProvider&gt; — see main.dart.
class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerProvider>();
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ManagerToolbar(),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(provider, isNarrow)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ManagerProvider provider, bool isNarrow) {
    if (provider.isLoading && provider.managers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.managers.isEmpty) {
      return _StateMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load managers',
        subtitle: provider.errorMessage!,
        actionLabel: 'Retry',
        onAction: () => provider.fetchManagers(),
      );
    }

    final managers = provider.managers;

    if (managers.isEmpty) {
      return const _StateMessage(
        icon: Icons.badge_outlined,
        title: 'No managers found',
        subtitle: 'Try a different search or add a new manager.',
      );
    }

    return SingleChildScrollView(
      child: isNarrow ? ManagerCardList(managers: managers) : ManagerDataTable(managers: managers),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

