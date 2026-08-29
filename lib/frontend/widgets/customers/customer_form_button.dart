import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
class CustomerFormButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const CustomerFormButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(90, 48),
            side: const BorderSide(
              color: AppColors.border
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(
                Icons.save_outlined,
                size: 19,
              ),
              label: const Text(
                'Save Customer',
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
