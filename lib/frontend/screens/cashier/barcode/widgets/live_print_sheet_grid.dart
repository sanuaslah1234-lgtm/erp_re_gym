import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/barcode_provider.dart';
import 'package:erp_software/frontend/widgets/common/barcode_widget.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class LivePrintSheetGrid extends StatelessWidget {
  const LivePrintSheetGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BarcodeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Expand items by quantity for the print sheet grid
    final List<_LabelItem> labelItems = [];
    for (final item in provider.selectedProducts) {
      for (int i = 0; i < item.quantity; i++) {
        labelItems.add(_LabelItem(
          name: item.product.name,
          sku: item.product.productCode,
          barcode: item.product.barcode ?? item.product.productCode,
          price: item.product.sellingPrice,
        ));
      }
    }

    return Column(
      children: [
        // Action Bar for Print
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Print Sheet Preview (${labelItems.length} Labels)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              ElevatedButton.icon(
                onPressed: labelItems.isEmpty || provider.isLoading
                    ? null
                    : () async {
                        final success = await provider.printLabels(authProvider.token);
                        if (success && context.mounted) {
                          ErpToast.showSuccess(
                            context,
                            'Labels sent to printer & history recorded in database!',
                            title: 'Printing Labels',
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Print Labels & Save', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Printable Labels Grid
        Expanded(
          child: labelItems.isEmpty
              ? const Center(
                  child: Text(
                    'No labels selected for print sheet.\nCheck product checkboxes in "Select Products" tab.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisExtent: 140,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: labelItems.length,
                  itemBuilder: (context, index) {
                    final item = labelItems[index];
                    return _buildLabelCard(provider, item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLabelCard(BarcodeProvider provider, _LabelItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black54, width: 1.2),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Store Header
          if (provider.showStoreHeader)
            Text(
              provider.storeHeader.toUpperCase(),
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          // Product Name
          if (provider.showProductName) ...[
            const SizedBox(height: 2),
            Text(
              item.name,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 4),

          // Barcode Lines
          BarcodeWidget(
            data: item.barcode,
            height: provider.barcodeHeight.clamp(20.0, 50.0),
            showText: false,
            color: Colors.black,
          ),

          // Barcode Text / SKU
          if (provider.showBarcodeText || provider.showSkuCode) ...[
            const SizedBox(height: 2),
            Text(
              provider.showBarcodeText ? item.barcode : 'SKU: ${item.sku}',
              style: TextStyle(
                fontSize: provider.textSize.clamp(8.0, 12.0),
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Price Tag
          if (provider.showPriceTag) ...[
            const SizedBox(height: 2),
            Text(
              'PRICE: ₹${item.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabelItem {
  final String name;
  final String sku;
  final String barcode;
  final double price;

  _LabelItem({
    required this.name,
    required this.sku,
    required this.barcode,
    required this.price,
  });
}

