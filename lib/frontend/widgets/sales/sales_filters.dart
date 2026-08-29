import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class SalesFilters extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCustomerChanged;
  final ValueChanged<String> onPaymentChanged;

  const SalesFilters({
    super.key,
    required this.onSearchChanged,
    required this.onCustomerChanged,
    required this.onPaymentChanged,
  });

  @override
  State<SalesFilters> createState() =>
      _SalesFiltersState();
}

class _SalesFiltersState
    extends State<SalesFilters> {
  final searchController =
      TextEditingController();

  String customer = 'All Customers';
  String payment = 'All Payments';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        12,
      ),
      color: AppColors.pageBackground,
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged:
                widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search Invoice...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 21,
              ),
              filled: true,
              fillColor:
                  AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(11),
                borderSide: BorderSide(
                  color: AppColors.border,
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(11),
                borderSide: BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  value: customer,
                  items: const [
                    'All Customers',
                    'Salman',
                    'Walk-in Customer',
                  ],
                  onChanged: (value) {
                    setState(() {
                      customer = value;
                    });

                    widget.onCustomerChanged(
                      value,
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _FilterDropdown(
                  value: payment,
                  items: const [
                    'All Payments',
                    'Cash',
                    'Card',
                    'UPI',
                  ],
                  onChanged: (value) {
                    setState(() {
                      payment = value;
                    });

                    widget.onPaymentChanged(
                      value,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown
    extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
