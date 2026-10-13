import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_project/utils/app_theme.dart';

class NewSnapButton extends StatelessWidget {
  const NewSnapButton({super.key, required this.onNewSnap});
  final Function() onNewSnap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onNewSnap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: AppRadius.pillBr,
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Text('← New Snap', style: AppTextStyles.caption),
      ),
    );
  }
}
