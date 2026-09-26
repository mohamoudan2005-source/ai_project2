import 'package:ai_project/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.emoji, required this.title});

  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 18.sp)),
        SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.primary,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }
}
