import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class InventoryFilters extends StatelessWidget {
  final String search;

  /// Currently selected warehouse ID.
  /// null = All Warehouses
  final String? selectedWarehouseId;

  final String selectedStatus;
  final String selectedSort;

  /// Dynamic warehouses from InventoryScreen.
  ///
  /// Example:
  /// [
  ///   {'id': '1', 'name': 'Main Warehouse'},
  ///   {'id': '2', 'name': 'Branch Warehouse'},
  /// ]
  final List<Map<String, String>> warehouses;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onWarehouseChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onSortChanged;

  final VoidCallback onRefresh;

  const InventoryFilters({
    super.key,

    required this.search,

    required this.selectedWarehouseId,

    required this.selectedStatus,
    required this.selectedSort,

    required this.warehouses,

    required this.onSearchChanged,
    required this.onWarehouseChanged,
    required this.onStatusChanged,
    required this.onSortChanged,

    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: AppShadows.soft,
          ),

          child: isMobile
              ? _MobileFilters(
                  search: search,
                  selectedWarehouseId:
                      selectedWarehouseId,
                  selectedStatus:
                      selectedStatus,
                  selectedSort:
                      selectedSort,
                  warehouses:
                      warehouses,
                  onSearchChanged:
                      onSearchChanged,
                  onWarehouseChanged:
                      onWarehouseChanged,
                  onStatusChanged:
                      onStatusChanged,
                  onSortChanged:
                      onSortChanged,
                  onRefresh:
                      onRefresh,
                )
              : _DesktopFilters(
                  search: search,
                  selectedWarehouseId:
                      selectedWarehouseId,
                  selectedStatus:
                      selectedStatus,
                  selectedSort:
                      selectedSort,
                  warehouses:
                      warehouses,
                  onSearchChanged:
                      onSearchChanged,
                  onWarehouseChanged:
                      onWarehouseChanged,
                  onStatusChanged:
                      onStatusChanged,
                  onSortChanged:
                      onSortChanged,
                  onRefresh:
                      onRefresh,
                ),
        );
      },
    );
  }
}

// ============================================================
// DESKTOP
// ============================================================

class _DesktopFilters extends StatelessWidget {
  final String search;

  final String? selectedWarehouseId;
  final String selectedStatus;
  final String selectedSort;

  final List<Map<String, String>> warehouses;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onWarehouseChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onSortChanged;

  final VoidCallback onRefresh;

  const _DesktopFilters({
    required this.search,
    required this.selectedWarehouseId,
    required this.selectedStatus,
    required this.selectedSort,
    required this.warehouses,
    required this.onSearchChanged,
    required this.onWarehouseChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // SEARCH
        Expanded(
          flex: 3,
          child: _SearchBox(
            value: search,
            onChanged: onSearchChanged,
          ),
        ),

        const SizedBox(width: 9),

        // WAREHOUSE
        Expanded(
          child: _WarehouseDropdown(
            selectedId: selectedWarehouseId,
            warehouses: warehouses,
            onChanged: onWarehouseChanged,
          ),
        ),

        const SizedBox(width: 9),

        // STATUS
        Expanded(
          child: _SimpleDropdown(
            value: selectedStatus,
            items: const [
              'All Statuses',
              'In Stock',
              'Low Stock',
              'Out of Stock',
            ],
            onChanged: onStatusChanged,
          ),
        ),

        const SizedBox(width: 9),

        // SORT
        Expanded(
          child: _SimpleDropdown(
            value: selectedSort,
            items: const [
              'Latest',
              'A-Z',
              'Z-A',
              'Quantity Low',
              'Quantity High',
            ],
            onChanged: onSortChanged,
          ),
        ),

        const SizedBox(width: 9),

        // REFRESH
        _RefreshButton(
          onTap: onRefresh,
        ),
      ],
    );
  }
}

// ============================================================
// MOBILE
// ============================================================

class _MobileFilters extends StatelessWidget {
  final String search;

  final String? selectedWarehouseId;
  final String selectedStatus;
  final String selectedSort;

  final List<Map<String, String>> warehouses;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onWarehouseChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onSortChanged;

  final VoidCallback onRefresh;

