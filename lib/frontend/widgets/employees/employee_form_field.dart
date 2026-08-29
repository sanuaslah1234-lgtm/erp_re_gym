import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class EmployeeFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;

  final bool required;
  final bool obscureText;

  final TextInputType? keyboardType;

  final Widget? suffixIcon;

  final String? Function(String?)? validator;

  const EmployeeFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
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

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 19,
              color: AppColors.textSecondary,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 14,
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
            errorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.danger,
              ),
            ),
            focusedErrorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.danger,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
