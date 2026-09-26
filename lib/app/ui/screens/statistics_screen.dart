import 'package:ai_project/app/ui/widgets/history/seaction_header.dart';
import 'package:ai_project/app/ui/widgets/history/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:ai_project/utils/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({
    super.key,
    required this.totalAnalyses,
    required this.pneumoniaCases,
    required this.normalCases,
    required this.detectionRate, // 0.0 - 100.0
  });

  final int totalAnalyses;
  final int pneumoniaCases;
  final int normalCases;
  final double detectionRate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(title: const Text('Statistics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top summary cards (2x2 grid) ───────────────────────────
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      emoji: '📊',
                      value: '$totalAnalyses',
                      label: 'TOTAL ANALYSES',
                      decoration: AppDecorations.card,
                      accentColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      emoji: '⚠️',
                      value: '$pneumoniaCases',
                      label: 'PNEUMONIA CASES',
                      decoration: AppDecorations.cardOrange,
                      accentColor: AppColors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      emoji: '✅',
                      value: '$normalCases',
                      label: 'NORMAL CASES',
                      decoration: AppDecorations.cardLime,
                      accentColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      emoji: '🎯',
                      value: '${detectionRate.toStringAsFixed(2)}%',
                      label: 'DETECTION RATE',
                      decoration: AppDecorations.card,
                      accentColor: AppColors.primary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.xxxl),
              Divider(color: Colors.white.withOpacity(0.07)),
              SizedBox(height: AppSpacing.xxl),

              // ── Case Distribution (donut) ──────────────────────────────
              SectionHeader(emoji: '🥧', title: 'Case Distribution'),
              SizedBox(height: AppSpacing.lg),
              _ChartCard(
                child: _CaseDistributionChart(
                  pneumoniaCases: pneumoniaCases,
                  normalCases: normalCases,
                ),
              ),

              SizedBox(height: AppSpacing.xxl),

              // ── Analysis Trend (bar) ───────────────────────────────────
              SectionHeader(emoji: '📈', title: 'Analysis Trend'),
              SizedBox(height: AppSpacing.lg),
              _ChartCard(
                child: _AnalysisTrendChart(
                  pneumoniaCases: pneumoniaCases,
                  normalCases: normalCases,
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat card ───────────────────────────────────────────────────────────────

// ── Section header ────────────────────────────────────────────────────────

// ── Shared chart card shell ──────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPad,
      decoration: AppDecorations.card,
      child: child,
    );
  }
}

// ── Case distribution donut chart ────────────────────────────────────────

class _CaseDistributionChart extends StatelessWidget {
  const _CaseDistributionChart({
    required this.pneumoniaCases,
    required this.normalCases,
  });

  final int pneumoniaCases;
  final int normalCases;

  @override
  Widget build(BuildContext context) {
    final total = pneumoniaCases + normalCases;
    final pneumoniaPct = total == 0 ? 0 : (pneumoniaCases / total * 100);
    final normalPct = total == 0 ? 0 : (normalCases / total * 100);

    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 55.r,
                  sections: [
                    PieChartSectionData(
                      value: pneumoniaCases.toDouble(),
                      color: AppColors.orange,
                      radius: 45.r,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: normalCases.toDouble(),
                      color: AppColors.primary,
                      radius: 45.r,
                      showTitle: false,
                    ),
                  ],
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

// ── Analysis trend bar chart ─────────────────────────────────────────────

class _AnalysisTrendChart extends StatelessWidget {
  const _AnalysisTrendChart({
    required this.pneumoniaCases,
    required this.normalCases,
  });

  final int pneumoniaCases;
  final int normalCases;

  @override
  Widget build(BuildContext context) {
    final maxVal = [
      pneumoniaCases,
      normalCases,
    ].reduce((a, b) => a > b ? a : b).toDouble();
    final chartMax = (maxVal < 1 ? 1 : maxVal) * 1.3;

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
            _LegendDot(
              color: AppColors.orange,
              label: 'Pneumonia',
              pct: '$pneumoniaCases',
            ),
            _LegendDot(
              color: AppColors.primary,
              label: 'Normal',
              pct: '$normalCases',
            ),
          ],
        ),
      ],
    );
  }
}
