import 'dart:io';
import 'package:ai_project/app/ui/widgets/history/analysis_trend_chart.dart';
import 'package:ai_project/app/ui/widgets/history/case_distribution_cart.dart';
import 'package:ai_project/app/ui/widgets/history/chart_card.dart';
import 'package:ai_project/app/ui/widgets/history/monthly_stats.dart';
import 'package:ai_project/app/ui/widgets/history/seaction_header.dart';
import 'package:ai_project/app/ui/widgets/history/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/ui/widgets/streak_pill.dart';
import 'package:ai_project/app/ui/widgets/history/history_empty_state.dart';
import 'package:ai_project/app/ui/widgets/history/mission_card.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/widgets/profile_avatar_button.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final appController = ref.read(appProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        appController.mapEventToState(AppEvent.goToCamera());
      },
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => appController.mapEventToState(
                              AppEvent.goToCamera(),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 6.h,
                              ),
                              decoration: AppDecorations.buttonGhost,
                              child: Text(
                                '← Back',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ),
                          const ProfileAvatarButton(),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Text('Dashboard', style: AppTextStyles.displayMedium),
                      SizedBox(height: 8.h),
                      StreakPill(streak: appState.streak, large: true),
                      SizedBox(height: 40.h),
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
                      SizedBox(height: AppSpacing.lg),
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

                      SizedBox(height: 50.h),
                      SectionHeader(emoji: '🥧', title: 'Case Distribution'),
                      SizedBox(height: 20.h),
                      ChartCard(
                        child: CaseDistributionChart(
                          pneumoniaCases: appState.pneumoniaCases,
                          normalCases: appState.normalCases,
                          totalCases: appState.totalCases,
                        ),
                      ),

                      SizedBox(height: 50.h),
                      SectionHeader(emoji: '📈', title: 'Analysis Trend'),
                      SizedBox(height: 20.h),
                      ChartCard(
                        child: AnalysisTrendChart(
                          pneumoniaCases: appState.pneumoniaCases,
                          normalCases: appState.normalCases,
                          totalCases: appState.totalCases,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      MonthlyStats(history: appState.history),
                      SizedBox(height: 50.h),
                      SectionHeader(emoji: '🕒', title: 'Recent Examinations'),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),

                // ── Mission list ─────────────────────────────────────────────────
                appState.history.isEmpty
                    ? HistoryEmptyState()
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 18.h,
                        ),
                        itemCount: appState.history.length,
                        itemBuilder: (context, index) {
                          final item = appState.history[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: MissionCard(item: item, index: index),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
