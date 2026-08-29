import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/cashier_settings.dart';

class PaymentSettingsWidget extends StatelessWidget {
  final CashierSettings settings;

  const PaymentSettingsWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Supported Payment Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const CheckboxListTile(value: true, onChanged: null, title: Text('Cash Payment (Enabled by default)')),
          const CheckboxListTile(value: true, onChanged: null, title: Text('Card Payment (Credit / Debit)')),
          const CheckboxListTile(value: true, onChanged: null, title: Text('UPI / QR Code Digital Payment')),
          const CheckboxListTile(value: true, onChanged: null, title: Text('Mixed Payment Support')),
        ],
      ),
    );
  }
}
