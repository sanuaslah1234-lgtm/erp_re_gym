import 'package:erp_software/frontend/screens/customers/customers_screen.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class RecentOrders extends StatelessWidget {
  const RecentOrders({super.key});

  final List<Map<String, dynamic>> orders = const [
    {
      "id": "#ORD-1025",
      "customer": "John Doe",
      "date": "Aug 15, 2026",
      "status": "Completed",
      "value": 12500.00,
    },
    {
      "id": "#ORD-1024",
      "customer": "Alex Smith",
      "date": "Aug 14, 2026",
      "status": "Processing",
      "value": 8750.00,
    },
    {
      "id": "#ORD-1023",
      "customer": "David Wilson",
      "date": "Aug 14, 2026",
      "status": "Pending",
      "value": 6200.00,
    },
    {
      "id": "#ORD-1022",
      "customer": "Sarah Thomas",
      "date": "Aug 13, 2026",
      "status": "Completed",
      "value": 4300.00,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppShadows.medium,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Orders",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Latest order activity",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CustomersScreen()));
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // HORIZONTAL TABLE
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: DataTable(
              headingRowHeight: 45,
              dataRowMinHeight: 55,
              dataRowMaxHeight: 60,

              columnSpacing: 35,

              headingRowColor:
                  WidgetStateProperty.all(
                AppColors.background,
              ),

              border: TableBorder(
                horizontalInside: BorderSide(
                  color: AppColors.border,
                  width: 0.7,
                ),
              ),

              columns: const [
                DataColumn(
                  label: Text(
                    "Order ID",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Customer",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Date",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Value",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],

              rows: orders.map((order) {
                return DataRow(
                  cells: [

                    // ORDER ID
                    DataCell(
                      Text(
                        order["id"],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    // CUSTOMER
                    DataCell(
                      Text(
                        order["customer"],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // DATE
                    DataCell(
                      Text(
                        order["date"],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    // STATUS
                    DataCell(
                      _statusBadge(
                        order["status"],
                      ),
                    ),

                    // VALUE
                    DataCell(
                      Text(
                        "₹${order["value"].toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "Completed":
        color = AppColors.success;
        break;

      case "Processing":
        color = AppColors.primary;
        break;

      case "Pending":
        color = AppColors.warning;
        break;

      case "Cancelled":
        color = AppColors.danger;
        break;

      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

