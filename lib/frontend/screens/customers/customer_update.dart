import 'package:erp_software/frontend/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/customer_model.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UpdateCustomerScreen extends StatefulWidget {
  final CustomerModel customer;

  const UpdateCustomerScreen({
    super.key,
    required this.customer,
  });

  @override
  State<UpdateCustomerScreen> createState() =>
      _UpdateCustomerScreenState();
}

class _UpdateCustomerScreenState extends State<UpdateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController loyaltyIdController;
  late final TextEditingController creditLimitController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.customer.name);

    phoneController =
        TextEditingController(text: widget.customer.phone);

    emailController =
        TextEditingController(text: widget.customer.email ?? '');

    addressController =
        TextEditingController(text: widget.customer.address ?? '');

    loyaltyIdController =
        TextEditingController(text: widget.customer.loyaltyId ?? '');

    creditLimitController = TextEditingController(
      text: widget.customer.creditLimit.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    loyaltyIdController.dispose();
    creditLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
        ),

        title: const Text(
          'Update Customer',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 850,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        _customerHeader(),

                        const SizedBox(height: 24),

                        const Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Update customer details',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _card(
                          child: Column(
                            children: [

                              _textField(
                                controller: nameController,
                                label: 'Customer Name',
                                hint: 'Enter customer name',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Customer name is required';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              _textField(
                                controller: phoneController,
                                label: 'Phone Number',
                                hint: 'Enter phone number',
                                icon: Icons.phone_outlined,
                                keyboardType:
                                    TextInputType.phone,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              _textField(
                                controller: emailController,
                                label: 'Email Address',
                                hint: 'Enter email address',
                                icon: Icons.email_outlined,
                                keyboardType:
                                    TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      !value.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              _textField(
                                controller: addressController,
                                label: 'Address',
                                hint: 'Enter customer address',
                                icon: Icons.location_on_outlined,
                                maxLines: 3,
                              ),

                              const SizedBox(height: 16),

                              _textField(
                                controller: loyaltyIdController,
                                label: 'Loyalty ID',
                                hint: 'Enter loyalty ID',
                                icon: Icons.card_membership_outlined,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Financial Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Update customer financial settings',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _card(
                          child: Column(
                            children: [

                              _textField(
                                controller: creditLimitController,
                                label: 'Credit Limit',
                                hint: '0.00',
                                icon: Icons.credit_card_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),

                              const SizedBox(height: 16),

                              _readOnlyField(
                                label: 'Current Balance',
                                value:
                                    '₹${widget.customer.currentBalance.toStringAsFixed(2)}',
                                icon: Icons
                                    .account_balance_wallet_outlined,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          children: [

                            Expanded(
                              flex: 35,
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        AppColors.textPrimary,
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              flex: 65,
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _updateCustomer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.primary,
                                    foregroundColor:
                                        AppColors.white,
                                    elevation: 0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save_outlined,
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _customerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 32,
            backgroundColor:
                AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              widget.customer.name.isNotEmpty
                  ? widget.customer.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.customer.phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.edit_outlined,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: child,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 7),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),

            filled: true,
            fillColor: AppColors.background,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _readOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 7),

        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.pageBackground,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customerId = widget.customer.id;
      if (customerId == null || customerId.isEmpty) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(message: "Customer ID is missing")
    );
    return;
  }
   try {
    final updatedCustomer = CustomerModel(
      id: customerId,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      address: addressController.text.trim().isEmpty
          ? null
          : addressController.text.trim(),
      loyaltyId: loyaltyIdController.text.trim().isEmpty
          ? null
          : loyaltyIdController.text.trim(),

      creditLimit:
          double.tryParse(creditLimitController.text.trim()) ?? 0,

      // Keep the existing balance
      currentBalance: widget.customer.currentBalance,
    );
    final updated = await CustomerService().updateCustomer(
      customerId,
      updatedCustomer
    );

    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context), 
      CustomSnackBar.success(message: "Customer updated successfully")
    );
    Navigator.pop(context, updated);
  }catch(e){
    if(!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: "Failed to update customer id")
    );
  }
  }
}
