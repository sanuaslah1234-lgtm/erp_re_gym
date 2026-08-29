  import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

  import 'customer_text_field.dart';
  import 'customer_form_row.dart';
  import 'customer_form_button.dart';

  class AddCustomerCard extends StatefulWidget {
    final VoidCallback onClose;
    final VoidCallback onCancel;

    final Future<void> Function(
      String name,
      String phone,
      String? email,
      String? address,
      String? loyaltyId,
      double currentBalance,
      double creditLimit,
    ) onSave;

    const AddCustomerCard({
      super.key,
      required this.onClose,
      required this.onCancel,
      required this.onSave,
    });

    @override
    State<AddCustomerCard> createState() => _AddCustomerCardState();
  }

  class _AddCustomerCardState extends State<AddCustomerCard> {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final loyaltyController = TextEditingController();
    final creditController = TextEditingController(text: '0');
    final balanceController = TextEditingController(text: '0');
    final addressController = TextEditingController();

    bool isSaving = false;

    @override
    void dispose() {
      nameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      loyaltyController.dispose();
      creditController.dispose();
      balanceController.dispose();
      addressController.dispose();

      super.dispose();
    }

    Future<void> saveCustomer() async {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();

      if (name.isEmpty) {
        showError('Customer name is required');
        return;
      }

      if (phone.isEmpty) {
        showError('Phone number is required');
        return;
      }

      final email = emailController.text.trim();
      final address = addressController.text.trim();
      final loyaltyId = loyaltyController.text.trim();
      final currentBalance = double.tryParse(balanceController.text.trim()) ??  0;
      final creditLimit =
          double.tryParse(
            creditController.text.trim(),
          ) ??
          0;

      try {
        setState(() {
          isSaving = true;
        });

        await widget.onSave(
          name,
          phone,
          email.isEmpty ? null : email,
          address.isEmpty ? null : address,
          loyaltyId.isEmpty ? null : loyaltyId,
          currentBalance,
          creditLimit,
        );
      } catch (e) {
        if (mounted) {
          showError(e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            isSaving = false;
          });
        }
      }
    }

    void showError(String message) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.info(message: message)
      );
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFDDE2E8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Customer',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Create a new customer profile',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: widget.onClose,
                  style: IconButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(
                height: 1,
                color: AppColors.border,
              ),
            ),

            CustomerTextField(
              label: 'Customer Name',
              hint: 'e.g. John Doe',
              controller: nameController,
              required: true,
            ),

            const SizedBox(height: 16),

            CustomerTextField(
              label: 'Phone',
              hint: 'e.g. +1 (555) 019-2834',
              controller: phoneController,
              required: true,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            CustomerTextField(
              label: 'Email',
              hint: 'customer@example.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            CustomerFormRow(
              loyaltyController: loyaltyController,
              creditController: creditController,
              balanceController: balanceController,
            ),

            const SizedBox(height: 16),

            CustomerTextField(
              label: 'Address',
              hint: 'Enter street, city, state address',
              controller: addressController,
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            CustomerFormButtons(
              onCancel: widget.onCancel,
              onSave: isSaving ? () {} : saveCustomer,
            ),
          ],
        ),
      );
    }
  }
