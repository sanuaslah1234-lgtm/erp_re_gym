import 'package:flutter/material.dart';
import 'customer_text_field.dart';

class CustomerFormRow extends StatelessWidget {
  final TextEditingController loyaltyController;
  final TextEditingController creditController;
  final TextEditingController balanceController;

  const CustomerFormRow({
    super.key,
    required this.loyaltyController,
    required this.creditController,
    required this.balanceController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return Column(
            children: [
              CustomerTextField(
                label: 'Loyalty ID',
                hint: 'e.g. LOYAL-8899',
                controller: loyaltyController,
              ),
              const SizedBox(height: 14),
              CustomerTextField(
                label: 'Credit Limit',
                hint: '0',
                controller: creditController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              CustomerTextField(
                label: 'Current Balance',
                hint: '0',
                controller: balanceController,
                keyboardType: TextInputType.number,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: CustomerTextField(
                label: 'Loyalty ID',
                hint: 'e.g. LOYAL-8899',
                controller: loyaltyController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomerTextField(
                label: 'Credit Limit',
                hint: '0',
                controller: creditController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomerTextField(
                label: 'Current Balance',
                hint: '0',
                controller: balanceController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        );
      },
    );
  }
}
