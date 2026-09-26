import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_state.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/ui/screens/camera_screen.dart';
import 'package:ai_project/app/ui/screens/complete_screen.dart';
import 'package:ai_project/app/ui/screens/history_screen.dart';
import 'package:ai_project/app/ui/screens/scanning_screen.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(appProvider).screen;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: switch (screen) {
        AppScreen.camera => const CameraScreen(),
        AppScreen.scanning => const ScanningScreen(),
        AppScreen.complete => const CompleteScreen(),
        AppScreen.history => const HistoryScreen(),
      },
    );
  }
}
