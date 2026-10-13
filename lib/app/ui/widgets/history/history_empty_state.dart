import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SortyWidget(mood: SortyMood.idle, size: AppSizes.sortyHistory),
          SizedBox(height: 16.h),
          Text('Nothing here yet.', style: AppTextStyles.headingSmall),
          SizedBox(height: 6.h),
          Text(
            "Your next scan is ready.\nGo check it out.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
