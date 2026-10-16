import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/ui/widgets/history/analysis_trend_chart.dart';
import 'package:ai_project/app/ui/widgets/history/case_distribution_cart.dart';
import 'package:ai_project/app/ui/widgets/history/chart_card.dart';
import 'package:ai_project/app/ui/widgets/history/mission_card.dart';
import 'package:ai_project/app/ui/widgets/history/monthly_stats.dart';
import 'package:ai_project/app/ui/widgets/history/patient_demographics_charts.dart';
import 'package:ai_project/app/ui/widgets/history/seaction_header.dart';
import 'package:ai_project/app/ui/widgets/history/stat_card.dart';
import 'package:ai_project/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StatisticsPart extends ConsumerStatefulWidget {
  const StatisticsPart({super.key});

  @override
  ConsumerState<StatisticsPart> createState() => _StatisticsPartState();
}

class _StatisticsPartState extends ConsumerState<StatisticsPart> {
  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  emoji: '📊',
                  value: appState.totalCases.toString(),
                  label: 'TOTAL ANALYSES',
                  decoration: AppDecorations.card,
                  accentColor: AppColors.primary,
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
                  value: appState.normalCases.toString(),
                  label: 'NORMAL CASES',
                  decoration: AppDecorations.cardLime,
                  accentColor: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  emoji: '⚠️',
                  value: appState.pneumoniaCases.toString(),
                  label: 'PNEUMONIA CASES',
                  decoration: AppDecorations.cardOrange,
                  accentColor: AppColors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 36.h),
          SectionHeader(emoji: '🥧', title: 'Case Distribution'),
          SizedBox(height: 16.h),
          ChartCard(
            child: CaseDistributionChart(
              pneumoniaCases: appState.pneumoniaCases,
              normalCases: appState.normalCases,
              totalCases: appState.normalCases + appState.pneumoniaCases,
            ),
          ),
          SizedBox(height: 36.h),
          SectionHeader(emoji: '📈', title: 'Analysis Trend'),
          SizedBox(height: 16.h),
          ChartCard(
            child: AnalysisTrendChart(
              pneumoniaCases: appState.pneumoniaCases,
              normalCases: appState.normalCases,
              totalCases: appState.normalCases + appState.pneumoniaCases,
            ),
          ),
          SizedBox(height: 36.h),
          SectionHeader(emoji: '👥', title: 'Patient Demographics'),
          SizedBox(height: 16.h),
          PatientDemographicsCharts(
            records: appState.history,
            isLoading: appState.isHistoryLoading,
            error: appState.historyLoadError,
          ),
          SizedBox(height: 36.h),
          MonthlyStats(
            history: appState.history,
            isLoading: appState.isHistoryLoading,
            error: appState.historyLoadError,
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
