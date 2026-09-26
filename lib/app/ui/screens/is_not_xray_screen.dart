import 'package:ai_project/app/application/app_controller.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IsNotXrayScreen extends StatelessWidget {
  const IsNotXrayScreen({
    super.key,
    required this.appController,
    required this.popAnim,
  });
  final AppController appController;
  final double popAnim;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        appController.mapEventToState(AppEvent.goToCamera());
      },
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: popAnim,
                  child: SortyWidget(
                    mood: SortyMood.concerned,
                    size: AppSizes.sortyComplete,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'NOT AN \nX-RAY',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.orange,
                    height: 1.0,
                    fontSize: 36.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "The image you selected doesn't look like a chest X-ray, "
                  'so we couldn\'t analyze it.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Please choose a clear chest X-ray image and try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
                SizedBox(height: 80.h),
                GestureDetector(
                  onTap: () =>
                      appController.mapEventToState(AppEvent.goToCamera()),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: AppDecorations.buttonPrimary,
                    child: Text(
                      'Try Another Image',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonText,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () =>
                      appController.mapEventToState(AppEvent.goToHistory()),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: AppDecorations.buttonGhost,
                    child: Text(
                      'See All Scans',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonTextLight.copyWith(
                        color: AppColors.textSub,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
