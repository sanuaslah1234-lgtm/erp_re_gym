import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/constants/app_constants.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class _Invoice {
  final int id;
  final String orderNumber;
  final double grandTotal;
  final String paymentStatus;
  final String orderStatus;
  final DateTime createdAt;

  _Invoice({required this.id, required this.orderNumber, required this.grandTotal, required this.paymentStatus, required this.orderStatus, required this.createdAt});

  factory _Invoice.fromJson(Map<String, dynamic> json) {
    return _Invoice(
      id: json['id'] ?? 0,
      orderNumber: (json['order_number'] ?? '').toString(),
      grandTotal: _parseDouble(json['grand_total']),
      paymentStatus: (json['payment_status'] ?? 'paid').toString(),
      orderStatus: (json['order_status'] ?? 'paid').toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static double _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }
}

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<_Invoice> _invoices = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.get(Uri.parse('${AppConstants.apiBaseUrl}/api/cashier/orders'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data = decoded is List ? decoded : (decoded is Map ? (decoded['data'] ?? []) : []);
        if (mounted) setState(() { _invoices = data.map((e) => _Invoice.fromJson(e)).toList(); _isLoading = false; });
      } else {
        if (mounted) setState(() { _error = 'Failed to load invoices (${res.statusCode})'; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  List<_Invoice> get _filtered {
    if (_search.isEmpty) return _invoices;
    final q = _search.toLowerCase();
    return _invoices.where((i) => i.orderNumber.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Invoices', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('View all POS invoices and receipts', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
                          child: Row(children: [
                            Expanded(child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: InputDecoration(hintText: 'Search invoices...', prefixIcon: const Icon(Icons.search, size: 18), isDense: true, filled: true, fillColor: AppColors.surfaceSecondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            )),
                            const SizedBox(width: 8),
                            Text('${_filtered.length} invoice${_filtered.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.refresh, color: AppColors.textSecondary), onPressed: _loadInvoices),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                        else if (_error != null)
                          Container(
                            width: double.infinity, padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.danger)),
                            child: Column(children: [
                              const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(onPressed: _loadInvoices, icon: const Icon(Icons.refresh), label: const Text('Retry')),
                            ]),
                          )
                        else if (_filtered.isEmpty)
                          Container(
                            width: double.infinity, padding: const EdgeInsets.all(50),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                            child: Column(children: const [
                              Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
                              SizedBox(height: 14),
                              Text('No invoices found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              SizedBox(height: 5),
                              Text('Invoices are created when POS orders are placed.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ]),
                          )
                        else
                          _buildTable(_filtered),
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

  Widget _buildTable(List<_Invoice> invoices) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 750,
          child: Column(children: [
            Container(
              height: 44, padding: const EdgeInsets.symmetric(horizontal: 20), color: AppColors.surfaceSecondary,
              child: const Row(children: [
                SizedBox(width: 130, child: Text('INVOICE #', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 120, child: Text('DATE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('TOTAL', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('PAYMENT', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('STATUS', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('ACTION', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...List.generate(invoices.length, (index) {
              final inv = invoices[index];
              final isLast = index == invoices.length - 1;
              final dateStr = '${inv.createdAt.day}/${inv.createdAt.month}/${inv.createdAt.year}';
              final isPaid = inv.paymentStatus == 'paid';
              return Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight))),
                child: Row(children: [
                  SizedBox(width: 130, child: Text(inv.orderNumber, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 120, child: Text(dateStr, style: const TextStyle(color: AppColors.textSecondary))),
                  SizedBox(width: 100, child: Text('\$${inv.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                  SizedBox(width: 100, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isPaid ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(inv.paymentStatus.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isPaid ? AppColors.success : AppColors.warning)),
                  )),
                  SizedBox(width: 100, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(inv.orderStatus.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                  )),
                  SizedBox(width: 100, child: IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    onPressed: () => ErpToast.showInfo(context, 'Invoice ${inv.orderNumber}', title: 'Invoice Details'),
                  )),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }
}
