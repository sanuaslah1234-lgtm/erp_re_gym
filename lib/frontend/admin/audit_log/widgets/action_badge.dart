import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

class ActionBadge extends StatelessWidget {
  final String action;

  const ActionBadge({super.key, required this.action});

  static Color colorFor(String action) {
    switch (action) {
      case 'LOGIN':
        return AppColors.electronics;
      case 'LOGOUT':
        return AppColors.neutral;
      case 'CREATE':
        return AppColors.success;
      case 'UPDATE':
        return AppColors.primary;
      case 'DELETE':
        return AppColors.danger;
      default:
        return AppColors.neutral;
    }
  }

  static IconData iconFor(String action) {
    switch (action) {
      case 'LOGIN':
        return Icons.login;
      case 'LOGOUT':
        return Icons.logout;
      case 'CREATE':
        return Icons.add_circle_outline;
      case 'UPDATE':
        return Icons.edit_outlined;
      case 'DELETE':
        return Icons.delete_outline;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(action);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        action,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
