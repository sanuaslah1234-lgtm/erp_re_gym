import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/core/models/product_model.dart';
import 'package:erp_software/core/models/warehouse_model.dart';
import 'package:erp_software/frontend/services/product_service.dart';
import 'package:erp_software/frontend/services/warehouse_service.dart';

import 'inventory_form_field.dart';

class InventoryAssignmentCard extends StatefulWidget {
  final String? selectedProductId;
  final String? selectedWarehouseId;

  final ValueChanged<String?> onProductChanged;
  final ValueChanged<String?> onWarehouseChanged;

  const InventoryAssignmentCard({
    super.key,
    required this.selectedProductId,
    required this.selectedWarehouseId,
    required this.onProductChanged,
    required this.onWarehouseChanged,
  });

  @override
  State<InventoryAssignmentCard> createState() =>
      _InventoryAssignmentCardState();
}

class _InventoryAssignmentCardState
    extends State<InventoryAssignmentCard> {

  final ProductService _productService =
      ProductService();

  final WarehouseService _warehouseService =
      WarehouseService();

  List<ProductModel> _products = [];
  List<WarehouseModel> _warehouses = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _productService.getProducts(),
        _warehouseService.getWarehouses(),
      ]);

      if (!mounted) return;

      setState(() {
        _products =
            results[0] as List<ProductModel>;

        _warehouses =
            results[1] as List<WarehouseModel>;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });

      debugPrint(
        'Inventory assignment error: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius:
                      BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 19,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'Assignment Details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            _ErrorView(
              message: _error!,
              onRetry: _loadData,
            )
          else ...[
            _ProductDropdown(
              products: _products,
              value: widget.selectedProductId,
              onChanged:
                  widget.onProductChanged,
            ),

            const SizedBox(height: 18),

            _WarehouseDropdown(
              warehouses: _warehouses,
              value:
                  widget.selectedWarehouseId,
              onChanged:
                  widget.onWarehouseChanged,
            ),
          ],
        ],
      ),
    );
  }
}
class _ProductDropdown extends StatelessWidget {
  final List<ProductModel> products;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _ProductDropdown({
    required this.products,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InventoryFormField(
      label: 'Product',
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,

        decoration:
            InventoryFormField.decoration(
          hintText: 'Select Product',
        ),

        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
        ),

        items: products.map((product) {
          return DropdownMenuItem<String>(
            value: product.id,
            child: Text(
              product.name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    );
  }
}
class _WarehouseDropdown
    extends StatelessWidget {

  final List<WarehouseModel> warehouses;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _WarehouseDropdown({
    required this.warehouses,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InventoryFormField(
      label: 'Warehouse',
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,

        decoration:
            InventoryFormField.decoration(
          hintText: 'Select Warehouse',
        ),

        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
        ),

        items: warehouses.map((warehouse) {
          return DropdownMenuItem<String>(
            value: warehouse.id,
            child: Text(
              warehouse.name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    );
  }
}
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 10),

        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
