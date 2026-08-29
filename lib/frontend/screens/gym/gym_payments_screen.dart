import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_payment_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/gym/add_payment_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/payment_receipt_dialog.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymPaymentsScreen extends StatefulWidget {
  final String initialStatus;

  const GymPaymentsScreen({
    super.key,
    this.initialStatus = 'All',
  });

  @override
  State<GymPaymentsScreen> createState() => _GymPaymentsScreenState();
}

class _GymPaymentsScreenState extends State<GymPaymentsScreen> {
  final GymApiService gymService = GymApiService();

  List<GymPaymentModel> _allPayments = [];
  List<GymPaymentModel> _filteredPayments = [];

  late String _selectedTab;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialStatus;
    loadPayments();
  }

  Future<void> loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await gymService.getPayments();
      if (!mounted) return;
      setState(() {
        _allPayments = list;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<GymPaymentModel> list = List.from(_allPayments);

    if (_selectedTab == 'PAID') {
      list = list.where((p) => p.status.toUpperCase() == 'PAID').toList();
    } else if (_selectedTab == 'PENDING') {
      list = list.where((p) => p.status.toUpperCase() == 'PENDING' || p.status.toUpperCase() == 'PARTIAL').toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return (p.memberName?.toLowerCase().contains(q) ?? false) ||
            (p.referenceNumber?.toLowerCase().contains(q) ?? false) ||
            p.paymentMethod.toLowerCase().contains(q);
      }).toList();
    }

    setState(() {
      _filteredPayments = list;
    });
  }

  double get _totalCollected => _allPayments.where((p) => p.status == 'PAID').fold(0.0, (sum, p) => sum + p.amount);
  double get _totalPending => _allPayments.where((p) => p.status == 'PENDING' || p.status == 'PARTIAL').fold(0.0, (sum, p) => sum + p.amount);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Payments', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Payments'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadPayments,
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gym Payments & Billing',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Track membership fees, invoice receipts, and pending balances', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AddPaymentDialog(onSaved: loadPayments),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('+ Record Payment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Summary Banner Cards
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFBBF7D0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('TOTAL COLLECTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                                      const SizedBox(height: 4),
                                      Text('\$${_totalCollected.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF15803D))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('PENDING DUES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                                      const SizedBox(height: 4),
                                      Text('\$${_totalPending.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Search & Tab Filter
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
                            ),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildTabPill('All', _allPayments.length),
                                      const SizedBox(width: 8),
                                      _buildTabPill('PAID', _allPayments.where((p) => p.status.toUpperCase() == 'PAID').length),
                                      const SizedBox(width: 8),
                                      _buildTabPill('PENDING', _allPayments.where((p) => p.status.toUpperCase() == 'PENDING' || p.status.toUpperCase() == 'PARTIAL').length),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  onChanged: (v) {
                                    setState(() => _searchQuery = v);
                                    _applyFilters();
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search payments by member, reference #, method...',
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 20),
                                    filled: true,
                                    fillColor: const Color(0xFFFAFAFA),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_isLoading) ...[
                            const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.primary)))
                          ] else if (_error != null) ...[
                            _buildErrorBanner(),
                          ] else if (_filteredPayments.isEmpty) ...[
                            _buildEmptyState(),
                          ] else ...[
                            _buildPaymentsTable(isMobile),
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

  Widget _buildTabPill(String title, int count) {
    final isSelected = _selectedTab == title;

    return InkWell(
      onTap: () {
        setState(() => _selectedTab = title);
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13))),
          TextButton(onPressed: loadPayments, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: const Icon(Icons.payments_rounded, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          const Text('No payment records found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Record membership fees or service payments using the button above.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildPaymentsTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredPayments.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final p = _filteredPayments[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.memberName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('Ref: ${p.referenceNumber ?? "PAY-${p.id}"}  •  ${p.paymentDate.toIso8601String().split("T").first}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),

                if (!isMobile) ...[
                  Expanded(
                    flex: 2,
                    child: Text('Method: ${p.paymentMethod}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ),
                ],

                Text(
                  '\$${p.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 12),

                _buildStatusBadge(p.status),
                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.print_outlined, size: 18, color: AppColors.primary),
                  tooltip: 'View Receipt',
                  onPressed: () {
                    if (p.id != null) {
                      showDialog(
                        context: context,
                        builder: (_) => PaymentReceiptDialog(paymentId: p.id!),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    switch (status.toUpperCase()) {
      case 'PAID':
        bg = AppColors.successLight;
        text = AppColors.successText;
        break;
      case 'PENDING':
        bg = AppColors.warningLight;
        text = AppColors.warningText;
        break;
      case 'PARTIAL':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF2563EB);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }
}
