import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';
import 'inventory_form_field.dart';

class InventoryStockLevels extends StatelessWidget {
  final TextEditingController quantityController;
  final TextEditingController minStockController;
  final TextEditingController maxStockController;
  final TextEditingController reorderLevelController;

  const InventoryStockLevels({
    super.key,
    required this.quantityController,
    required this.minStockController,
    required this.maxStockController,
    required this.reorderLevelController,
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
          const Text(
            'Stock Levels',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 22),

          InventoryNumberField(
            label: 'Initial Quantity',
            controller: quantityController,
          ),

          const SizedBox(height: 18),

          InventoryNumberField(
            label: 'Minimum Stock',
            controller: minStockController,
          ),

          const SizedBox(height: 18),

          InventoryNumberField(
            label: 'Maximum Stock',
            controller: maxStockController,
          ),

          const SizedBox(height: 18),

          InventoryNumberField(
            label: 'Reorder Level',
            controller: reorderLevelController,
          ),
        ],
      ),
    );
  }
}
