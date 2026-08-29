// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:erp_software/core/models/customer_model.dart';
import 'package:erp_software/frontend/screens/customers/customer_update.dart';
import 'package:erp_software/frontend/services/customer_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onChanged;
  const CustomerCard({super.key, required this.customer,this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showCustomerMenu(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    customer.phone,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  if (customer.email != null && customer.email!.isNotEmpty) ...[
                    const SizedBox(height: 3),

                    Text(
                      customer.email!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '₹${customer.currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            const Icon(Icons.more_vert, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showCustomerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.15),
                blurRadius: 25,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Customer header
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              customer.phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                _menuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Full Details',
                  onTap: () {
                    Navigator.pop(context);
                    _showFullDetails(context);
                  },
                ),

                _menuItem(
                  context,
                  icon: Icons.edit_outlined,
                  title: 'Update Customer',
                  onTap: () async{
                    Navigator.pop(context);
                    final updatedCustomer = await Navigator.push<CustomerModel>(
                      context,
                      MaterialPageRoute(builder: (_)=> UpdateCustomerScreen(customer: customer))
                    );
                    if(updatedCustomer != null){
                      onChanged?.call();
                    }
                  },
                  
                ),
                const Divider(height: 1),

                _menuItem(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Delete Customer',
                  iconColor: AppColors.danger,
                  textColor: AppColors.danger,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 21),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.black,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _showFullDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 650),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              customer.phone,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Details
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _infoCard(
                          icon: Icons.person_outline,
                          title: 'Name',
                          value: customer.name,
                        ),

                        _infoCard(
                          icon: Icons.phone_outlined,
                          title: 'Phone',
                          value: customer.phone,
                        ),

                        _infoCard(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: customer.email ?? '-',
                        ),

                        _infoCard(
                          icon: Icons.location_on_outlined,
                          title: 'Address',
                          value: customer.address ?? '-',
                        ),

                        _infoCard(
                          icon: Icons.card_membership_outlined,
                          title: 'Loyalty ID',
                          value: customer.loyaltyId ?? '-',
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Financial Information',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _moneyCard(
                                title: 'Credit Limit',
                                value:
                                    '₹${customer.creditLimit.toStringAsFixed(2)}',
                                icon: Icons.credit_card_outlined,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _moneyCard(
                                title: 'Balance',
                                value:
                                    '₹${customer.currentBalance.toStringAsFixed(2)}',
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (context.mounted) {
                            _showCustomerMenu(context);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }


  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Delete icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Delete Customer?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 8),

                Text(
                  'Are you sure you want to delete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  customer.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final customerId = customer.id;

                      // Check ID
                      if (customerId == null || customerId.isEmpty) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: 'Customer ID is missing',
                          ),
                        );
                        return;
                      }

                      try {
                        await CustomerService().deleteCustomer(customerId);

                        if (!context.mounted) return;

                        Navigator.pop(context);
                        onChanged?.call();
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                            message: 'Customer deleted successfully',
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        Navigator.pop(context);

                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: 'Failed to delete customer',
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Delete Customer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      side: BorderSide(color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

