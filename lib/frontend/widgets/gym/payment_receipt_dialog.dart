import 'package:flutter/material.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class PaymentReceiptDialog extends StatefulWidget {
  final int paymentId;

  const PaymentReceiptDialog({
    super.key,
    required this.paymentId,
  });

  @override
  State<PaymentReceiptDialog> createState() => _PaymentReceiptDialogState();
}

class _PaymentReceiptDialogState extends State<PaymentReceiptDialog> {
  final GymApiService gymService = GymApiService();
  Map<String, dynamic>? _receiptData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    try {
      final data = await gymService.getPaymentReceipt(widget.paymentId);
      if (!mounted) return;
      setState(() {
        _receiptData = data;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 10),
                  const Text('Payment Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Receipt Content
            _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))
                : _receiptData == null
                    ? const Padding(padding: EdgeInsets.all(40), child: Text('Receipt not found'))
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Organization Header
                            const Text('FITNESS & GYM MANAGEMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2563EB), letterSpacing: 1.0)),
                            const SizedBox(height: 4),
                            const Text('Official Payment & Tax Invoice Receipt', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            const Divider(height: 24),

                            // Receipt Meta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Receipt No', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    Text(_receiptData!['receiptNo'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Payment Date', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    Text(_receiptData!['paymentDate']?.toString().split('T').first ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Member Info Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Billed To: ${_receiptData!['member']?['name'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                  Text('Member Code: ${_receiptData!['member']?['code'] ?? '-'}  •  Phone: ${_receiptData!['member']?['phone'] ?? '-'}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Membership Details
                            if (_receiptData!['membership'] != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Plan: ${_receiptData!['membership']['planName']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('Valid: ${_receiptData!['membership']['startDate']} to ${_receiptData!['membership']['endDate']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                              const Divider(height: 16),
                            ],

                            // Amount Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Payment Method: ${_receiptData!['paymentMethod']}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                                  child: Text(_receiptData!['status'] ?? 'PAID', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successText)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBFDBFE))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Amount Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E40AF))),
                                  Text('\$${(double.tryParse(_receiptData!['amount']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Close'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ErpToast.showSuccess(context, 'Receipt ready for printing / download!', title: 'Print Receipt');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Print Receipt'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
