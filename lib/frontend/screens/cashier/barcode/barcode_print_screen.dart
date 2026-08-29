import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/barcode_provider.dart';
import 'package:erp_software/frontend/screens/cashier/barcode/widgets/barcode_products_table.dart';
import 'package:erp_software/frontend/screens/cashier/barcode/widgets/label_print_settings_card.dart';
import 'package:erp_software/frontend/screens/cashier/barcode/widgets/live_print_sheet_grid.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

class BarcodePrintScreen extends StatefulWidget {
  const BarcodePrintScreen({super.key});

  @override
  State<BarcodePrintScreen> createState() => _BarcodePrintScreenState();
}

class _BarcodePrintScreenState extends State<BarcodePrintScreen> {
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
      drawer: isMobile ? const Drawer(child: ErpSidebar(isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Barcode Print'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sub-header Text matching Image 2
                        const Text(
                          'Generate, customize, and print high-density barcodes & price tags for inventory.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Main Content Area: Left Settings Card + Right Table Card
                        Expanded(
                          child: isMobile
                              ? SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const LabelPrintSettingsCard(),
                                      const SizedBox(height: 16),
                                      _buildRightTableCard(barcodeProvider, totalLabelsCount),
                                    ],
                                  ),
                                )
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
                                      child: _buildRightTableCard(barcodeProvider, totalLabelsCount),
                                    ),
                                  ],
                                ),
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

  Widget _buildRightTableCard(BarcodeProvider provider, int totalLabelsCount) {
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

