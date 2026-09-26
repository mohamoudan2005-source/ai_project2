import 'dart:io';

import 'package:ai_project/app/models/prediction_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_project/utils/app_theme.dart';

class MissionCard extends StatelessWidget {
  final PredictionHistoryItem item;
  final int index;
  const MissionCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final probability = item.probability;

    final ProbabilityPct = (probability * 100).toStringAsFixed(1);

    return Container(
      padding: AppSpacing.cardPad,
      decoration: AppDecorations.card,
      child: Row(
        children: [
          // Thumbnail
          if (item.photoPath.isNotEmpty)
            Container(
              width: AppSizes.histThumb,
              height: AppSizes.histThumb,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.histThumbRadius),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                File(item.photoPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.muted),
              ),
            ),
          SizedBox(width: 14.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Result #${index + 1} ${item.label.toUpperCase()}",
                  style: AppTextStyles.headingSmall.copyWith(
                    color: item.isPneumonia
                        ? AppColors.orange
                        : AppColors.textMain,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  ' Probability: $ProbabilityPct%  '
                  '${item.completedAt.day}/${item.completedAt.month}/${item.completedAt.year}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          // Check
          Container(
            width: 28.w,
            height: 28.w,
            decoration: AppDecorations.badgeLime,
            child: Center(child: Text('✓', style: AppTextStyles.label)),
          ),
        ],
      ),
    );
  }
}
