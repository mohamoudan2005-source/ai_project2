import 'package:ai_project/app/application/app_event.dart';
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
import 'package:ai_project/app/ui/widgets/streak_pill.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/widgets/profile_avatar_button.dart';
import 'package:ai_project/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum _OutcomeFilter { all, pneumonia, normal }

enum _HistorySort { newest, oldest }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const int _pageSize = 10;

  final _searchController = TextEditingController();
  int _pageIndex = 0;
  _OutcomeFilter _filter = _OutcomeFilter.all;
  _HistorySort _sort = _HistorySort.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PredictionHistoryItem> _filteredRecords(
    List<PredictionHistoryItem> history,
  ) {
    final query = _normalizeSearch(_searchController.text);
    final queryParts = query.isEmpty ? const <String>[] : query.split(' ');

    final records = history.where((item) {
      final name = _normalizeSearch(item.patientName ?? '');
      final nameParts = name.split(' ');
      final matchesSearch =
          queryParts.isEmpty ||
          queryParts.every(
            (part) => nameParts.any((namePart) => namePart.startsWith(part)),
          );
      final matchesFilter = switch (_filter) {
        _OutcomeFilter.all => true,
        _OutcomeFilter.pneumonia =>
          item.classificationKnown && item.isPneumonia,
        _OutcomeFilter.normal => item.classificationKnown && !item.isPneumonia,
      };
      return matchesSearch && matchesFilter;
    }).toList();

    records.sort((a, b) {
      final dateOrder = a.completedAt.compareTo(b.completedAt);
      final orderedDate = _sort == _HistorySort.newest ? -dateOrder : dateOrder;
      if (orderedDate != 0) return orderedDate;
      return (a.id ?? '').compareTo(b.id ?? '');
    });
    return records;
  }

  static String _normalizeSearch(String value) =>
      FirestoreService.normalizePatientNameSearch(value);

  void _resetPage() => _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final appController = ref.read(appProvider.notifier);
    final filteredRecords = _filteredRecords(appState.history);
    final totalCount = filteredRecords.length;
    final pageCount = (totalCount / _pageSize).ceil().clamp(1, 1 << 30);
    final currentPage = _pageIndex.clamp(0, pageCount - 1);
    final visibleRecords = filteredRecords
        .skip(currentPage * _pageSize)
        .take(_pageSize)
        .toList();
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 900 ? 40.0 : 20.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        appController.mapEventToState(AppEvent.goToCamera());
      },
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding.w,
                  20.h,
                  horizontalPadding.w,
                  36.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(height: 36.h),
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
                        totalCases:
                            appState.normalCases + appState.pneumoniaCases,
                      ),
                    ),
                    SizedBox(height: 36.h),
                    SectionHeader(emoji: '📈', title: 'Analysis Trend'),
                    SizedBox(height: 16.h),
                    ChartCard(
                      child: AnalysisTrendChart(
                        pneumoniaCases: appState.pneumoniaCases,
                        normalCases: appState.normalCases,
                        totalCases:
                            appState.normalCases + appState.pneumoniaCases,
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
                    SectionHeader(emoji: '🕒', title: 'Examination History'),
                    SizedBox(height: 16.h),
                    _buildSearchAndFilters(),
                    SizedBox(height: 16.h),
                    if (appState.isHistoryLoading && appState.history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (appState.historyLoadError != null &&
                        appState.history.isEmpty)
                      _buildErrorState(appState.historyLoadError!)
                    else if (visibleRecords.isEmpty)
                      _buildEmptyState()
                    else ...[
                      for (
                        var index = 0;
                        index < visibleRecords.length;
                        index++
                      )
                        Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: MissionCard(
                            item: visibleRecords[index],
                            index: currentPage * _pageSize + index,
                          ),
                        ),
                      _buildPagination(
                        totalCount: totalCount,
                        visibleCount: visibleRecords.length,
                        currentPage: currentPage,
                        pageCount: pageCount,
                      ),
                    ],
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text(
                        'AI predictions are decision-support estimates, not a medical diagnosis.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textDead,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(_resetPage),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMain),
            decoration: InputDecoration(
              hintText: 'Search patient name',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textDead,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSub,
                      onPressed: () {
                        _searchController.clear();
                        setState(_resetPage);
                      },
                    ),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.primary.withAlpha(50)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.primary.withAlpha(50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _filterChip('All', _OutcomeFilter.all),
            _filterChip('Pneumonia', _OutcomeFilter.pneumonia),
            _filterChip('Normal', _OutcomeFilter.normal),
            SizedBox(width: 12.w),
            DropdownButtonHideUnderline(
              child: DropdownButton<_HistorySort>(
                value: _sort,
                dropdownColor: AppColors.card,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMain,
                ),
                items: const [
                  DropdownMenuItem(
                    value: _HistorySort.newest,
                    child: Text('Newest first'),
                  ),
                  DropdownMenuItem(
                    value: _HistorySort.oldest,
                    child: Text('Oldest first'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null || value == _sort) return;
                  setState(() {
                    _sort = value;
                    _resetPage();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, _OutcomeFilter filter) {
    final selected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        if (_filter == filter) return;
        setState(() {
          _filter = filter;
          _resetPage();
        });
      },
      showCheckmark: true,
      selectedColor: const Color(0xFFD4E157),
      checkmarkColor: const Color(0xFF121212),
      backgroundColor: const Color(0xFF222222),
      labelStyle: AppTextStyles.caption.copyWith(
        color: selected ? const Color(0xFF121212) : Colors.white70,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected ? const Color(0xFFD4E157) : const Color(0xFF333333),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }

  Widget _buildPagination({
    required int totalCount,
    required int visibleCount,
    required int currentPage,
    required int pageCount,
  }) {
    final start = totalCount == 0 ? 0 : currentPage * _pageSize + 1;
    final end = (currentPage * _pageSize + visibleCount).clamp(0, totalCount);
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8.h,
        children: [
          Text(
            'Showing $start–$end of $totalCount',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSub),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: currentPage > 0
                    ? () => setState(() => _pageIndex = currentPage - 1)
                    : null,
                child: const Text('Previous'),
              ),
              SizedBox(width: 8.w),
              Text(
                'Page ${currentPage + 1} of $pageCount',
                style: AppTextStyles.caption,
              ),
              SizedBox(width: 8.w),
              OutlinedButton(
                onPressed: currentPage + 1 < pageCount
                    ? () => setState(() => _pageIndex = currentPage + 1)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasCriteria =
        _searchController.text.trim().isNotEmpty ||
        _filter != _OutcomeFilter.all;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 38.h, horizontal: 20.w),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Icon(
            hasCriteria
                ? Icons.search_off_rounded
                : Icons.medical_information_outlined,
            size: 36.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            hasCriteria ? 'No matching examinations' : 'No examinations yet',
            style: AppTextStyles.headingSmall,
          ),
          SizedBox(height: 6.h),
          Text(
            hasCriteria
                ? 'Try another patient name or change the outcome filter.'
                : 'Completed examinations will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSub),
          ),
          if (hasCriteria) ...[
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _filter = _OutcomeFilter.all;
                  _resetPage();
                });
              },
              child: const Text('Clear search and filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Text(message, style: AppTextStyles.bodySmall),
          TextButton(
            onPressed: ref.read(appProvider.notifier).reloadUserData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
