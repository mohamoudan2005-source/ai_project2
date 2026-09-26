import 'package:ai_project/utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnalysisTrendChart extends StatelessWidget {
  const AnalysisTrendChart({
    required this.pneumoniaCases,
    required this.normalCases,
    required this.totalCases,
  });

  final int pneumoniaCases;
  final int normalCases;
  final int totalCases;

  @override
  Widget build(BuildContext context) {
    final maxVal = [
      pneumoniaCases,
      normalCases,
    ].reduce((a, b) => a > b ? a : b).toDouble();
    final chartMax = (maxVal < 1 ? 1 : maxVal) * 1.3;

    // Guard against dividing by zero when there's no history yet.
    final pneumoniaPct = totalCases == 0
        ? 0
        : (pneumoniaCases * 100 ~/ totalCases);
    final normalPct = totalCases == 0 ? 0 : (normalCases * 100 ~/ totalCases);

    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: BarChart(
            BarChartData(
              maxY: chartMax,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.07),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28.w,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final text = value.toInt() == 0 ? 'Pneumonia' : 'Normal';
                      return Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          text,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: pneumoniaCases.toDouble(),
                      color: AppColors.orange,
                      width: 46.w,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: normalCases.toDouble(),
                      color: AppColors.primary,
                      width: 46.w,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.xl,
          alignment: WrapAlignment.center,
          children: [
            LegendDot(
              color: AppColors.orange,
              label: 'Pneumonia',
              pct: pneumoniaPct.toString(),
            ),
            LegendDot(
              color: AppColors.primary,
              label: 'Normal',
              pct: normalPct.toString(),
            ),
          ],
        ),
      ],
    );
  }
}

class LegendDot extends StatelessWidget {
  const LegendDot({
    required this.color,
    required this.label,
    required this.pct,
  });

  final Color color;
  final String label;
  final String pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text('$label ($pct%)', style: AppTextStyles.bodySmall),
      ],
    );
  }
}
