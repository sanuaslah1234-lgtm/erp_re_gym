import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../../admin/branch/providers/branch_provider.dart';
import '../../admin/branch/widgets/branch_card_list.dart';
import '../../admin/branch/widgets/branch_data_table.dart';
import '../../admin/branch/widgets/branch_toolbar.dart';

/// Drop this into your app's routing / shell in place of the Branch tab body.
/// It expects to be wrapped by a ChangeNotifierProvider&lt;BranchProvider&gt;
/// (see main.dart), OR you can wrap just this screen locally — see below.
class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BranchProvider>().fetchBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BranchProvider>();
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
            const BranchToolbar(),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(provider, isNarrow)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BranchProvider provider, bool isNarrow) {
    if (provider.isLoading && provider.branches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.branches.isEmpty) {
      return _StateMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load branches',
        subtitle: provider.errorMessage!,
        actionLabel: 'Retry',
        onAction: () => provider.fetchBranches(),
      );
    }

    final branches = provider.branches;

    if (branches.isEmpty) {
      return const _StateMessage(
        icon: Icons.apartment_outlined,
        title: 'No branches found',
        subtitle: 'Try a different search or add a new branch.',
      );
    }

    return SingleChildScrollView(
      child: isNarrow
          ? BranchCardList(branches: branches)
          : BranchDataTable(branches: branches),
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
            Text(subtitle,
                style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
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

