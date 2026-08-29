import 'package:erp_software/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatefulWidget {
  const RevenueChart({super.key});                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  String selectedYear = "2026";

  final Map<String, List<Map<String, double>>> chartData = {
    "2026": [
      {"revenue": 65, "expense": 35},
      {"revenue": 72, "expense": 40},
      {"revenue": 80, "expense": 45},
      {"revenue": 68, "expense": 38},
      {"revenue": 88, "expense": 50},
      {"revenue": 95, "expense": 55},
    ],

    "2025": [
      {"revenue": 55, "expense": 30},
      {"revenue": 62, "expense": 35},
      {"revenue": 70, "expense": 42},
      {"revenue": 75, "expense": 40},
      {"revenue": 82, "expense": 48},
      {"revenue": 90, "expense": 52},
    ],

    "2024": [
      {"revenue": 45, "expense": 25},
      {"revenue": 50, "expense": 30},
      {"revenue": 58, "expense": 32},
      {"revenue": 65, "expense": 37},
      {"revenue": 70, "expense": 42},
      {"revenue": 78, "expense": 48},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final data = chartData[selectedYear]!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Revenue vs Expenses",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  const Text(
                    "Monthly performance",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryLight
              )
            ),
            child:Theme(
              data: Theme.of(context).copyWith(
                canvasColor: AppColors.white,
                hoverColor: AppColors.primarySoft,
                highlightColor: AppColors.primarySoft,
                splashColor: AppColors.primarySoft
              ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedYear,
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.primary,
                ),
                style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    items: chartData.keys.map((year){
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value){
                      if(value == null) return;
                      setState(() {
                          selectedYear = value;
                      });
                    },
              ),
            ),
          ),
          ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 35),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          "Jan",
                          "Feb",
                          "Mar",
                          "Apr",
                          "May",
                          "Jun",
                        ];
                        if (value.toInt() >= months.length) {
                          return const SizedBox();
                        }
                        return Text(
                          months[value.toInt()],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  data.length,
                  (index){
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 5,
                      barRods: [
                        BarChartRodData(
                          toY: data[index]["revenue"]!,
                          width: 8,
                          color: AppColors.revenue,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        BarChartRodData(
                          toY: data[index]["expense"]!,
                          width: 8,
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(4)
                        )
                      ]
                    );
                  }
                )
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(AppColors.revenue, "Revenue"),
              SizedBox(width: 20),
              _legend(AppColors.danger, "Expenses"),
            ],
          ),
        ],
      ),
    );
  }
  static Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
