import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/utils/app_theme.dart';

class HistoryIcon extends ConsumerWidget {
  const HistoryIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appController = ref.read(appProvider.notifier);

    return GestureDetector(
      onTap: () => appController.mapEventToState(AppEvent.goToHistory()),
      child: Container(
        width: 43.w,
        height: 43.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.40),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(
          Icons.history_rounded,
          color: AppColors.textMain,
          size: AppSizes.iconMd,
        ),
      ),
    );
  }
}
