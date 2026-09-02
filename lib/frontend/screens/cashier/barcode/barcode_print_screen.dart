import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/barcode_provider.dart';
import 'package:erp_software/frontend/screens/cashier/barcode/widgets/barcode_products_table.dart';
import 'package:erp_software/frontend/screens/cashier/barcode/widgets/label_print_settings_card.dart';
import 'package:erp_software/frontend/screens/cashier/barcode/widgets/live_print_sheet_grid.dart';
import 'package:provider/provider.dart';

class BarcodePrintScreen extends StatefulWidget {
  const BarcodePrintScreen({super.key});

  @override
  State<BarcodePrintScreen> createState() => _BarcodePrintScreenState();
}

class _BarcodePrintScreenState extends State<BarcodePrintScreen> {
  int _mobileTab = 0; // 0: Products, 1: Settings, 2: Print Sheet

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<BarcodeProvider>(context, listen: false).fetchProductsAndHistory(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final barcodeProvider = Provider.of<BarcodeProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    final totalLabelsCount = barcodeProvider.selectedProducts.fold(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const HamburgerButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Barcode Printing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sub-header Text
            const Text(
              'Generate, customize, and print high-density barcodes & price tags for inventory.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),

            // Main Content Area
            Expanded(
              child: isMobile
                  ? _buildMobileCard(barcodeProvider, totalLabelsCount)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Panel: Label & Print Settings
                        const SizedBox(
                          width: 320,
                          child: SingleChildScrollView(
                            child: LabelPrintSettingsCard(),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Panel: Select Products / Live Print Sheet
                        Expanded(
                          child: _buildDesktopCard(barcodeProvider, totalLabelsCount),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCard(BarcodeProvider provider, int totalLabelsCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mobile Top Tabs: Products, Settings, Live Sheet
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton(
                    label: 'Products (${provider.checkedProductIds.length})',
                    icon: Icons.grid_view_rounded,
                    isActive: _mobileTab == 0,
                    onTap: () => setState(() => _mobileTab = 0),
                  ),
                  const SizedBox(width: 12),
                  _buildTabButton(
                    label: 'Settings',
                    icon: Icons.tune_rounded,
                    isActive: _mobileTab == 1,
                    onTap: () => setState(() => _mobileTab = 1),
                  ),
                  const SizedBox(width: 12),
                  _buildTabButton(
                    label: 'Print Sheet ($totalLabelsCount)',
                    icon: Icons.visibility_outlined,
                    isActive: _mobileTab == 2,
                    onTap: () => setState(() => _mobileTab = 2),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                : (_mobileTab == 0
                    ? const BarcodeProductsTable()
                    : (_mobileTab == 1
                        ? const SingleChildScrollView(
                            padding: EdgeInsets.all(12),
                            child: LabelPrintSettingsCard(),
                          )
                        : const LivePrintSheetGrid())),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCard(BarcodeProvider provider, int totalLabelsCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar with Tabs & Preset Qty Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tabs: Select Products & Live Print Sheet
                  Row(
                    children: [
                      _buildTabButton(
                        label: 'Select Products (${provider.checkedProductIds.length})',
                        icon: Icons.grid_view_rounded,
                        isActive: provider.activeTab == 0,
                        onTap: () => provider.setActiveTab(0),
                      ),
                      const SizedBox(width: 16),
                      _buildTabButton(
                        label: 'Live Print Sheet ($totalLabelsCount Labels)',
                        icon: Icons.visibility_outlined,
                        isActive: provider.activeTab == 1,
                        onTap: () => provider.setActiveTab(1),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),

                  // Preset Qty Buttons Row (1, 5, 10)
                  Row(
                    children: [
                      const Text('Preset Qty:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(width: 8),
                      _buildPresetQtyButton('1', provider),
                      const SizedBox(width: 4),
                      _buildPresetQtyButton('5', provider),
                      const SizedBox(width: 4),
                      _buildPresetQtyButton('10', provider),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Content View
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                : (provider.activeTab == 0
                    ? const BarcodeProductsTable()
                    : const LivePrintSheetGrid()),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetQtyButton(String text, BarcodeProvider provider) {
    final qty = int.parse(text);

    return InkWell(
      onTap: () => provider.setPresetQty(qty),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
        ),
      ),
    );
  }
}

