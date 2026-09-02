import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/cashier_settings.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/cashier_settings_provider.dart';
import 'package:erp_software/frontend/screens/cashier/settings/widgets/payment_settings.dart';
import 'package:erp_software/frontend/screens/cashier/settings/widgets/pos_preferences.dart';
import 'package:erp_software/frontend/screens/cashier/settings/widgets/receipt_settings.dart';
import 'package:erp_software/frontend/screens/cashier/settings/widgets/tax_settings.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class CashierSettingsScreen extends StatefulWidget {
  const CashierSettingsScreen({super.key});

  @override
  State<CashierSettingsScreen> createState() => _CashierSettingsScreenState();
}

class _CashierSettingsScreenState extends State<CashierSettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _addrCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _footerCtrl;
  late TextEditingController _taxCtrl;
  late TextEditingController _maxDiscCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _addrCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _footerCtrl = TextEditingController();
    _taxCtrl = TextEditingController();
    _maxDiscCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final provider = Provider.of<CashierSettingsProvider>(context, listen: false);
      await provider.fetchSettings(token);

      _initControllers(provider.settings);
    });
  }

  void _initControllers(CashierSettings s) {
    _nameCtrl.text = s.storeName;
    _addrCtrl.text = s.storeAddress;
    _phoneCtrl.text = s.phone;
    _emailCtrl.text = s.email;
    _footerCtrl.text = s.receiptFooter;
    _taxCtrl.text = s.defaultTaxPercentage.toStringAsFixed(1);
    _maxDiscCtrl.text = s.maximumDiscountPercentage.toStringAsFixed(1);
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _footerCtrl.dispose();
    _taxCtrl.dispose();
    _maxDiscCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<CashierSettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final isMobile = MediaQuery.of(context).size.width < 650;

    final saveButton = ElevatedButton.icon(
      onPressed: settingsProvider.isLoading
          ? null
          : () async {
              final updated = CashierSettings(
                id: settingsProvider.settings.id,
                storeName: _nameCtrl.text.trim(),
                storeAddress: _addrCtrl.text.trim(),
                phone: _phoneCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                receiptFooter: _footerCtrl.text.trim(),
                showLogo: settingsProvider.settings.showLogo,
                showTax: settingsProvider.settings.showTax,
                showCashierName: settingsProvider.settings.showCashierName,
                showCustomerName: settingsProvider.settings.showCustomerName,
                autoPrintReceipt: settingsProvider.settings.autoPrintReceipt,
                defaultTaxPercentage: double.tryParse(_taxCtrl.text) ?? 5.0,
                allowNegativeStock: settingsProvider.settings.allowNegativeStock,
                requireCustomer: settingsProvider.settings.requireCustomer,
                allowDiscount: settingsProvider.settings.allowDiscount,
                maximumDiscountPercentage: double.tryParse(_maxDiscCtrl.text) ?? 50.0,
                autoClearCart: settingsProvider.settings.autoClearCart,
              );

              final success = await settingsProvider.saveSettings(authProvider.token, updated);
              if (success && context.mounted) {
                ErpToast.showSuccess(
                  context,
                  'Cashier settings saved to PostgreSQL database!',
                );
              }
            },
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
      icon: const Icon(Icons.save, size: 18),
      label: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Cashier Module Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 12),
                              saveButton,
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Cashier Module Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              saveButton,
                            ],
                          ),
                        const SizedBox(height: 24),

                        settingsProvider.isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                            : Column(
                                children: [
                                  ReceiptSettingsWidget(
                                    settings: settingsProvider.settings,
                                    nameCtrl: _nameCtrl,
                                    addrCtrl: _addrCtrl,
                                    phoneCtrl: _phoneCtrl,
                                    emailCtrl: _emailCtrl,
                                    footerCtrl: _footerCtrl,
                                  ),
                                  const SizedBox(height: 20),
                                  TaxSettingsWidget(settings: settingsProvider.settings, taxCtrl: _taxCtrl),
                                  const SizedBox(height: 20),
                                  PosPreferencesWidget(settings: settingsProvider.settings, maxDiscCtrl: _maxDiscCtrl),
                                  const SizedBox(height: 20),
                                  PaymentSettingsWidget(settings: settingsProvider.settings),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

