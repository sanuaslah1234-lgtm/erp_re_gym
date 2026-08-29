import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class InventoryQuickTips extends StatelessWidget {
  const InventoryQuickTips({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius:
                      BorderRadius.circular(9),
                ),

                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'Quick Tips',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const _Tip(
            text:
                "Ensure the product isn't already assigned to this warehouse.",
          ),

          const SizedBox(height: 16),

          const _Tip(
            text:
                'Reorder level should be higher than minimum stock.',
          ),

          const SizedBox(height: 16),

          const _Tip(
            text:
                'Initial quantity will be the starting stock count.',
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;

  const _Tip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 6,
          ),

          width: 5,
          height: 5,

          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
