import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/cashier_settings.dart';

class PosPreferencesWidget extends StatelessWidget {
  final CashierSettings settings;
  final TextEditingController maxDiscCtrl;

  const PosPreferencesWidget({
    super.key,
    required this.settings,
    required this.maxDiscCtrl,
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
          const Text('POS Operations & Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SwitchListTile(
            value: settings.allowNegativeStock,
            title: const Text('Allow Negative Stock Checkout'),
            subtitle: const Text('Permit sales even if product quantity is zero'),
            onChanged: (val) => settings.allowNegativeStock = val,
          ),
          SwitchListTile(
            value: settings.requireCustomer,
            title: const Text('Require Customer Selection Before Payment'),
            onChanged: (val) => settings.requireCustomer = val,
          ),
          SwitchListTile(
            value: settings.allowDiscount,
            title: const Text('Allow Manual Item / Order Discounts'),
            onChanged: (val) => settings.allowDiscount = val,
          ),
          SwitchListTile(
            value: settings.autoClearCart,
            title: const Text('Auto Clear Cart After Order Completion'),
            onChanged: (val) => settings.autoClearCart = val,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: maxDiscCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Maximum Allowed Discount %', suffixText: '%'),
          ),
        ],
      ),
    );
  }
}
