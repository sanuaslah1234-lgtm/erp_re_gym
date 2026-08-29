import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

class SettingsPlaceholderTab extends StatelessWidget {
  final String title;

  const SettingsPlaceholderTab({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined, size: 42, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text('$title settings coming soon',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('This section will be built once its fields are designed.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
