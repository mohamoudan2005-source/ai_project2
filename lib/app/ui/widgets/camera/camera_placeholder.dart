import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_project/app/ui/screens/cam_grid.dart';
import 'package:ai_project/app/ui/widgets/camera/bottom_bar.dart';
import 'package:ai_project/utils/app_theme.dart';

class CameraPlaceholder extends StatelessWidget {
  const CameraPlaceholder({super.key, required this.onGallery});
  final Function() onGallery;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D0C),
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          const Positioned.fill(child: CamGrid()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary.withOpacity(0.3),
                  size: 48.w,
                ),
                SizedBox(height: 10.h),
                Text(
                  'Camera loading…',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60.h,
            child: BottomBar(pickImage: onGallery, takePhoto: () {}),
          ),
        ],
      ),
    );
  }
}
