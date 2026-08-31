import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/admin/branch/providers/branch_provider.dart';
import 'package:erp_software/frontend/admin/branch/widgets/branch_card_list.dart';
import 'package:erp_software/frontend/admin/branch/widgets/branch_data_table.dart';
import 'package:erp_software/frontend/admin/branch/widgets/branch_toolbar.dart';

class StoreBranchesScreen extends StatefulWidget {
  const StoreBranchesScreen({super.key});

  @override
  State<StoreBranchesScreen> createState() => _StoreBranchesScreenState();
}

class _StoreBranchesScreenState extends State<StoreBranchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BranchProvider>().fetchBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final provider = context.watch<BranchProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile ? Drawer(child: ErpSidebar(activeItem: 'Store Outlets & Branches', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Store Outlets & Branches'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: Padding(
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
                          Expanded(child: _buildBody(provider, isMobile)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BranchProvider provider, bool isNarrow) {
    if (provider.isLoading && provider.branches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.branches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Could not load branches', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(provider.errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: () => provider.fetchBranches(), child: const Text('Retry')),
          ],
        ),
      );
    }
    final branches = provider.branches;
    if (branches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment_outlined, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text('No branches found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Add your first branch to get started.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: isNarrow ? BranchCardList(branches: branches) : BranchDataTable(branches: branches),
    );
  }
}
