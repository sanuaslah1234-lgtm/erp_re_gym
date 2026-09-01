import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_payment_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/gym/add_payment_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/payment_receipt_dialog.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymPaymentsScreen extends StatefulWidget {
  final String initialStatus;

  const GymPaymentsScreen({super.key, this.initialStatus = 'All'});

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const HamburgerButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        actions: [
          IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => AddPaymentDialog(onSaved: loadPayments)),
            icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
            tooltip: 'Record Payment',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadPayments,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(child: _summaryCard('COLLECTED', _totalCollected, const Color(0xFFDCFCE7), const Color(0xFF15803D))),
                  const SizedBox(width: 10),
                  Expanded(child: _summaryCard('PENDING', _totalPending, const Color(0xFFFEE2E2), const Color(0xFFDC2626))),
                ],
              ),
              const SizedBox(height: 14),

              // Tab Pills
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

              // Search
              TextField(
                onChanged: (v) {
                  setState(() => _searchQuery = v);
                  _applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Search payments...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 14),

              // Content
              if (_isLoading)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else if (_error != null)
                _buildErrorBanner()
              else if (_filteredPayments.isEmpty)
                _buildEmptyState()
              else
                ...(_filteredPayments.map((p) => _paymentCard(p))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, double amount, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
        ],
      ),
    );
  }

  Widget _paymentCard(GymPaymentModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.memberName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Ref: ${p.referenceNumber ?? "PAY-${p.id}"}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              _buildStatusBadge(p.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(Icons.calendar_today_rounded, p.paymentDate.toIso8601String().split('T').first),
              const SizedBox(width: 6),
              _infoChip(Icons.payment_rounded, p.paymentMethod),
              const Spacer(),
              Text('\$${p.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (p.id != null) {
                  showDialog(context: context, builder: (_) => PaymentReceiptDialog(paymentId: p.id!));
                }
              },
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text('View Receipt', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: const Color(0xFF64748B)),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 10, color: Color(0xFF475569)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTabPill(String title, int count) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = title);
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF475569))),
            const SizedBox(width: 6),
            Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12))),
          TextButton(onPressed: loadPayments, child: const Text('Retry', style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Icon(Icons.payments_rounded, size: 40, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          const Text('No payments found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          const Text('Record a payment using the + button above.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
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
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
    );
  }
}
