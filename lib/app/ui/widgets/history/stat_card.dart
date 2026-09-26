import 'package:ai_project/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.decoration,
    required this.accentColor,
  });

  final String emoji;
  final String value;
  final String label;
  final BoxDecoration decoration;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 14.w),
      decoration: decoration,
      child: Column(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: AppRadius.smBr,
            ),
            child: Text(emoji, style: TextStyle(fontSize: 16.sp)),
          ),
          SizedBox(height: 12.h),
          Text(value, style: AppTextStyles.displayMedium),
          SizedBox(height: 4.h),
          Text(label, textAlign: TextAlign.center, style: AppTextStyles.hint),
        ],
      ),
    );
  }
}
