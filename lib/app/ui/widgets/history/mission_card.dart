import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/ui/screens/examination_detail_screen.dart';
import 'package:ai_project/utils/app_theme.dart';

class MissionCard extends StatelessWidget {
  final PredictionHistoryItem item;
  final int index;
  const MissionCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final probability = item.probability;
    final probabilityPct = (probability * 100).toStringAsFixed(1);
    final hasPatient =
        item.patientName != null && item.patientName!.trim().isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExaminationDetailScreen(item: item, index: index),
          ),
        );
      },
      child: Container(
        padding: AppSpacing.cardPad,
        decoration: AppDecorations.card,
        child: Row(
          children: [
            // Thumbnail (supports Firebase Storage photoURL with local file fallback)
            Container(
              width: AppSizes.histThumb,
              height: AppSizes.histThumb,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.histThumbRadius),
                color: Colors.black,
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildThumbnail(),
            ),
            SizedBox(width: 14.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasPatient
                        ? item.patientName!
                        : "Examination #${index + 1}",
                    style: AppTextStyles.headingSmall.copyWith(
                      color: item.isPneumonia
                          ? AppColors.orange
                          : AppColors.textMain,
                      fontSize: 15.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "${item.label.toUpperCase()} • $probabilityPct% probability",
                    style: GoogleFonts.nunito(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: item.isPneumonia
                          ? AppColors.orange
                          : AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${item.completedAt.day}/${item.completedAt.month}/${item.completedAt.year}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textDead,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),

            // Open Detail Arrow Badge
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (item.photoURL != null && item.photoURL!.isNotEmpty) {
      return Image.network(
        item.photoURL!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildLocalFallback(),
      );
    }
    return _buildLocalFallback();
  }

  Widget _buildLocalFallback() {
    if (item.photoPath.isNotEmpty) {
      final file = File(item.photoPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.muted),
        );
      }
    }
    return Container(
      color: AppColors.cardAlt,
      child: Icon(
        Icons.medical_services_outlined,
        color: AppColors.textSub,
        size: 20.sp,
      ),
    );
  }
}
