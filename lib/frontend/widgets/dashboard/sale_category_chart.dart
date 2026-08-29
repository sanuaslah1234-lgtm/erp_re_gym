import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SalesCategoryChart extends StatefulWidget {
  const SalesCategoryChart({super.key});

  @override
  State<SalesCategoryChart> createState() => _SalesCategoryChartState();
}

class _SalesCategoryChartState extends State<SalesCategoryChart> {
  String selectedPeriod = "This Month";
  int touchedIndex = -1;
  final Map<String, List<PieChartSectionData>> chartData = {
    "This Month": [
      _section(35, AppColors.primary),
      _section(25, AppColors.success),
      _section(18, AppColors.warning),
      _section(12, AppColors.danger),
      _section(10, AppColors.primaryLight),
    ],
    "Last Month": [
      _section(30, AppColors.primary),
      _section(28, AppColors.success),
      _section(20, AppColors.warning),
      _section(12, AppColors.danger),
      _section(10, AppColors.primaryLight),
    ],
  };

  static PieChartSectionData _section(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 55,
      showTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final originData = chartData[selectedPeriod]!;
    final data = List.generate(originData.length, (index) {
      final section = originData[index];
      return PieChartSectionData(
        value: section.value,
        color: section.color,
        radius: touchedIndex == index ? 70 : 50,
        showTitle: touchedIndex == index,
        title: "${section.value.toInt()}%",
        titleStyle: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      );
    });

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sales by Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 5),
                    Text(
                      "Category distribution",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedPeriod,
                    dropdownColor: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    elevation: 8,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    items: chartData.keys.map((period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedPeriod = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: data,

                centerSpaceRadius: 55,

                sectionsSpace: 4,

                startDegreeOffset: -90,

                borderData: FlBorderData(show: false),

                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (response == null || response.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }

                      touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 12,
            children: [
              _legend(AppColors.primary, "Electronics", "35%"),
              _legend(AppColors.success, "Fashion", "25%"),
              _legend(AppColors.warning, "Accessories", "18%"),
              _legend(AppColors.danger, "Footwear", "12%"),
              _legend(AppColors.primaryLight, "Others", "10%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String title, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
