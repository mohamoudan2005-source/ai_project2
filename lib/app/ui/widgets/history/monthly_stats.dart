import 'package:ai_project/app/models/prediction_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:ai_project/utils/app_theme.dart';

/// Calendar-style heatmap, one month at a time — one cell per day, colored
/// by how many scans happened that day. Tap a day to see its scan count
/// (and results). Defaults to the current month, with arrows to browse
/// other months. Built entirely from AppTheme tokens.
class MonthlyStats extends StatefulWidget {
  const MonthlyStats({super.key, required this.history});

  final List<PredictionHistoryItem> history;

  @override
  State<MonthlyStats> createState() => _MonthlyStatsState();
}

class _MonthlyStatsState extends State<MonthlyStats> {
  late DateTime _selectedMonth;

  static DateTime get _currentMonthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  @override
  void initState() {
    super.initState();
    _selectedMonth = _currentMonthStart;
  }

  bool get _isCurrentMonth =>
      _selectedMonth.year == _currentMonthStart.year &&
      _selectedMonth.month == _currentMonthStart.month;

  void _changeMonth(int offset) {
    setState(() {
      final next = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
      // Never navigate past the current month.
      _selectedMonth = next.isAfter(_currentMonthStart)
          ? _currentMonthStart
          : next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, List<PredictionHistoryItem>> itemsByDay = {};
    for (final item in widget.history) {
      final d = item.completedAt;
      if (d.year == _selectedMonth.year && d.month == _selectedMonth.month) {
        itemsByDay.putIfAbsent(d.day, () => []).add(item);
      }
    }
    final total = itemsByDay.values.fold<int>(0, (a, list) => a + list.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: AppRadius.smBr,
              ),
              child: Text('📅', style: TextStyle(fontSize: 15.sp)),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Monthly Activity',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.primary,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Padding(
          padding: EdgeInsets.only(left: 44.w),
          child: Text(
            '$total scan${total == 1 ? '' : 's'} in ${DateFormat('MMMM yyyy').format(_selectedMonth)} · tap a day for details',
            style: AppTextStyles.caption,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: AppSpacing.cardPad,
          decoration: AppDecorations.card,
          child: Column(
            children: [
              _MonthNav(
                month: _selectedMonth,
                isCurrentMonth: _isCurrentMonth,
                onPrevious: () => _changeMonth(-1),
                onNext: _isCurrentMonth ? null : () => _changeMonth(1),
              ),
              SizedBox(height: AppSpacing.md),
              _MonthGrid(itemsByDay: itemsByDay, month: _selectedMonth),
              SizedBox(height: AppSpacing.md),
              _Legend(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Month navigator ──────────────────────────────────────────────────────

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.month,
    required this.isCurrentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final bool isCurrentMonth;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Column(
          children: [
            Text(
              DateFormat('MMMM yyyy').format(month),
              style: AppTextStyles.headingMedium.copyWith(fontSize: 16.sp),
            ),
            if (isCurrentMonth)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  'CURRENT',
                  style: AppTextStyles.hint.copyWith(
                    fontSize: 9.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: AppRadius.smBr,
        ),
        child: Icon(
          icon,
          size: 20.w,
          color: enabled ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.itemsByDay, required this.month});

  final Map<int, List<PredictionHistoryItem>> itemsByDay;
  final DateTime month;

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  int levelFor(int count, int maxCount) {
    if (count == 0 || maxCount == 0) return 0;
    final ratio = count / maxCount;
    if (ratio <= 0.25) return 1;
    if (ratio <= 0.5) return 2;
    if (ratio <= 0.75) return 3;
    return 4;
  }

  Color colorFor(int level) {
    switch (level) {
      case 0:
        return Colors.white.withOpacity(0.06);
      case 1:
        return AppColors.primary.withOpacity(0.25);
      case 2:
        return AppColors.primary.withOpacity(0.45);
      case 3:
        return AppColors.primary.withOpacity(0.7);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == month.year && today.month == month.month;

    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday -> 0

    final maxCount = itemsByDay.values.isEmpty
        ? 0
        : itemsByDay.values
              .map((l) => l.length)
              .reduce((a, b) => a > b ? a : b);

    final totalCells = leadingBlanks + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: [
        // Weekday header
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        for (int row = 0; row < rowCount; row++) ...[
          Row(
            children: [
              for (int col = 0; col < 7; col++) ...[
                Expanded(
                  child: _buildCell(
                    context,
                    row * 7 + col,
                    leadingBlanks,
                    daysInMonth,
                    maxCount,
                    isCurrentMonth,
                    today,
                  ),
                ),
              ],
            ],
          ),
          if (row != rowCount - 1) SizedBox(height: 6.h),
        ],
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    int cellIndex,
    int leadingBlanks,
    int daysInMonth,
    int maxCount,
    bool isCurrentMonth,
    DateTime today,
  ) {
    final dayNum = cellIndex - leadingBlanks + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return AspectRatio(aspectRatio: 1, child: const SizedBox.shrink());
    }

    final date = DateTime(month.year, month.month, dayNum);
    final dayItems = itemsByDay[dayNum] ?? const [];
    final count = dayItems.length;
    final level = levelFor(count, maxCount);
    final color = colorFor(level);
    final isToday = isCurrentMonth && today.day == dayNum;
    final isFuture = date.isAfter(DateTime(today.year, today.month, today.day));
    final textColor = level >= 3 ? AppColors.dark : AppColors.textMain;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: GestureDetector(
          onTap: isFuture
              ? null
              : () => _showDayDetail(context, date, dayItems),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
              border: isToday
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Text(
              '$dayNum',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12.sp,
                color: isFuture ? textColor.withOpacity(0.35) : textColor,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDayDetail(
    BuildContext context,
    DateTime date,
    List<PredictionHistoryItem> items,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DayDetailSheet(date: date, items: items),
    );
  }
}

// ── Day detail bottom sheet ──────────────────────────────────────────────

class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({required this.date, required this.items});

  final DateTime date;
  final List<PredictionHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.modalPad,
      decoration: AppDecorations.topSheet,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: AppSizes.modalHandle,
                  height: AppSizes.modalHandleHeight,
                  margin: EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(date),
                style: AppTextStyles.headingSmall,
              ),
              SizedBox(height: 4.h),
              Text(
                items.isEmpty
                    ? 'No scans on this day'
                    : '${items.length} scan${items.length == 1 ? '' : 's'}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              if (items.isNotEmpty)
                ...items.map((item) => _DayDetailRow(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayDetailRow extends StatelessWidget {
  const _DayDetailRow({required this.item});

  final PredictionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isPneumonia ? AppColors.orange : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.cardPad,
      decoration: item.isPneumonia
          ? AppDecorations.cardOrange
          : AppDecorations.cardLime,
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${(item.probability * 100).toStringAsFixed(1)}%',
            style: AppTextStyles.caption,
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            DateFormat('HH:mm').format(item.completedAt),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final levels = [
      Colors.white.withOpacity(0.06),
      AppColors.primary.withOpacity(0.25),
      AppColors.primary.withOpacity(0.45),
      AppColors.primary.withOpacity(0.7),
      AppColors.primary,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: AppTextStyles.caption.copyWith(fontSize: 10.sp)),
        SizedBox(width: 4.w),
        for (final color in levels)
          Container(
            width: 10.w,
            height: 10.w,
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        SizedBox(width: 4.w),
        Text('More', style: AppTextStyles.caption.copyWith(fontSize: 10.sp)),
      ],
    );
  }
}
