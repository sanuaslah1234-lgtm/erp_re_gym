import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';
import 'sales_status_badge.dart';

class SalesInvoiceCard extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final VoidCallback onView;

  const SalesInvoiceCard({
    super.key,
    required this.invoice,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        (invoice['total'] as num).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      AppColors.primarySoft,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice['invoice']
                          .toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      invoice['customer']
                          .toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              SalesStatusBadge(
                status:
                    invoice['status'].toString(),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding:
                const EdgeInsets.symmetric(
              vertical: 11,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color:
                  AppColors.pageBackground,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Info(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value:
                        invoice['date'].toString(),
                  ),
                ),

                Expanded(
                  child: _Info(
                    icon: Icons.payments_outlined,
                    label: 'Payment',
                    value:
                        invoice['payment']
                            .toString(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Material(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.circular(9),
                child: InkWell(
                  onTap: onView,
                  borderRadius:
                      BorderRadius.circular(9),
                  child: const Padding(
                    padding:
                        EdgeInsets.all(10),
                    child: Icon(
                      Icons.visibility_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Info({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
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
              const SizedBox(height: 2),
              Text(
                value,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
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
