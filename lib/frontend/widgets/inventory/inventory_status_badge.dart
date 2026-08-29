import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class InventoryStatusBadge extends StatelessWidget {
  final String status;

  const InventoryStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _config();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: config.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _config() {
    switch (status) {
      case 'In Stock':
        return const _StatusConfig(
          background: AppColors.successLight,
          foreground: AppColors.successText,
        );

      case 'Low Stock':
        return const _StatusConfig(
          background: AppColors.warningLight,
          foreground: AppColors.warningText,
        );

      case 'Out of Stock':
        return const _StatusConfig(
          background: AppColors.dangerLight,
          foreground: AppColors.dangerText,
        );

      default:
        return const _StatusConfig(
          background: AppColors.neutralLight,
          foreground: AppColors.neutralText,
        );
    }
  }
}

class _StatusConfig {
  final Color background;
  final Color foreground;

  const _StatusConfig({
    required this.background,
    required this.foreground,
  });
}
