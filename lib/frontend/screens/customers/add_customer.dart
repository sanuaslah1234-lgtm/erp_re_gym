import 'package:flutter/material.dart';
import 'package:erp_software/core/models/customer_model.dart';
import 'package:erp_software/frontend/services/customer_service.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/customers/add_customer.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final CustomerService customerService = CustomerService();
  bool isSaving = false;

  Future<void> saveCustomer({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? loyaltyId,
    required double currentBalance,
    required double creditLimit,
  }) async {
    if (name.trim().isEmpty) {
      ErpToast.showError(context, 'Customer name is required');
      return;
    }

    if (phone.trim().isEmpty) {
      ErpToast.showError(context, 'Phone number is required');
      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      final customer = CustomerModel(
        name: name.trim(),
        phone: phone.trim(),
        email: email,
        address: address,
        loyaltyId: loyaltyId,
        creditLimit: creditLimit,
        currentBalance: currentBalance,
        isActive: true,
      );

      final created = await customerService.createCustomer(customer);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ErpToast.showSuccess(
        context,
        '${created.name} added successfully to PostgreSQL database!',
        title: 'Customer Created',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ErpToast.showError(
        context,
        'Failed to add customer: ${e.toString().replaceAll('Exception: ', '')}',
        title: 'Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Customers', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Customers'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customers',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildButton(
                                icon: Icons.print_outlined,
                                label: 'Print',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildButton(
                                icon: Icons.file_download_outlined,
                                label: 'Export',
                                showArrow: true,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildButton(
                                icon: Icons.add,
                                label: '+ Add Customer',
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Add Customer Form Card
                        AddCustomerCard(
                          onClose: () => Navigator.pop(context),
                          onCancel: () => Navigator.pop(context),
                          onSave: (
                            name,
                            phone,
                            email,
                            address,
                            loyaltyId,
                            currentBalance,
                            creditLimit,
                          ) async {
                            await saveCustomer(
                              name: name,
                              phone: phone,
                              email: email,
                              address: address,
                              loyaltyId: loyaltyId,
                              currentBalance: currentBalance,
                              creditLimit: creditLimit,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    bool showArrow = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF2563EB),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
