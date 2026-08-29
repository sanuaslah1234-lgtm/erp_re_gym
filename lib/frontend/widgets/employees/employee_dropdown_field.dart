import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class EmployeeDropdownField
    extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final IconData icon;

  final bool required;

  final List<String> items;

  final ValueChanged<String?> onChanged;

  const EmployeeDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.danger,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 7),

        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(
              icon,
              size: 19,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 2,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
          items: items.map(
            (item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}
