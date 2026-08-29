import 'package:erp_software/frontend/screens/customers/add_customer.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomerActions extends StatelessWidget {
  const CustomerActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.print_outlined,
            title: 'Print',
            onTap: () {},
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _ActionButton(
            icon: Icons.download_outlined,
            title: 'Export',
            showArrow: true,
            onTap: () {},
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _ActionButton(
            icon: Icons.add,
            title: 'Add Customer',
            dark: true,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool dark;
  final bool showArrow;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.dark = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: AppColors.white),

              const SizedBox(width: 6),

              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),

              if (showArrow) ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 17,
                  color: AppColors.white
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

