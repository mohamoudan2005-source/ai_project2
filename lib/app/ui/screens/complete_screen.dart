import 'package:ai_project/app/ui/screens/is_not_xray_screen.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

import '../widgets/streak_pill.dart';

class CompleteScreen extends HookConsumerWidget {
  const CompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final appController = ref.read(appProvider.notifier);

    // Prediction result coming from the model
    final result = appState.result; // PredictionResult?
    final isPneumonia = result?.isPneumonia ?? false;
    final label = result?.label ?? 'Unknown';
    final probability = result?.probability ?? 0.0;
    final ProbabilityPct = (probability * 100).toStringAsFixed(1);

    // Only celebrate with confetti when the result is Normal
    final confettiCtrl = useMemoized(
      () => ConfettiController(duration: const Duration(seconds: 4)),
    );
    useEffect(() {
      if (!isPneumonia) {
        confettiCtrl.play();
      }
      return confettiCtrl.dispose;
    }, [isPneumonia]);

    // Sorty pop animation
    final popCtrl = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );
    useEffect(() {
      popCtrl.forward();
      return null;
    }, []);
    final popAnim = useAnimation(
      CurvedAnimation(parent: popCtrl, curve: Curves.elasticOut),
    );

    final resultColor = isPneumonia ? AppColors.orange : AppColors.primary;

    return !appState.isXray
        ? IsNotXrayScreen(appController: appController, popAnim: popAnim)
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              appController.mapEventToState(AppEvent.goToCamera());
            },
            child: Scaffold(
              backgroundColor: AppColors.dark,
              body: Stack(
                children: [
                  // Confetti (only fires for Normal results)
                  if (!isPneumonia)
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: confettiCtrl,
                        blastDirectionality: BlastDirectionality.explosive,
                        colors: const [
                          AppColors.primary,
                          AppColors.orange,
                          Colors.white,
                        ],
                        numberOfParticles: 40,
                        maxBlastForce: 30,
                        minBlastForce: 10,
                      ),
                    ),

                  // Content
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Sorty reacting to the result
                          Transform.scale(
                            scale: popAnim,
                            child: SortyWidget(
                              mood: isPneumonia
                                  ? SortyMood.concerned
                                  : SortyMood.celebrating,
                              size: AppSizes.sortyComplete,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Result label
                          Text(
                            label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.displayLarge.copyWith(
                              color: resultColor,
                              height: 1.0,
                              fontSize: isPneumonia ? 32.sp : 44.sp,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Probability
                          Text(
                            'Probability: $ProbabilityPct%',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge,
                          ),
                          SizedBox(height: 6.h),

                          Text(
                            isPneumonia
                                ? 'The scan shows signs consistent with pneumonia. Please consult a doctor for a proper diagnosis.'
                                : 'No signs of pneumonia were detected in this scan.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall,
                          ),
                          SizedBox(height: 50.h),

                          // Streak
                          StreakPill(streak: appState.streak, large: true),
                          SizedBox(height: 80.h),

                          // New scan button
                          GestureDetector(
                            onTap: () => appController.mapEventToState(
                              AppEvent.goToCamera(),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: AppDecorations.buttonPrimary,
                              child: Text(
                                'Scan Another X-Ray',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.buttonText,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // History button
                          GestureDetector(
                            onTap: () => appController.mapEventToState(
                              AppEvent.goToHistory(),
                            ),
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
                ],
              ),
            ),
          );
  }
}
