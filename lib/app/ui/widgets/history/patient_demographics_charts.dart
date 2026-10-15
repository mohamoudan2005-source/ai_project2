import 'dart:math' as math;

import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PatientDemographicsData {
  PatientDemographicsData._({
    required this.ageCounts,
    required this.genderCounts,
    required this.validAgeRecordCount,
    required this.totalRecordCount,
  });

  static const ageGroupLabels = ['0-17', '18-29', '30-44', '45-59', '60+'];
  static const genderCategories = ['Male', 'Female', 'Other', 'Unknown'];

  final List<int> ageCounts;
  final Map<String, int> genderCounts;
  final int validAgeRecordCount;
  final int totalRecordCount;

  factory PatientDemographicsData.fromRecords(
    Iterable<PredictionHistoryItem> records,
  ) {
    final ageCounts = List<int>.filled(ageGroupLabels.length, 0);
    final genderCounts = {for (final category in genderCategories) category: 0};
    var validAgeRecordCount = 0;
    var totalRecordCount = 0;

    for (final record in records) {
      totalRecordCount++;
      final age = record.patientAge;
      if (age != null && age >= 0 && age <= 125) {
        final groupIndex = switch (age) {
          <= 17 => 0,
          <= 29 => 1,
          <= 44 => 2,
          <= 59 => 3,
          _ => 4,
        };
        ageCounts[groupIndex]++;
        validAgeRecordCount++;
      }

      final normalizedGender = switch (record.patientGender
          ?.trim()
          .toLowerCase()) {
        'male' => 'Male',
        'female' => 'Female',
        'other' => 'Other',
        _ => 'Unknown',
      };
      genderCounts[normalizedGender] = genderCounts[normalizedGender]! + 1;
    }

    return PatientDemographicsData._(
      ageCounts: ageCounts,
      genderCounts: genderCounts,
      validAgeRecordCount: validAgeRecordCount,
      totalRecordCount: totalRecordCount,
    );
  }
}

class PatientDemographicsCharts extends StatelessWidget {
  const PatientDemographicsCharts({
    required this.records,
    required this.isLoading,
    required this.error,
    super.key,
  });

  final List<PredictionHistoryItem> records;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final data = PatientDemographicsData.fromRecords(records);

    return Column(
      children: [
        _ChartCard(
          child: _AgeDistributionChart(
            data: data,
            isLoading: isLoading && data.totalRecordCount == 0,
            error: data.totalRecordCount == 0 ? error : null,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        _ChartCard(
          child: _GenderDistributionChart(
            data: data,
            isLoading: isLoading && data.totalRecordCount == 0,
            error: data.totalRecordCount == 0 ? error : null,
          ),
        ),
      ],
    );
  }
}

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

class _AgeDistributionChart extends StatelessWidget {
  const _AgeDistributionChart({
    required this.data,
    required this.isLoading,
    required this.error,
  });

