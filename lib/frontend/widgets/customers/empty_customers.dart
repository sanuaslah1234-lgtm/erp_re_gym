import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class EmptyCustomers extends StatelessWidget {
  const EmptyCustomers({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration:  BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutralLight
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 58,
              color: AppColors.neutral
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'No customers found.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.neutral,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
