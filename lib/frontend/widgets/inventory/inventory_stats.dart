import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class InventoryStats extends StatelessWidget {
  final int totalRecords;
  final int healthyStock;
  final int lowStock;
  final int outOfStock;

  const InventoryStats({
    super.key,
    required this.totalRecords,
    required this.healthyStock,
    required this.lowStock,
    required this.outOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width < 600) {
          columns = 2;
        } else if (width < 1000) {
          columns = 2;
        } else {
          columns = 4;
        }

        final spacing = width < 600 ? 9.0 : 12.0;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio:
              width < 600 ? 1.65 : 2.8,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: 'Total Records',
              value: '$totalRecords',
              icon: Icons.inventory_2_outlined,
              color: AppColors.primary,
              background: AppColors.primarySoft,
            ),
            _StatCard(
              title: 'Healthy Stock',
              value: '$healthyStock',
              icon: Icons.check_circle_outline,
              color: AppColors.success,
              background: AppColors.successLight,
            ),
            _StatCard(
              title: 'Low Stock',
              value: '$lowStock',
              icon: Icons.warning_amber_rounded,
              color: AppColors.warningDark,
              background: AppColors.warningLight,
            ),
            _StatCard(
              title: 'Out of Stock',
              value: '$outOfStock',
              icon: Icons.remove_shopping_cart_outlined,
              color: AppColors.danger,
              background: AppColors.dangerLight,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