  final PatientDemographicsData data;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChartTitle(
          title: 'Patients by Age Group',
          subtitle: 'Examination records by age group',
        ),
        SizedBox(height: AppSpacing.lg),
        if (isLoading)
          const _ChartMessage(message: 'Loading examination records...')
        else if (error != null)
          _ChartMessage(message: error!)
        else if (data.validAgeRecordCount == 0)
          const _ChartMessage(message: 'No valid patient ages recorded yet.')
        else
          _buildChart(),
      ],
    );
  }

  Widget _buildChart() {
    final maxCount = data.ageCounts.reduce(math.max);
    final maxY = maxCount == 0 ? 1.0 : maxCount * 1.3;
    final interval = maxCount <= 4 ? 1.0 : (maxCount / 4).ceilToDouble();
    const chartHeight = 230.0;
    final plotLeft = 34.w;
    final plotTop = 8.h;
    final plotBottom = 40.h;
    final colors = [
      AppColors.primary,
      AppColors.orange,
      const Color(0xFF55C6B0),
      const Color(0xFF76A9D1),
      const Color(0xFFAAA99F),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final plotWidth = math.max(0, constraints.maxWidth - plotLeft);
        final plotHeight = chartHeight.h - plotTop - plotBottom;

        return SizedBox(
          height: chartHeight.h,
          child: Stack(
            children: [
              BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withValues(alpha: 0.07),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.dark,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final ageGroup =
                            PatientDemographicsData.ageGroupLabels[group.x];
                        return BarTooltipItem(
                          '$ageGroup years\n${rod.toY.toInt()} examination records',
                          AppTextStyles.caption.copyWith(
                            color: AppColors.textMain,
                            fontSize: 12.sp,
                          ),
                        );
                      },
                    ),
                  ),
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
                        reservedSize: plotLeft,
                        interval: interval,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: plotBottom,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 ||
                              index >=
                                  PatientDemographicsData
                                      .ageGroupLabels
                                      .length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 7.h),
                            child: Text(
                              PatientDemographicsData.ageGroupLabels[index],
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11.sp,
                                color: AppColors.textSub,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    PatientDemographicsData.ageGroupLabels.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.ageCounts[index].toDouble(),
                          color: colors[index],
                          width: 22.w,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(5.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ...List.generate(data.ageCounts.length, (index) {
                final count = data.ageCounts[index];
                final centerX = plotLeft + plotWidth * (index + 0.5) / 5;
                final barTop = plotTop + plotHeight * (1 - count / maxY);
                return Positioned(
                  left: centerX - 14.w,
                  top: math.max(0, barTop - 20.h),
                  child: IgnorePointer(
                    child: SizedBox(
                      width: 28.w,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMain,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _GenderDistributionChart extends StatefulWidget {
  const _GenderDistributionChart({
    required this.data,
    required this.isLoading,
    required this.error,
  });

  final PatientDemographicsData data;
  final bool isLoading;
  final String? error;

  @override
  State<_GenderDistributionChart> createState() =>
      _GenderDistributionChartState();
}

class _GenderDistributionChartState extends State<_GenderDistributionChart> {
  static const _colors = [
    AppColors.primary,
    AppColors.orange,
    Color(0xFF55C6B0),
    Color(0xFF77776F),
  ];

  int _touchedIndex = -1;
  Offset? _touchPosition;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final total = data.totalRecordCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ChartTitle(
          title: 'Patients by Gender',
          subtitle: 'Examination records grouped by gender',
        ),
        SizedBox(height: AppSpacing.lg),
        if (widget.isLoading)
          const _ChartMessage(message: 'Loading examination records...')
        else if (widget.error != null)
          _ChartMessage(message: widget.error!)
        else if (total == 0)
          const _ChartMessage(message: 'No examination records yet.')
        else ...[
          Center(
            child: Text(
              'Total included records: $total',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSub,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildDonut(data, total),
          SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: List.generate(
              PatientDemographicsData.genderCategories.length,
              (index) {
                final category =
                    PatientDemographicsData.genderCategories[index];
                final count = data.genderCounts[category]!;
                final percentage = count / total * 100;
                return _GenderLegendItem(
                  color: _colors[index],
                  label: category,
                  count: count,
                  percentage: percentage,
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDonut(PatientDemographicsData data, int total) {
    const chartHeight = 190.0;
    const tooltipWidth = 150.0;
    const tooltipHeight = 48.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final position = _touchPosition;
        final tooltipLeft = position == null
            ? 0.0
            : (position.dx + 10.w)
                  .clamp(
                    4.w,
                    math.max(4.w, constraints.maxWidth - tooltipWidth.w - 4.w),
                  )
                  .toDouble();
        final tooltipTop = position == null
            ? 0.0
            : (position.dy + 10.h)
                  .clamp(
                    4.h,
                    math.max(4.h, chartHeight.h - tooltipHeight.h - 4.h),
                  )
                  .toDouble();

        return SizedBox(
          height: chartHeight.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final section = response?.touchedSection;
                      if (!event.isInterestedForInteractions ||
                          section == null ||
                          section.touchedSection == null) {
                        if (_touchedIndex != -1) {
                          setState(() {
                            _touchedIndex = -1;
                            _touchPosition = null;
                          });
                        }
                        return;
                      }
                      setState(() {
                        _touchedIndex = section.touchedSectionIndex;
                        _touchPosition = response?.touchLocation;
                      });
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 48.r,
                  sections: List.generate(
                    PatientDemographicsData.genderCategories.length,
                    (index) {
                      final category =
                          PatientDemographicsData.genderCategories[index];
                      return PieChartSectionData(
                        value: data.genderCounts[category]!.toDouble(),
                        color: _colors[index],
                        radius: _touchedIndex == index ? 42.r : 36.r,
                        showTitle: false,
                      );
                    },
                  ),
                ),
              ),
              IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textMain,
                        fontSize: 20.sp,
                      ),
                    ),
                    Text(
                      'records',
                      style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              if (_touchedIndex >= 0 && _touchedIndex < _colors.length)
                Positioned(
                  left: tooltipLeft,
                  top: tooltipTop,
                  child: IgnorePointer(
                    child: Container(
                      width: tooltipWidth.w,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: _colors[_touchedIndex].withValues(alpha: 0.8),
                        ),
                      ),
                      child: Text(
                        _tooltipText(data, _touchedIndex, total),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMain,
                          fontSize: 11.sp,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _tooltipText(PatientDemographicsData data, int index, int total) {
    final category = PatientDemographicsData.genderCategories[index];
    final count = data.genderCounts[category]!;
    final percentage = count / total * 100;
    return '$category: $count records (${percentage.toStringAsFixed(1)}%)';
  }
}

class _ChartTitle extends StatelessWidget {
  const _ChartTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(fontSize: 17.sp),
        ),
        SizedBox(height: 2.h),
        Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 12.sp)),
      ],
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(fontSize: 13.sp),
        ),
      ),
    );
  }
}

class _GenderLegendItem extends StatelessWidget {
  const _GenderLegendItem({
    required this.color,
    required this.label,
    required this.count,
    required this.percentage,
  });

  final Color color;
  final String label;
  final int count;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(
          '$label  $count (${percentage.toStringAsFixed(1)}%)',
          style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
        ),
      ],
    );
  }
}
