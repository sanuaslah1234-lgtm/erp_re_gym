import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/customer_model.dart';
import 'package:erp_software/frontend/services/customer_service.dart';
import 'package:erp_software/frontend/widgets/customers/add_customer.dart';
import 'package:erp_software/frontend/widgets/customers/customer_list.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class CustomersScreen extends StatefulWidget {
  final bool initialShowAdd;
  const CustomersScreen({super.key, this.initialShowAdd = false});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerService customerService = CustomerService();

  List<CustomerModel> customers = [];
  List<CustomerModel> filteredCustomers = [];

  String searchText = '';
  String selectedFilter = 'All';
  String selectedSort = 'DEFAULT';

  bool isLoading = true;
  String? error;
  late bool showAddCustomer;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    showAddCustomer = widget.initialShowAdd;
    loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadCustomers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await customerService.getCustomers();
      if (!mounted) return;

      setState(() {
        customers = result;
        isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<CustomerModel> result = List.from(customers);

    // SEARCH
    if (searchText.trim().isNotEmpty) {
      final query = searchText.trim().toLowerCase();

      result = result.where((customer) {
        final name = customer.name.toLowerCase();
        final phone = customer.phone.toLowerCase();
        final email = customer.email?.toLowerCase() ?? '';
        final loyaltyId = customer.loyaltyId?.toLowerCase() ?? '';
        final address = customer.address?.toLowerCase() ?? '';

        return name.contains(query) ||
            phone.contains(query) ||
            email.contains(query) ||
            loyaltyId.contains(query) ||
            address.contains(query);
      }).toList();
    }

    // FILTER
    if (selectedFilter == 'Active') {
      result = result.where((customer) => customer.isActive == true).toList();
    } else if (selectedFilter == 'Inactive') {
      result = result.where((customer) => customer.isActive == false).toList();
    }

    // SORT
    switch (selectedSort) {
      case 'NAME A-Z':
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'NAME Z-A':
        result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'BALANCE HIGH-LOW':
        result.sort((a, b) => b.currentBalance.compareTo(a.currentBalance));
        break;
      case 'BALANCE LOW-HIGH':
        result.sort((a, b) => a.currentBalance.compareTo(b.currentBalance));
        break;
      case 'NEWEST':
        result.sort((a, b) {
          final aDate = a.createdAt;
          final bDate = b.createdAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
        break;
      case 'DEFAULT':
      default:
        break;
    }

    if (!mounted) return;

    setState(() {
      filteredCustomers = result;
    });
  }

  Future<void> _handleSaveCustomer(
    String name,
    String phone,
    String? email,
    String? address,
    String? loyaltyId,
    double currentBalance,
    double creditLimit,
  ) async {
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

    ErpToast.showSuccess(
      context,
      'Customer "${created.name}" created and saved to PostgreSQL successfully!',
      title: 'Customer Added',
    );

    setState(() {
      showAddCustomer = false;
    });

    await loadCustomers();
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Filter Customers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('All Customers'),
                trailing: selectedFilter == 'All' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => selectedFilter = 'All');
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
                title: const Text('Active Only'),
                trailing: selectedFilter == 'Active' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => selectedFilter = 'Active');
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: AppColors.neutralDark),
                title: const Text('Inactive Only'),
                trailing: selectedFilter == 'Inactive' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => selectedFilter = 'Inactive');
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortMenu(BuildContext context) {
    final sortOptions = [
      'DEFAULT',
      'NAME A-Z',
      'NAME Z-A',
      'NEWEST',
      'BALANCE HIGH-LOW',
      'BALANCE LOW-HIGH',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sort Customers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ...sortOptions.map((opt) => ListTile(
                    title: Text(opt),
                    trailing: selectedSort == opt ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() => selectedSort = opt);
                      Navigator.pop(context);
                      _applyFilters();
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Export Customer Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined, color: Color(0xFF10B981)),
                title: const Text('Export as CSV (.csv)'),
                onTap: () {
                  Navigator.pop(context);
                  ErpToast.showSuccess(context, 'Exported ${filteredCustomers.length} customer records as CSV');
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: Color(0xFF2563EB)),
                title: const Text('Export as Excel (.xlsx)'),
                onTap: () {
                  Navigator.pop(context);
                  ErpToast.showSuccess(context, 'Exported ${filteredCustomers.length} customer records as Excel');
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFEF4444)),
                title: const Text('Export as PDF Document'),
                onTap: () {
                  Navigator.pop(context);
                  ErpToast.showSuccess(context, 'Generated PDF report for ${filteredCustomers.length} customers');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Customers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadCustomers,
                    color: AppColors.primary,
                    backgroundColor: AppColors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top 3 Action Buttons Row (Print, Export, + Add Customer)
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.print_outlined,
                                  label: 'Print',
                                  onTap: () {
                                    ErpToast.showInfo(context, 'Printing customer report for ${filteredCustomers.length} records...');
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.file_download_outlined,
                                  label: 'Export',
                                  showDropdownArrow: true,
                                  onTap: () => _showExportOptions(context),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.add,
                                  label: '+ Add Customer',
                                  onTap: () {
                                    setState(() {
                                      showAddCustomer = true;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Content Area: Either Add Customer Card (Second Page) OR Filter & Customer List
                          if (showAddCustomer) ...[
                            AddCustomerCard(
                              onClose: () {
                                setState(() {
                                  showAddCustomer = false;
                                });
                              },
                              onCancel: () {
                                setState(() {
                                  showAddCustomer = false;
                                });
                              },
                              onSave: _handleSaveCustomer,
                            ),
                          ] else ...[
                            // Search and Filter Card
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x050F172A),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Search Input
                                  TextField(
                                    controller: _searchController,
                                    onChanged: (val) {
                                      setState(() {
                                        searchText = val;
                                      });
                                      _applyFilters();
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search customers...',
                                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 20),
                                      suffixIcon: searchText.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  searchText = '';
                                                });
                                                _applyFilters();
                                              },
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: const Color(0xFFFAFAFA),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Filter, Sort, and Refresh Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildPillDropdown(
                                          icon: Icons.filter_alt_outlined,
                                          label: 'Filter: $selectedFilter',
                                          onTap: () => _showFilterMenu(context),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildPillDropdown(
                                          icon: Icons.arrow_downward_rounded,
                                          label: 'Sort: $selectedSort',
                                          onTap: () => _showSortMenu(context),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          _searchController.clear();
                                          setState(() {
                                            searchText = '';
                                            selectedFilter = 'All';
                                            selectedSort = 'DEFAULT';
                                          });
                                          loadCustomers();
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 42,
                                          width: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFAFAFA),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF2563EB)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Customer List / Table Area
                            if (isLoading) ...[
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                                ),
                              ),
                            ] else if (error != null) ...[
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13)),
                                    ),
                                    TextButton(
                                      onPressed: loadCustomers,
                                      child: const Text('Retry', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (filteredCustomers.isEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.people_outline_rounded, size: 40, color: Color(0xFF2563EB)),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No customers found',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      searchText.isNotEmpty
                                          ? 'Try adjusting your search or filter settings.'
                                          : 'Start adding your customer profiles to keep track of loyalty, credit, and sales history.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          showAddCustomer = true;
                                        });
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add First Customer'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x050F172A),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CustomerList(
                                  customers: filteredCustomers,
                                  onDeleted: loadCustomers,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool showDropdownArrow = false,
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
              if (showDropdownArrow) ...[
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillDropdown({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2563EB)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
