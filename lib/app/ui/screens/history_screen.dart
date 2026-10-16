import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/ui/widgets/history/analysis_trend_chart.dart';
import 'package:ai_project/app/ui/widgets/history/case_distribution_cart.dart';
import 'package:ai_project/app/ui/widgets/history/chart_card.dart';
import 'package:ai_project/app/ui/widgets/history/history_part.dart'
    show HistoryPart;
import 'package:ai_project/app/ui/widgets/history/mission_card.dart';
import 'package:ai_project/app/ui/widgets/history/monthly_stats.dart';
import 'package:ai_project/app/ui/widgets/history/patient_demographics_charts.dart';
import 'package:ai_project/app/ui/widgets/history/seaction_header.dart';
import 'package:ai_project/app/ui/widgets/history/stat_card.dart';
import 'package:ai_project/app/ui/widgets/history/statistics_part.dart';
import 'package:ai_project/app/ui/widgets/streak_pill.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/widgets/profile_avatar_button.dart';
import 'package:ai_project/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final appController = ref.read(appProvider.notifier);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 900 ? 40.0 : 20.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        appController.mapEventToState(AppEvent.goToCamera());
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.dark,
          body: SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
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
                            child: Text('← Back', style: AppTextStyles.caption),
                          ),
                        ),
                        const ProfileAvatarButton(),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Text('Dashboard', style: AppTextStyles.displayMedium),
                    SizedBox(height: 8.h),
                    StreakPill(streak: appState.streak, large: true),
                    if (appState.isHistoryLoading) ...[
                      SizedBox(height: 18.h),
                      const LinearProgressIndicator(color: AppColors.primary),
                    ],
                    if (appState.historyLoadError != null) ...[
                      SizedBox(height: 14.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: AppDecorations.card,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              appState.historyLoadError!,
                              style: AppTextStyles.caption,
                            ),
                            TextButton(
                              onPressed: appController.reloadUserData,
                              child: const Text('Retry summary'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 26.h),
                    TabBar(
                      indicatorColor: AppColors.primary,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.syne(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.55,
                      ),
                      unselectedLabelStyle: GoogleFonts.syne(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSub,
                        height: 1.55,
                      ),
                      tabs: [
                        Tab(child: Text('Statistics')),
                        Tab(child: Text('History')),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Flexible(
                      child: const TabBarView(
                        children: [StatisticsPart(), HistoryPart()],
                      ),
                    ),
                    // StatisticsPart(),
                    // HistoryPart(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