  const _MobileFilters({
    required this.search,
    required this.selectedWarehouseId,
    required this.selectedStatus,
    required this.selectedSort,
    required this.warehouses,
    required this.onSearchChanged,
    required this.onWarehouseChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SEARCH
        _SearchBox(
          value: search,
          onChanged: onSearchChanged,
        ),

        const SizedBox(height: 9),

        // WAREHOUSE
        _WarehouseDropdown(
          selectedId: selectedWarehouseId,
          warehouses: warehouses,
          onChanged: onWarehouseChanged,
        ),

        const SizedBox(height: 9),

        // STATUS + SORT + REFRESH
        Row(
          children: [
            Expanded(
              child: _SimpleDropdown(
                value: selectedStatus,
                items: const [
                  'All Statuses',
                  'In Stock',
                  'Low Stock',
                  'Out of Stock',
                ],
                onChanged: onStatusChanged,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _SimpleDropdown(
                value: selectedSort,
                items: const [
                  'Latest',
                  'A-Z',
                  'Z-A',
                  'Quantity Low',
                  'Quantity High',
                ],
                onChanged: onSortChanged,
              ),
            ),

            const SizedBox(width: 8),

            _RefreshButton(
              onTap: onRefresh,
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// SEARCH
// ============================================================

class _SearchBox extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,

      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textPrimary,
      ),

      decoration: InputDecoration(
        hintText:
            'Search product, SKU or warehouse...',

        hintStyle: const TextStyle(
          fontSize: 11,
          color: AppColors.textMuted,
        ),

        prefixIcon: const Icon(
          Icons.search,
          size: 19,
          color: AppColors.textMuted,
        ),

        filled: true,
        fillColor: AppColors.surfaceSecondary,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DYNAMIC WAREHOUSE DROPDOWN
// ============================================================

class _WarehouseDropdown extends StatelessWidget {
  final String? selectedId;

  final List<Map<String, String>> warehouses;

  final ValueChanged<String?> onChanged;

  const _WarehouseDropdown({
    required this.selectedId,
    required this.warehouses,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items =
        <DropdownMenuItem<String?>>[];

    // ALL WAREHOUSES
    items.add(
      const DropdownMenuItem<String?>(
        value: null,
        child: Text(
          'All Warehouses',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    // DYNAMIC WAREHOUSES
    for (final warehouse in warehouses) {
      final id = warehouse['id'];
      final name = warehouse['name'];

      if (id == null || name == null) {
        continue;
      }

      items.add(
        DropdownMenuItem<String?>(
          value: id,
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    final hasSelectedWarehouse =
        selectedId != null &&
        warehouses.any(
          (warehouse) =>
              warehouse['id'] == selectedId,
        );

    return DropdownButtonFormField<String?>(
      initialValue:
          hasSelectedWarehouse
              ? selectedId
              : null,

      onChanged: onChanged,

      isExpanded: true,

      icon: const Icon(
        Icons.keyboard_arrow_down,
        size: 17,
      ),

      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),

      decoration: _dropdownDecoration(),
      items: items,
    );
  }
}

// ============================================================
// NORMAL DROPDOWN
// ============================================================

class _SimpleDropdown extends StatelessWidget {
  final String value;
  final List<String> items;

  final ValueChanged<String?> onChanged;

  const _SimpleDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue:
          items.contains(value)
              ? value
              : items.first,

      onChanged: onChanged,

      isExpanded: true,

      icon: const Icon(
        Icons.keyboard_arrow_down,
        size: 17,
      ),

      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),

      decoration: _dropdownDecoration(),

      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }
}

// ============================================================
// DROPDOWN DECORATION
// ============================================================

InputDecoration _dropdownDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.surfaceSecondary,

    contentPadding:
        const EdgeInsets.symmetric(
      horizontal: 11,
      vertical: 2,
    ),

    border: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.border,
      ),
    ),

    enabledBorder:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.border,
      ),
    ),

    focusedBorder:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.primary,
      ),
    ),
  );
}

// ============================================================
// REFRESH BUTTON
// ============================================================

class _RefreshButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RefreshButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,

      borderRadius:
          BorderRadius.circular(10),

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(10),

        child: const SizedBox(
          width: 42,
          height: 42,

          child: Icon(
            Icons.refresh,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
