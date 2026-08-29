import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/sales/sales_filters.dart';
import 'package:erp_software/frontend/widgets/sales/sales_invoice_card.dart';
import 'package:erp_software/frontend/widgets/sales/sales_bill_sheet.dart';

class SalesManagementScreen extends StatefulWidget {
  const SalesManagementScreen({
    super.key,
  });

  @override
  State<SalesManagementScreen> createState() =>
      _SalesManagementScreenState();
}

class _SalesManagementScreenState
    extends State<SalesManagementScreen> {
  String search = '';
  String customerFilter = 'All Customers';
  String paymentFilter = 'All Payments';

  final List<Map<String, dynamic>> invoices = [
    {
      'invoice': 'SO-1787124949286',
      'customer': 'Salman',
      'cashier': 'Admin',
      'date': '2026-08-19',
      'payment': 'Cash',
      'status': 'Paid',
      'total': 1650.0,
      'items': [
        {
          'name': 'Product A',
          'quantity': 1,
          'price': 1650.0,
        },
      ],
    },
    {
      'invoice': 'SO-1787124650264',
      'customer': 'Salman',
      'cashier': 'Admin',
      'date': '2026-08-19',
      'payment': 'Cash',
      'status': 'Paid',
      'total': 1650.0,
      'items': [
        {
          'name': 'Product B',
          'quantity': 1,
          'price': 1650.0,
        },
      ],
    },
    {
      'invoice': 'SO-1787123349308',
      'customer': 'Salman',
      'cashier': 'Admin',
      'date': '2026-08-19',
      'payment': 'Cash',
      'status': 'Paid',
      'total': 3300.0,
      'items': [
        {
          'name': 'Product C',
          'quantity': 2,
          'price': 1650.0,
        },
      ],
    },
    {
      'invoice': 'SO-1787118458134',
      'customer': 'Salman',
      'cashier': 'Admin',
      'date': '2026-08-19',
      'payment': 'Cash',
      'status': 'Paid',
      'total': 1650.0,
      'items': [
        {
          'name': 'Product A',
          'quantity': 1,
          'price': 1650.0,
        },
      ],
    },
    {
      'invoice': 'SO-1787118336327',
      'customer': 'Walk-in Customer',
      'cashier': 'Admin',
      'date': '2026-08-19',
      'payment': 'Cash',
      'status': 'Paid',
      'total': 105.0,
      'items': [
        {
          'name': 'Product D',
          'quantity': 1,
          'price': 105.0,
        },
      ],
    },
    {
      'invoice': 'SO-17866822230702',
      'customer': 'Walk-in Customer',
      'cashier': 'Admin',
      'date': '2026-08-14',
      'payment': 'Cash',
      'status': 'Paid',
      'total': 1650.0,
      'items': [
        {
          'name': 'Product A',
          'quantity': 1,
          'price': 1650.0,
        },
      ],
    },
    {
      'invoice': 'SO-1786682198679',
      'customer': 'Walk-in Customer',
      'cashier': 'Admin',
      'date': '2026-08-14',
      'payment': 'Cash',
      'status': 'Pending',
      'total': 1650.0,
      'items': [
        {
          'name': 'Product A',
          'quantity': 1,
          'price': 1650.0,
        },
      ],
    },
    {
      'invoice': 'SO-1786605041754',
      'customer': 'Walk-in Customer',
      'cashier': 'Admin',
      'date': '2026-08-13',
      'payment': 'Cash',
      'status': 'Paid',
      'total': 3300.0,
      'items': [
        {
          'name': 'Product C',
          'quantity': 2,
          'price': 1650.0,
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get filteredInvoices {
    return invoices.where((invoice) {
      final invoiceNumber =
          invoice['invoice']
              .toString()
              .toLowerCase();

      final customer =
          invoice['customer']
              .toString()
              .toLowerCase();

      final query =
          search.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          invoiceNumber.contains(query) ||
          customer.contains(query);

      final matchesCustomer =
          customerFilter == 'All Customers' ||
          invoice['customer'] ==
              customerFilter;

      final matchesPayment =
          paymentFilter == 'All Payments' ||
          invoice['payment'] ==
              paymentFilter;

      return matchesSearch &&
          matchesCustomer &&
          matchesPayment;
    }).toList();
  }

  void showBill(
    Map<String, dynamic> invoice,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SalesBillSheet(
          invoice: invoice,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.pageBackground,

      body: SafeArea(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // --------------------------------
      // PAGE TITLE
      // --------------------------------
      Padding(
        padding: const EdgeInsets.fromLTRB(
          14,
          16,
          14,
          4,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              'Manage invoices and customer sales.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 10),

      // --------------------------------
      // FILTERS
      // --------------------------------
      SalesFilters(
        onSearchChanged: (value) {
          setState(() {
            search = value;
          });
        },
        onCustomerChanged: (value) {
          setState(() {
            customerFilter = value;
          });
        },
        onPaymentChanged: (value) {
          setState(() {
            paymentFilter = value;
          });
        },
      ),

      // --------------------------------
      // SALES LIST
      // --------------------------------
      Expanded(
        child: filteredInvoices.isEmpty
            ? const _EmptySales()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  4,
                  14,
                  30,
                ),
                itemCount:
                    filteredInvoices.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final invoice =
                      filteredInvoices[index];

                  return SalesInvoiceCard(
                    invoice: invoice,
                    onView: () {
                      showBill(invoice);
                    },
                  );
                },
              ),
      ),
    ],
  ),
),
    );
  }
}

class _EmptySales extends StatelessWidget {
  const _EmptySales();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'No sales found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Try changing your search or filters',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
