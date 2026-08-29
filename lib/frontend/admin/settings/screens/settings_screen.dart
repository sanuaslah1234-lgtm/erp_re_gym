import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/settings_provider.dart';
import '../widgets/business_profile_form.dart';
import '../widgets/settings_placeholder_tab.dart';
import '../widgets/settings_tab_nav.dart';

/// Drop this into your app's routing / shell in place of the Settings tab
/// body. Wrap it (or a parent above it) with
/// ChangeNotifierProvider&lt;SettingsProvider&gt; — see main.dart.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsTab _activeTab = SettingsTab.businessProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchSettings();
    });
  }

  Future<void> _save(SettingsProvider provider) async {
    final success = await provider.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Settings saved successfully' : provider.errorMessage ?? 'Save failed'),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _confirmReset(SettingsProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset Defaults', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will discard your current business profile and restore the original default values. Continue?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.white),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await provider.resetToDefaults();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Settings reset to defaults' : provider.errorMessage ?? 'Reset failed'),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final isNarrow = MediaQuery.of(context).size.width < 900;

    if (provider.isLoading && provider.draft.companyName.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(provider, isNarrow),
          const SizedBox(height: 20),
          if (provider.errorMessage != null) _errorBanner(provider),
          isNarrow ? _narrowLayout() : _wideLayout(),
        ],
      ),
    );
  }

  Widget _header(SettingsProvider provider, bool isNarrow) {
    final title = Row(
      children: [
        const Icon(Icons.business_center_outlined, color: AppColors.primary),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('System Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
      ],
    );

    const subtitle = Text(
      'Configure business details, localization, tax rates, inventory thresholds, and system preferences.',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
    );

    final resetButton = OutlinedButton.icon(
      onPressed: provider.isSaving ? null : () => _confirmReset(provider),
      icon: const Icon(Icons.refresh, size: 16),
      label: const Text('Reset Defaults'),
    );

    final saveButton = FilledButton.icon(
      onPressed: (provider.isSaving || !provider.isDirty) ? null : () => _save(provider),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      icon: provider.isSaving
          ? const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
          : const Icon(Icons.save_outlined, size: 16),
      label: Text(provider.isSaving ? 'Saving...' : 'Save Settings'),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: 4),
          subtitle,
          const SizedBox(height: 14),
          Row(children: [Expanded(child: resetButton), const SizedBox(width: 10), Expanded(child: saveButton)]),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 4), subtitle],
          ),
        ),
        resetButton,
        const SizedBox(width: 10),
        saveButton,
      ],
    );
  }

  Widget _errorBanner(SettingsProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.dangerText, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _wideLayout() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 240,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SettingsTabNav(selected: _activeTab, onSelect: (t) => setState(() => _activeTab = t)),
            ),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _tabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _narrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(8),
          child: SettingsTabNav(selected: _activeTab, onSelect: (t) => setState(() => _activeTab = t)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(20),
          child: _tabContent(),
        ),
      ],
    );
  }

  Widget _tabContent() {
    switch (_activeTab) {
      case SettingsTab.businessProfile:
        return const BusinessProfileForm();
      case SettingsTab.localizationFinance:
        return const SettingsPlaceholderTab(title: 'Localization & Finance');
      case SettingsTab.invoicingSales:
        return const SettingsPlaceholderTab(title: 'Invoicing & Sales');
      case SettingsTab.inventoryPos:
        return const SettingsPlaceholderTab(title: 'Inventory & POS');
      case SettingsTab.securitySystem:
        return const SettingsPlaceholderTab(title: 'Security & System');
    }
  }
}
