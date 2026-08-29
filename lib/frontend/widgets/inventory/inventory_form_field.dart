import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class InventoryFormField extends StatelessWidget {
  final String label;
  final Widget child;

  const InventoryFormField({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 7),

        child,
      ],
    );
  }

  static InputDecoration decoration({
    String? hintText,
  }) {
    return InputDecoration(
      hintText: hintText,

      filled: true,
      fillColor: AppColors.surface,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),

      hintStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.3,
        ),
      ),
    );
  }
}

class InventoryNumberField
    extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const InventoryNumberField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return InventoryFormField(
      label: label,

      child: TextFormField(
        controller: controller,

        keyboardType:
            TextInputType.number,

        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary,
        ),

        decoration:
            InventoryFormField.decoration(),
      ),
    );
  }
}
