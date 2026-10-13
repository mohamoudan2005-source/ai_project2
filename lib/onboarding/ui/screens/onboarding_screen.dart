import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/ui/screens/main_screen.dart';
import 'package:ai_project/onboarding/application/onboarding_event.dart';
import 'package:ai_project/onboarding/application/onboarding_state.dart';
import 'package:ai_project/onboarding/providers/onboarding_provider.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingController = ref.read(onboardingProvider.notifier);
    final pageCtrl = usePageController(
      initialPage: onboardingState.currentPage,
    );

    // Sync external state → PageView
    useEffect(() {
      if (pageCtrl.hasClients &&
          pageCtrl.page?.round() != onboardingState.currentPage) {
        pageCtrl.animateToPage(
          onboardingState.currentPage,
          duration: AppDurations.slow,
          curve: AppCurves.smooth,
        );
      }
      return null;
    }, [onboardingState.currentPage]);

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Page view ─────────────────────────────────────────────────────────
            PageView.builder(
              controller: pageCtrl,
              itemCount: OnboardingPage.values.length,
              onPageChanged: (page) => onboardingController.mapEventToState(
                OnboardingEvent.goToPage(page),
              ),
              itemBuilder: (context, index) {
                final page = OnboardingPage.values[index];
                return _OnboardingPage(
                  page: page,
                  isActive: index == onboardingState.currentPage,
                );
              },
            ),

            // ── Bottom controls ───────────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomControls(
                currentPage: onboardingState.currentPage,
                totalPages: OnboardingPage.values.length,
                isLastPage: onboardingState.isLastPage,
                onNext: () {
                  if (onboardingState.isLastPage) {
                    onboardingController.mapEventToState(
                      OnboardingEvent.complete(),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  } else {
                    onboardingController.mapEventToState(
                      OnboardingEvent.nextPage(),
                    );
                  }
                },
                onSkip: () => onboardingController.mapEventToState(
                  OnboardingEvent.complete(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single onboarding page ────────────────────────────────────────────────────

class _OnboardingPage extends HookWidget {
  final OnboardingPage page;
  final bool isActive;

  const _OnboardingPage({required this.page, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final fadeCtrl = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );
    final floatCtrl = useAnimationController(duration: AppDurations.float);

    useEffect(() {
      if (isActive) {
        fadeCtrl.forward(from: 0);
        floatCtrl.repeat(reverse: true);
      }
      return null;
    }, [isActive]);

    final fadeAnim = useAnimation(
      CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut),
    );
    final floatAnim = useAnimation(
      Tween<double>(
        begin: 0,
        end: -14,
      ).animate(CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut)),
    );

    return SafeArea(
      child: FadeTransition(
        opacity: AlwaysStoppedAnimation(fadeAnim),
        child: Column(
          children: [
            const Spacer(),

            // ── Illustration ─────────────────────────────────────────────────
            Transform.translate(
              offset: Offset(0, floatAnim),
              child: _PageIllustration(page: page),
            ),
            SizedBox(height: 48.h),

            // ── Text ─────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.syne(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    page.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSub,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

// ── Page illustrations ────────────────────────────────────────────────────────

class _PageIllustration extends StatelessWidget {
  final OnboardingPage page;
  const _PageIllustration({required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case OnboardingPage.welcome:
        return SortyWidget(mood: SortyMood.happy, size: 140.w);

      case OnboardingPage.snap:
        return _ScanIllustration();

      case OnboardingPage.plan:
        return _AnalysisIllustration();

      case OnboardingPage.streak:
        return _ScanLogIllustration();

      case OnboardingPage.ready:
        return SortyWidget(mood: SortyMood.confident, size: 140.w);
    }
  }
}

// ── Scan illustration (was: Snap) ─────────────────────────────────────────────

class _ScanIllustration extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pulseCtrl = useAnimationController(
      duration: const Duration(milliseconds: 1800),
    );
    useEffect(() {
      pulseCtrl.repeat(reverse: true);
      return null;
    }, []);
    final pulseAnim = useAnimation(
      CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut),
    );

    return SizedBox(
      width: 200.w,
      height: 200.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring pulse
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) => Container(
              width: 180.w + pulseAnim * 20.w,
              height: 180.w + pulseAnim * 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15 + pulseAnim * 0.10),
                  width: 1,
                ),
              ),
            ),
          ),

          // Camera / X-ray frame
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.xlBr,
              border: Border.all(color: AppColors.limeBorder, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grid lines
                CustomPaint(painter: _GridPainter(), size: Size(140.w, 140.w)),

                // Corner brackets
                ..._corners(140.w),

                // Center sorty, looking closely at the scan
                SortyWidget(mood: SortyMood.thinking, size: 60.w),
              ],
            ),
          ),

          // Scan line sweeping down, like an X-ray being read
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) => Positioned(
              top: 30.h + pulseAnim * 80.h,
              left: 30.w,
              right: 30.w,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _corners(double size) {
    const len = 14.0;
    return [
      Positioned(top: 16, left: 16, child: _Corner(len: len, type: 0)),
      Positioned(top: 16, right: 16, child: _Corner(len: len, type: 1)),
      Positioned(bottom: 16, left: 16, child: _Corner(len: len, type: 2)),
      Positioned(bottom: 16, right: 16, child: _Corner(len: len, type: 3)),
    ];
  }
}

