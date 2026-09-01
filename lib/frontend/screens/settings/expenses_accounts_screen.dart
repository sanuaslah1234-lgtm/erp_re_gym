import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/config/app_config.dart';
import 'package:erp_software/theme/app_colors.dart';

class _Expense {
  final String id;
  final String paymentMethod;
  final double amount;
  final String? referenceNumber;
  final String? orderNumber;
  final DateTime createdAt;
  _Expense({required this.id, required this.paymentMethod, required this.amount, this.referenceNumber, this.orderNumber, required this.createdAt});
  factory _Expense.fromJson(Map<String, dynamic> json) => _Expense(
    id: json['id'].toString(),
    paymentMethod: (json['payment_method'] ?? 'cash').toString(),
    amount: _parseDouble(json['amount']),
    referenceNumber: json['reference_number']?.toString(),
    orderNumber: json['order_number']?.toString(),
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
  );
  static double _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }
}

class ExpensesAccountsScreen extends StatefulWidget {
  const ExpensesAccountsScreen({super.key});

  @override
  State<ExpensesAccountsScreen> createState() => _ExpensesAccountsScreenState();
}

class _ExpensesAccountsScreenState extends State<ExpensesAccountsScreen> {
  List<_Expense> _expenses = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/expenses'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data = decoded is List ? decoded : (decoded is Map ? (decoded['data'] ?? []) : []);
        if (mounted) setState(() { _expenses = data.map((e) => _Expense.fromJson(e)).toList(); _isLoading = false; });
      } else {
        if (mounted) setState(() { _error = 'Failed to load expenses (${res.statusCode})'; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  List<_Expense> get _filtered {
    if (_search.isEmpty) return _expenses;
    final q = _search.toLowerCase();
    return _expenses.where((e) => e.paymentMethod.toLowerCase().contains(q) || (e.orderNumber?.toLowerCase().contains(q) ?? false)).toList();
  }

  double get _totalAmount => _filtered.fold(0.0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
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
                        const Text('Expenses & Accounts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Track payment transactions and account balances', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),
                        // Summary cards
                        Row(children: [
                          _summaryCard('Total Transactions', '${_filtered.length}', Icons.receipt_long, const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
                          const SizedBox(width: 16),
                          _summaryCard('Total Amount', '\$${_totalAmount.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF10B981), const Color(0xFFD1FAEFE)),
                        ]),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
                          child: Row(children: [
                            Expanded(child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: InputDecoration(hintText: 'Search transactions...', prefixIcon: const Icon(Icons.search, size: 18), isDense: true, filled: true, fillColor: AppColors.surfaceSecondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            )),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.refresh, color: AppColors.textSecondary), onPressed: _loadExpenses),
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
                              ElevatedButton.icon(onPressed: _loadExpenses, icon: const Icon(Icons.refresh), label: const Text('Retry')),
                            ]),
                          )
                        else if (_filtered.isEmpty)
                          Container(
                            width: double.infinity, padding: const EdgeInsets.all(50),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                            child: Column(children: const [
                              Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textMuted),
                              SizedBox(height: 14),
                              Text('No transactions found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              SizedBox(height: 5),
                              Text('Payment transactions will appear here.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

  Widget _summaryCard(String title, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildTable(List<_Expense> expenses) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 800,
          child: Column(children: [
            Container(
              height: 44, padding: const EdgeInsets.symmetric(horizontal: 20), color: AppColors.surfaceSecondary,
              child: const Row(children: [
                SizedBox(width: 130, child: Text('DATE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 120, child: Text('METHOD', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 120, child: Text('ORDER #', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 100, child: Text('REFERENCE', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                SizedBox(width: 120, child: Text('AMOUNT', style: TextStyle(fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...List.generate(expenses.length, (index) {
              final e = expenses[index];
              final isLast = index == expenses.length - 1;
              final dateStr = '${e.createdAt.day}/${e.createdAt.month}/${e.createdAt.year}';
              final isCash = e.paymentMethod == 'cash';
              return Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight))),
                child: Row(children: [
                  SizedBox(width: 130, child: Text(dateStr, style: const TextStyle(color: AppColors.textSecondary))),
                  SizedBox(width: 120, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isCash ? AppColors.successLight : const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                    child: Text(e.paymentMethod.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isCash ? AppColors.success : const Color(0xFF4F46E5))),
                  )),
                  SizedBox(width: 120, child: Text(e.orderNumber ?? '-', style: const TextStyle(color: AppColors.textSecondary))),
                  SizedBox(width: 100, child: Text(e.referenceNumber ?? '-', style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 120, child: Text('\$${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }
}
