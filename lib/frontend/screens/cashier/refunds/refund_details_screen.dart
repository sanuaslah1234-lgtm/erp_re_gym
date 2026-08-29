import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/refund.dart';

class RefundDetailsScreen extends StatelessWidget {
  final Refund refund;

  const RefundDetailsScreen({super.key, required this.refund});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Refund Details - ${refund.refundNumber}'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildRow('Refund Number', refund.refundNumber),
                    const Divider(),
                    _buildRow('Original Order #', refund.orderNumber ?? 'Order #${refund.orderId}'),
                    const Divider(),
                    _buildRow('Refund Method', refund.refundMethod),
                    const Divider(),
                    _buildRow('Total Refund Amount', '\$${refund.refundAmount.toStringAsFixed(2)}'),
                    const Divider(),
                    _buildRow('Reason', refund.reason ?? 'N/A'),
                    const Divider(),
                    _buildRow('Processed By', refund.processorName ?? 'User #${refund.processedBy}'),
                    const Divider(),
                    _buildRow('Processed Date', refund.createdAt?.toString() ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Refunded Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: refund.items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final item = refund.items[i];
                    return ListTile(
                      title: Text(item.productName ?? 'Product #${item.productId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Refunded Quantity: ${item.quantity.toStringAsFixed(0)}'),
                      trailing: Text('\$${item.refundAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.purple)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
