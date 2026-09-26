import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'dart:io';

import 'package:ai_project/utils/widgets/sorty_widget.dart';

const _scanPhrases = [
  "Okay. Let's check it out. 👀",
  "Got it. Scanning now.",
  "Taking a closer look. 🩻",
  "Let's see what we're dealing with.",
  "Almost there. Checking for pneumonia.",
];

class ScanningScreen extends HookConsumerWidget {
  const ScanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final appController = ref.read(appProvider.notifier);

    final progress = useState(0.0);
    final phraseIndex = useState(0);
    final photoPath = appState.photoPath;
    final isLoading = appState.isLoading;

    final bounceCtrl = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    final ringCtrl = useAnimationController(
      duration: const Duration(milliseconds: 2200),
    );

    useEffect(() {
      bounceCtrl.repeat(reverse: true);
      ringCtrl.repeat();
      return null;
    }, []);

    // Animate progress to 80% then wait for API
    useEffect(() {
      if (isLoading) return null;
      // Animate to 80% for initial scan
      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 80));
        if (progress.value >= 0.80) return false;
        progress.value = (progress.value + 0.02).clamp(0.0, 0.80);
        phraseIndex.value = (progress.value * (_scanPhrases.length - 1))
            .round()
            .clamp(0, _scanPhrases.length - 1);
        return true;
      }).then((_) {
        // Navigate to time picker
        appController.mapEventToState(AppEvent.analyzeMission());
      });
      return null;
    }, []);

    // When loading (API call), animate to 100%
    useEffect(() {
      if (!isLoading) return null;
      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 60));
        if (progress.value >= 1.0) return false;
        progress.value = (progress.value + 0.015).clamp(0.0, 1.0);
        return true;
      });
      return null;
    }, [isLoading]);

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          // Blurred photo background
          if (photoPath != null)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.72),
                  BlendMode.darken,
                ),
                child: Image.file(
                  File(photoPath),
                  fit: BoxFit.cover,
                  color: Colors.grey.withOpacity(0.5),
                  colorBlendMode: BlendMode.saturation,
                ),
              ),
            ),
          // Dark gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.dark.withOpacity(0.4),
                    AppColors.dark.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulse rings
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: ringCtrl,
                      builder: (_, __) => Opacity(
                        opacity: (1 - ringCtrl.value).clamp(0, 1),
                        child: Transform.scale(
                          scale: 0.85 + (ringCtrl.value * 0.75),
                          child: Container(
                            width: 220.w,
                            height: 260.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Sorty bouncing
                    AnimatedBuilder(
                      animation: bounceCtrl,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          0,
                          -8 *
                              CurvedAnimation(
                                parent: bounceCtrl,
                                curve: Curves.easeInOut,
                              ).value,
                        ),
                        child: child,
                      ),
                      child: SortyWidget(
                        mood: SortyMood.thinking,
                        size: 110.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                // Scan phrase
                AnimatedSwitcher(
                  duration: 350.ms,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.84,
                    child: Text(
                      _scanPhrases[phraseIndex.value],
                      key: ValueKey(phraseIndex.value),
                      style: GoogleFonts.syne(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.r),
                    child: LinearProgressIndicator(
                      value: progress.value,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                      minHeight: 10.h,
                    ),
                  ),
                ),
                SizedBox(height: 13.h),
                Text(
                  '${(progress.value * 100).round()}%',
                  style: GoogleFonts.syne(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
