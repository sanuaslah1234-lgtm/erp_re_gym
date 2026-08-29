import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

enum SettingsTab { businessProfile, localizationFinance, invoicingSales, inventoryPos, securitySystem }

class SettingsTabNav extends StatelessWidget {
  final SettingsTab selected;
  final void Function(SettingsTab) onSelect;

  const SettingsTabNav({super.key, required this.selected, required this.onSelect});

  static const _items = [
    (SettingsTab.businessProfile, Icons.business_center_outlined, 'Business Profile'),
    (SettingsTab.localizationFinance, Icons.public_outlined, 'Localization & Finance'),
    (SettingsTab.invoicingSales, Icons.description_outlined, 'Invoicing & Sales'),
    (SettingsTab.inventoryPos, Icons.shopping_cart_outlined, 'Inventory & POS'),
    (SettingsTab.securitySystem, Icons.shield_outlined, 'Security & System'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _items.map((item) {
        final isSelected = selected == item.$1;
        return Material(
          color: isSelected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onSelect(item.$1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(item.$2,
                      size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$3,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
