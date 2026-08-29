import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final bool isActive;

  const StatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.neutral;
    final bg = isActive ? AppColors.successLight : AppColors.neutralLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
