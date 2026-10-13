import 'package:ai_project/utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CaseDistributionChart extends StatefulWidget {
  const CaseDistributionChart({
    required this.pneumoniaCases,
    required this.normalCases,
    required this.totalCases,
    super.key,
  });

  final int pneumoniaCases, totalCases, normalCases;

  @override
  State<CaseDistributionChart> createState() => _CaseDistributionChartState();
}

class _CaseDistributionChartState extends State<CaseDistributionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.pneumoniaCases + widget.normalCases;
    final pneumoniaPct = total == 0 ? 0 : (widget.pneumoniaCases / total * 100);
    final normalPct = total == 0 ? 0 : (widget.normalCases / total * 100);

    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 55.r,
                  sections: [
                    PieChartSectionData(
                      value: widget.pneumoniaCases.toDouble(),
                      color: AppColors.orange,
                      radius: touchedIndex == 0 ? 55.r : 45.r, // grows on tap
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: widget.normalCases.toDouble(),
                      color: AppColors.primary,
                      radius: touchedIndex == 1 ? 55.r : 45.r,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              // Optional: show data for the touched section in the center
              if (touchedIndex != -1)
                Text(
                  touchedIndex == 0
                      ? 'Pneumonia\n${widget.pneumoniaCases}'
                      : 'Normal\n${widget.normalCases}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: touchedIndex == 0
                        ? AppColors.orange
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            _LegendDot(
              color: AppColors.orange,
              label: 'Pneumonia',
              pct: pneumoniaPct.toStringAsFixed(0),
            ),
            _LegendDot(
              color: AppColors.primary,
              label: 'Normal',
              pct: normalPct.toStringAsFixed(0),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
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
