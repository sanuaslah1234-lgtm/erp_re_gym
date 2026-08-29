import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/services/inventory_service.dart';
import 'package:erp_software/frontend/widgets/addInventory/inventory_assignment_card.dart';
import 'package:erp_software/frontend/widgets/addInventory/inventory_stock_levels.dart';
import 'package:erp_software/frontend/widgets/addInventory/inventory_quick_tips.dart';

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({
    super.key,
  });

  @override
  State<AddInventoryScreen> createState() =>
      _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final InventoryService _inventoryService = InventoryService();

  String? selectedProductId;
  String? selectedWarehouseId;

  final quantityController =
      TextEditingController(text: '0');

  final minStockController =
      TextEditingController(text: '10');

  final maxStockController =
      TextEditingController(text: '1000');

  final reorderLevelController =
      TextEditingController(text: '20');

  bool _isCreating = false;

  @override
  void dispose() {
    quantityController.dispose();
    minStockController.dispose();
    maxStockController.dispose();
    reorderLevelController.dispose();

    super.dispose();
  }

  Future<void> _createInventory() async {
    // Validate product
    if (selectedProductId == null ||
        selectedProductId!.isEmpty) {
      _showMessage(
        'Please select a product',
        isError: true,
      );
      return;
    }

    // Validate warehouse
    if (selectedWarehouseId == null ||
        selectedWarehouseId!.isEmpty) {
      _showMessage(
        'Please select a warehouse',
        isError: true,
      );
      return;
    }

    final quantity =
        int.tryParse(quantityController.text.trim());

    final minStock =
        int.tryParse(minStockController.text.trim());

    final maxStock =
        int.tryParse(maxStockController.text.trim());

    final reorderLevel =
        int.tryParse(reorderLevelController.text.trim());

    if (quantity == null ||
        minStock == null ||
        maxStock == null ||
        reorderLevel == null) {
      _showMessage(
        'Please enter valid stock values',
        isError: true,
      );
      return;
    }

    if (minStock > maxStock) {
      _showMessage(
        'Minimum stock cannot be greater than maximum stock',
        isError: true,
      );
      return;
    }

    if (reorderLevel < minStock ||
        reorderLevel > maxStock) {
      _showMessage(
        'Reorder level must be between minimum and maximum stock',
        isError: true,
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final inventory =
          await _inventoryService.createInventory(
        productId: selectedProductId!,
        warehouseId: selectedWarehouseId!,
        quantity: quantity,
        minStock: minStock,
        maxStock: maxStock,
        reorderLevel: reorderLevel,
      );

      if (!mounted) return;

      _showMessage(
        'Inventory created successfully',
      );

      // Clear form after successful creation
      setState(() {
        selectedProductId = null;
        selectedWarehouseId = null;

        quantityController.text = '0';
        minStockController.text = '10';
        maxStockController.text = '1000';
        reorderLevelController.text = '20';
      });

      debugPrint(
        'Created inventory: ${inventory.id}',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            14,
            16,
            14,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              InventoryAssignmentCard(
                selectedProductId:
                    selectedProductId,
                selectedWarehouseId:
                    selectedWarehouseId,

                onProductChanged: (value) {
                  setState(() {
                    selectedProductId = value;
                  });
                },

                onWarehouseChanged: (value) {
                  setState(() {
                    selectedWarehouseId = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              InventoryStockLevels(
                quantityController:
                    quantityController,
                minStockController:
                    minStockController,
                maxStockController:
                    maxStockController,
                reorderLevelController:
                    reorderLevelController,
              ),

              const SizedBox(height: 16),

              const InventoryQuickTips(),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _isCreating
                          ? null
                          : _createInventory,
                  child: _isCreating
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Inventory',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}