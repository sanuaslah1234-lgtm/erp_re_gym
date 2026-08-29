import 'package:erp_software/frontend/screens/employees/employee_screen.dart';
import 'package:erp_software/frontend/widgets/dashboard/recent_orders.dart';
import 'package:erp_software/frontend/widgets/dashboard/revenue_chart.dart';
import 'package:erp_software/frontend/widgets/dashboard/sale_category_chart.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BranchManagerDashBoard extends StatefulWidget {
  const BranchManagerDashBoard({super.key});

  @override
  State<BranchManagerDashBoard> createState() =>
      _BranchManagerDashBoardState();
}

class _BranchManagerDashBoardState extends State<BranchManagerDashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body:SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Admin",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Retail ERP Dashboard Overview",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // BUTTON
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeesScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:Row(
                      children: [
                        const Icon(Icons.signal_cellular_alt),
                     const Text(
                      "Generate",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                      ]
                  ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20,),
           RevenueChart(),
           SizedBox(height: 5,),
           SalesCategoryChart(),
           SizedBox(height: 10,),
           RecentOrders(),
           SizedBox(height: 10,)
          ],
        ),
      ),
    )
    );
  }
}
