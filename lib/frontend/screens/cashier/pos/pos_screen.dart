import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/pos_provider.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/cart_panel.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/product_grid.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/product_search_bar.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<PosProvider>(context, listen: false).fetchProducts(token);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyEvents,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: isMobile ? const Drawer(child: ErpSidebar(isDrawer: true)) : null,
        body: Row(
          children: [
            if (!isMobile) const ErpSidebar(activeItem: 'POS'),
            Expanded(
              child: Column(
                children: [
                  const ErpTopbar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: isMobile
                          ? Column(
                              children: [
                                _buildProductSection(posProvider, authProvider),
                                const SizedBox(height: 16),
                                const SizedBox(height: 450, child: CartPanel()),
                              ],
                            )
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
      ),
    );
  }

  Widget _buildProductSection(PosProvider posProvider, AuthProvider authProvider) {
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

        // Dropdowns Row: All Categories | All Brands | Grid View
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: posProvider.selectedCategoryId,
                    hint: const Text('All Categories', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Categories', style: TextStyle(fontSize: 12)),
                      ),
                      ...posProvider.categories.map((cat) {
                        return DropdownMenuItem<int?>(
                          value: cat['id'] as int,
                          child: Text(cat['name'].toString(), style: const TextStyle(fontSize: 12)),
                        );
                      }),
                    ],
                    onChanged: (val) => posProvider.selectCategory(val, authProvider.token),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'All Brands',
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                    items: const [
                      DropdownMenuItem(value: 'All Brands', child: Text('All Brands', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Apple', child: Text('Apple', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Samsung', child: Text('Samsung', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (_) {},
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 4),
                  Text('Grid', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Categories / Tags Filter Pills (All / iphone 15)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              InkWell(
                onTap: () => posProvider.selectCategory(null, authProvider.token),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.grid_view, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'All',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.more_horiz, color: Color(0xFF64748B), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'iphone 15',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
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

