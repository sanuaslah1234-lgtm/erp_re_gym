import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

enum ReportTab { sales, purchase, inventory }

class ReportTabs extends StatelessWidget {
  final ReportTab selected;
  final void Function(ReportTab) onSelect;

  const ReportTabs({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            icon: Icons.attach_money,
            label: 'Sales Reports',
            selected: selected == ReportTab.sales,
            onTap: () => onSelect(ReportTab.sales),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TabButton(
            icon: Icons.shopping_bag_outlined,
            label: 'Purchase Reports',
            selected: selected == ReportTab.purchase,
            onTap: () => onSelect(ReportTab.purchase),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TabButton(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory Reports',
            selected: selected == ReportTab.inventory,
            onTap: () => onSelect(ReportTab.inventory),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.white : AppColors.textSecondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
