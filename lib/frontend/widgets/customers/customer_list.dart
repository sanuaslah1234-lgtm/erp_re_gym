import 'package:erp_software/core/models/customer_model.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'customer_card.dart';
class CustomerList extends StatelessWidget {
  final List<CustomerModel> customers;
  final VoidCallback? onDeleted;
  const CustomerList({
    super.key,
    required this.customers,
    this.onDeleted
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),

      itemCount: customers.length,

      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          color: AppColors.border,
        );
      },

      itemBuilder: (context, index) {
        final customer = customers[index];

        return CustomerCard(
          customer: customer,
          onChanged:onDeleted,
        );
      },
    );
  }
}