class _Corner extends StatelessWidget {
  final double len;
  final int type;
  const _Corner({required this.len, required this.type});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _CornerPainter(type: type, len: len),
    size: Size(len, len),
  );
}

class _CornerPainter extends CustomPainter {
  final int type;
  final double len;
  _CornerPainter({required this.type, required this.len});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    switch (type) {
      case 0:
        canvas.drawLine(Offset.zero, Offset(len, 0), p);
        canvas.drawLine(Offset.zero, Offset(0, len), p);
      case 1:
        canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), p);
        canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), p);
      case 2:
        canvas.drawLine(Offset(0, size.height), Offset(len, size.height), p);
        canvas.drawLine(
          Offset(0, size.height),
          Offset(0, size.height - len),
          p,
        );
      case 3:
        canvas.drawLine(
          Offset(size.width, size.height),
          Offset(size.width - len, size.height),
          p,
        );
        canvas.drawLine(
          Offset(size.width, size.height),
          Offset(size.width, size.height - len),
          p,
        );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.primary.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 20)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Analysis illustration (was: Plan) ─────────────────────────────────────────

class _AnalysisIllustration extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final staggerCtrl = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    useEffect(() {
      staggerCtrl.forward();
      return null;
    }, []);

    final steps = [
      ('👀', 'Looking at the X-ray', true),
      ('🔍', 'Checking for patterns', true),
      ('🧠', 'Comparing what I know', false),
      ('✅', 'All done', false),
    ];

    return SizedBox(
      width: 280.w,
      child: Column(
        children: steps.asMap().entries.map((e) {
          final delay = e.key * 0.2;
          return AnimatedBuilder(
            animation: staggerCtrl,
            builder: (_, __) {
              final t = ((staggerCtrl.value - delay) / 0.3).clamp(0.0, 1.0);
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(20 * (1 - t), 0),
                  child: _MiniStepCard(
                    emoji: e.value.$1,
                    title: e.value.$2,
                    isDone: e.value.$3,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _MiniStepCard extends StatelessWidget {
  final String emoji;
  final String title;
  final bool isDone;
  const _MiniStepCard({
    required this.emoji,
    required this.title,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.mdBr,
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppColors.primary : AppColors.limeBg,
            ),
            child: Center(
              child: Text(
                isDone ? '✓' : '·',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: isDone ? AppColors.dark : AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(emoji, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 8.w),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: isDone ? AppColors.textSub : AppColors.textMain,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan log illustration (was: Streak) ───────────────────────────────────────

class _ScanLogIllustration extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    useEffect(() {
      ctrl.forward();
      return null;
    }, []);

    // A handful of past scans: label + confidence, most recent first.
    final entries = [
      ('Normal', 0.98, false),
      ('Normal', 0.94, false),
      ('Pneumonia', 0.89, true),
      ('Normal', 0.91, false),
    ];

    return Column(
      children: [
        // Sorty confident
        SortyWidget(mood: SortyMood.confident, size: 90.w),
        SizedBox(height: 24.h),

        // Mini log list
        SizedBox(
          width: 240.w,
          child: Column(
            children: entries.asMap().entries.map((e) {
              final i = e.key;
              final delay = i * 0.15;
              return AnimatedBuilder(
                animation: ctrl,
                builder: (_, __) {
                  final t = ((ctrl.value - delay) / 0.3).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - t)),
                      child: _LogRow(
                        label: e.value.$1,
                        confidence: e.value.$2,
                        flagged: e.value.$3,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16.h),

        // Running total
        AnimatedBuilder(
          animation: ctrl,
          builder: (_, __) {
            final count = (ctrl.value * entries.length).round();
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🫁', style: TextStyle(fontSize: 24.sp)),
                SizedBox(width: 6.w),
                Text(
                  '$count scans logged',
                  style: GoogleFonts.syne(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  final String label;
  final double confidence;
  final bool flagged;
  const _LogRow({
    required this.label,
    required this.confidence,
    required this.flagged,
  });

  @override
  Widget build(BuildContext context) {
    final color = flagged ? AppColors.orange : AppColors.primary;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.mdBr,
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMain,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${(confidence * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSub),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.isLastPage,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.dark,
      padding: EdgeInsets.fromLTRB(28.w, 16.h, 28.w, 48.h),
      child: Column(
        children: [
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (i) => _Dot(isActive: i == currentPage),
            ),
          ),
          SizedBox(height: 24.h),

          // Next / Get Started button
          _NextButton(isLastPage: isLastPage, onTap: onNext),
          SizedBox(height: 12.h),

          // Skip
          if (!isLastPage)
            GestureDetector(
              onTap: onSkip,
              child: Text(
                'Skip',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDead,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      width: isActive ? 24.w : 8.w,
      height: 8.h,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white.withOpacity(0.15),
        borderRadius: AppRadius.pillBr,
      ),
    );
  }
}

class _NextButton extends HookWidget {
  final bool isLastPage;
  final VoidCallback onTap;
  const _NextButton({required this.isLastPage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pressed = useState(false);

    return GestureDetector(
      onTapDown: (_) => pressed.value = true,
      onTapUp: (_) => pressed.value = false,
      onTapCancel: () => pressed.value = false,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        transform: pressed.value
            ? (Matrix4.identity()..scale(0.96))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: AppDecorations.buttonPrimary,
        child: Text(
          isLastPage ? "Let's go 🫁" : 'Continue →',
          textAlign: TextAlign.center,
          style: AppTextStyles.buttonText,
        ),
      ),
    );
  }
}
