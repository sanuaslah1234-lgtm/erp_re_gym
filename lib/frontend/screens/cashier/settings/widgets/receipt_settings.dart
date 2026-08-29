import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/cashier_settings.dart';

class ReceiptSettingsWidget extends StatelessWidget {
  final CashierSettings settings;
  final TextEditingController nameCtrl;
  final TextEditingController addrCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController footerCtrl;

  const ReceiptSettingsWidget({
    super.key,
    required this.settings,
    required this.nameCtrl,
    required this.addrCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.footerCtrl,
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
          const Text('Receipt Layout & Store Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Store Name')),
          const SizedBox(height: 12),
          TextFormField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Store Address')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'))),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(controller: footerCtrl, decoration: const InputDecoration(labelText: 'Receipt Footer Message')),
          const SizedBox(height: 16),
          SwitchListTile(
            value: settings.showLogo,
            title: const Text('Show Store Logo on Receipt'),
            onChanged: (val) => settings.showLogo = val,
          ),
          SwitchListTile(
            value: settings.showTax,
            title: const Text('Show Tax Breakdown'),
            onChanged: (val) => settings.showTax = val,
          ),
          SwitchListTile(
            value: settings.showCashierName,
            title: const Text('Show Cashier Name'),
            onChanged: (val) => settings.showCashierName = val,
          ),
          SwitchListTile(
            value: settings.showCustomerName,
            title: const Text('Show Customer Name'),
            onChanged: (val) => settings.showCustomerName = val,
          ),
          SwitchListTile(
            value: settings.autoPrintReceipt,
            title: const Text('Auto-Print Thermal Receipt After Checkout'),
            onChanged: (val) => settings.autoPrintReceipt = val,
          ),
        ],
      ),
    );
  }
}
