import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/ui/widgets/camera/history_icon.dart';
import 'package:ai_project/app/ui/widgets/streak_pill.dart';

class CameraTopBar extends HookConsumerWidget {
  const CameraTopBar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreakPill(streak: appState.streak),
          HistoryIcon(),
        ],
      ),
    );
  }
}
