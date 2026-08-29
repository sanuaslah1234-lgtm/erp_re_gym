import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class SalesBillSheet extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const SalesBillSheet({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final items =
        List<Map<String, dynamic>>.from(
      invoice['items'] ?? [],
    );

    final total =
        (invoice['total'] as num).toDouble();

    final subtotal = total;
    final discount = 0.0;

    // Demo tax
    final tax = total * 0.10;

    final grandTotal =
        subtotal - discount + tax;

    final status =
        invoice['status'].toString();

    final isPaid =
        status.toLowerCase() == 'paid';

    return Container(
      height: MediaQuery.of(context).size.height *
          0.90,

      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius:
            const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // --------------------------------
            // TOP BAR
            // --------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      'Sale Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------
            // BILL
            // --------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  14,
                  4,
                  14,
                  20,
                ),
                child: Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset:
                            const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _BillHeader(
                        invoice: invoice,
                        isPaid: isPaid,
                      ),

                      const Divider(
                        height: 1,
                      ),

                      _CustomerSection(
                        invoice: invoice,
                      ),

                      const Divider(
                        height: 1,
                      ),

                      _ItemsSection(
                        items: items,
                      ),

                      const Divider(
                        height: 1,
                      ),

                      _SummarySection(
                        subtotal: subtotal,
                        discount: discount,
                        tax: tax,
                        grandTotal:
                            grandTotal,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _BillHeader extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final bool isPaid;

  const _BillHeader({
    required this.invoice,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Invoice',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  invoice['invoice'].toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  invoice['date'].toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green.withValues(alpha: 0.10)
                  : Colors.red.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Text(
              invoice['status'].toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
                color: isPaid
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _CustomerSection extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const _CustomerSection({
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'SALE INFORMATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _Detail(
                  icon: Icons.person_outline,
                  label: 'Customer',
                  value:
                      invoice['customer'].toString(),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _Detail(
                  icon: Icons.badge_outlined,
                  label: 'Cashier',
                  value:
                      invoice['cashier'].toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _Detail(
            icon: Icons.payments_outlined,
            label: 'Payment',
            value:
                invoice['payment'].toString(),
          ),
        ],
      ),
    );
  }
}
class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Detail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.textSecondary,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class _ItemsSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _ItemsSection({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'ITEMS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          ...items.map(
            (item) {
              final name =
                  item['name'].toString();

              final quantity =
                  item['quantity'] as int;

              final price =
                  (item['price'] as num)
                      .toDouble();

              final itemTotal =
                  quantity * price;

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 9,
                ),
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      AppColors.pageBackground,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color:
                            AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(
                          9,
                        ),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color:
                            AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            name,
                            style:
                                const TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w700,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$quantity × ₹${price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '₹${itemTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
class _SummarySection extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;

  const _SummarySection({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: subtotal,
          ),

          const SizedBox(height: 8),

          _SummaryRow(
            label: 'Discount',
            value: discount,
            prefix: '- ',
          ),

          const SizedBox(height: 8),

          _SummaryRow(
            label: 'Tax',
            value: tax,
          ),

          const SizedBox(height: 14),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primarySoft,
                  AppColors.surface,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Grand Total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                ),

                Text(
                  '₹${grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final String prefix;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                AppColors.textSecondary,
          ),
        ),

        Text(
          '$prefix₹${value.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color:
                AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
