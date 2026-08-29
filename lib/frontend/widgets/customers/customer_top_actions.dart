import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomerTopActions extends StatelessWidget {
  final VoidCallback onPrint;
  final VoidCallback onExport;
  final VoidCallback onAdd;

  const CustomerTopActions({
    super.key,
    required this.onPrint,
    required this.onExport,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.print_outlined,
            text: 'Print',
            onPressed: onPrint,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _ActionButton(
            icon: Icons.download_outlined,
            text: 'Export',
            arrow: true,
            onPressed: onExport,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _ActionButton(
            icon: Icons.add,
            text: 'Add Customer',
            dark: true,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool dark;
  final bool arrow;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.dark = false,
    this.arrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              AppColors.white,
          foregroundColor:
              AppColors.primary,
          side: BorderSide(
            color: AppColors.border
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding:  EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),

            const SizedBox(width: 5),

            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (arrow)
              const Icon(
                Icons.keyboard_arrow_down,
                size: 17,
              ),
          ],
        ),
      ),
    );
  }
}
