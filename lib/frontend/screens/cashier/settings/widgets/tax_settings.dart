import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/cashier_settings.dart';

class TaxSettingsWidget extends StatelessWidget {
  final CashierSettings settings;
  final TextEditingController taxCtrl;

  const TaxSettingsWidget({
    super.key,
    required this.settings,
    required this.taxCtrl,
  });

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
          const Text('Tax Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: taxCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Default Tax Rate (%)', suffixText: '%'),
          ),
        ],
      ),
    );
  }
}
