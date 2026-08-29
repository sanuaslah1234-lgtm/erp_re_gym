import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class InventoryActions extends StatelessWidget {
  final bool isMobile;

  final VoidCallback onAdd;
  final VoidCallback onPrint;
  final VoidCallback onExport;

  const InventoryActions({
    super.key,
    required this.isMobile,
    required this.onAdd,
    required this.onPrint,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          _ActionButton(
            icon: Icons.add,
            label: 'Add Inventory',
            primary: true,
            expanded: true,
            onTap: onAdd,
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.print_outlined,
                  label: 'Print',
                  onTap: onPrint,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _ActionButton(
                  icon: Icons.file_download_outlined,
                  label: 'Export',
                  onTap: onExport,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        _ActionButton(
          icon: Icons.print_outlined,
          label: 'Print',
          onTap: onPrint,
        ),

        const SizedBox(width: 9),

        _ActionButton(
          icon: Icons.file_download_outlined,
          label: 'Export',
          onTap: onExport,
        ),

        const SizedBox(width: 9),

        _ActionButton(
          icon: Icons.add,
          label: 'Add Inventory',
          primary: true,
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final bool expanded;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary
          ? AppColors.primary
          : AppColors.surface,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: expanded ? double.infinity : null,
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: primary
                ? null
                : Border.all(
                    color: AppColors.border,
                  ),
            boxShadow: primary
                ? AppShadows.primary
                : null,
          ),
          child: Row(
            mainAxisSize: expanded
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: primary
                    ? AppColors.white
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primary
                      ? AppColors.white
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
