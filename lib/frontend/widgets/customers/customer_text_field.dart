import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomerTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;

  const CustomerTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ]
                : null,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
