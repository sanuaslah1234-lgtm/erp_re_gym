import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/pos_provider.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/cart_panel.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/held_orders_dialog.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/product_grid.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/product_search_bar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  int _mobileTabIndex = 0; // 0: Products, 1: Cart

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _keyboardFocusNode.requestFocus();
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<PosProvider>(context, listen: false).fetchProducts(token);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvents(KeyEvent event) {
    if (event is KeyDownEvent) {
      final posProvider = Provider.of<PosProvider>(context, listen: false);

      if (event.logicalKey == LogicalKeyboardKey.f2) {
        _searchFocusNode.requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.f8) {
        posProvider.holdCurrentOrder();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    // Show error/warning toast when posProvider has a message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (posProvider.errorMessage != null && mounted) {
        ErpToast.showError(context, posProvider.errorMessage!);
        posProvider.clearError();
      }
      if (posProvider.warningMessage != null && mounted) {
        ErpToast.showWarning(context, posProvider.warningMessage!);
        posProvider.clearWarning();
      }
    });

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvents,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('POS Terminal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
        body: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: isMobile
                          ? (_mobileTabIndex == 0
                              ? _buildProductSection(posProvider, authProvider)
                              : CartPanel(onBack: () => setState(() => _mobileTabIndex = 0)))
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: _buildProductSection(posProvider, authProvider)),
                                const SizedBox(width: 16),
                                const Expanded(flex: 6, child: CartPanel()),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: (isMobile && _mobileTabIndex == 0 && posProvider.itemCount > 0)
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _mobileTabIndex = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          'View Cart (${posProvider.itemCount} items)',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${posProvider.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildProductSection(PosProvider posProvider, AuthProvider authProvider) {
    // Build clean, deduplicated categories dropdown items
    final categoryItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('All Categories', style: TextStyle(fontSize: 12)),
      ),
    ];
    final seenCatIds = <int>{};
    for (final cat in posProvider.categories) {
      final catId = int.tryParse(cat['id']?.toString() ?? '');
      if (catId != null && !seenCatIds.contains(catId)) {
        seenCatIds.add(catId);
        categoryItems.add(
          DropdownMenuItem<int?>(
            value: catId,
            child: Text(cat['name']?.toString() ?? 'Category $catId', style: const TextStyle(fontSize: 12)),
          ),
        );
      }
    }
    final selectedCatValue = (posProvider.selectedCategoryId != null && seenCatIds.contains(posProvider.selectedCategoryId))
        ? posProvider.selectedCategoryId
        : null;

    // Build clean, deduplicated brands dropdown items
    final brandItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('All Brands', style: TextStyle(fontSize: 12)),
      ),
    ];
    final seenBrandIds = <int>{};
    for (final b in posProvider.brands) {
      final bId = int.tryParse(b['id']?.toString() ?? '');
      if (bId != null && !seenBrandIds.contains(bId)) {
        seenBrandIds.add(bId);
        brandItems.add(
          DropdownMenuItem<int?>(
            value: bId,
            child: Text(b['name']?.toString() ?? 'Brand $bId', style: const TextStyle(fontSize: 12)),
          ),
        );
      }
    }
    final selectedBrandValue = (posProvider.selectedBrandId != null && seenBrandIds.contains(posProvider.selectedBrandId))
        ? posProvider.selectedBrandId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Barcode Scan Bar
        ProductSearchBar(
          controller: _searchController,
          onSearchChanged: (val) => posProvider.setSearchQuery(val, authProvider.token),
          onBarcodeScanned: (barcode) {
            posProvider.scanBarcode(authProvider.token, barcode);
            _searchController.clear();
          },
        ),
        const SizedBox(height: 12),

        // Dropdowns Row: All Categories | All Brands | Held Orders
        Row(
          children: [
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: selectedCatValue,
                    hint: const Text('All Categories', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                    items: categoryItems,
                    onChanged: (val) => posProvider.selectCategory(val, authProvider.token),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: selectedBrandValue,
                    hint: const Text('All Brands', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                    items: brandItems,
                    onChanged: (val) => posProvider.selectBrand(val, authProvider.token),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const HeldOrdersDialog(),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: posProvider.heldOrders.isNotEmpty ? const Color(0xFFFEF3C7) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: posProvider.heldOrders.isNotEmpty ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pause_circle_outline,
                      size: 16,
                      color: posProvider.heldOrders.isNotEmpty ? const Color(0xFFD97706) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Held (${posProvider.heldOrders.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: posProvider.heldOrders.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                        color: posProvider.heldOrders.isNotEmpty ? const Color(0xFFD97706) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Categories / Tags Filter Pills (dynamic from database)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              InkWell(
                onTap: () => posProvider.selectCategory(null, authProvider.token),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: posProvider.selectedCategoryId == null
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.grid_view, color: posProvider.selectedCategoryId == null ? Colors.white : const Color(0xFF64748B), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: posProvider.selectedCategoryId == null ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...seenCatIds.map((cId) {
                final cat = posProvider.categories.firstWhere((c) => int.tryParse(c['id']?.toString() ?? '') == cId, orElse: () => {'id': cId, 'name': 'Category $cId'});
                final isSelected = posProvider.selectedCategoryId == cId;
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () => posProvider.selectCategory(cId, authProvider.token),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cat['name'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Products Grid View
        Expanded(
          child: posProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : ProductGrid(
                  products: posProvider.products,
                  onProductTap: (product) => posProvider.addToCart(product),
                ),
        ),
      ],
    );
  }
}
