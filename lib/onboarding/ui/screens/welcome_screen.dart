import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/onboarding/application/onboarding_event.dart';
import 'package:ai_project/onboarding/providers/onboarding_provider.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

class WelcomeScreen extends HookConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingController = ref.read(onboardingProvider.notifier);

    // ── Animations ────────────────────────────────────────────────────────────
    final fadeCtrl = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );
    final floatCtrl = useAnimationController(duration: AppDurations.float);
    final glowCtrl = useAnimationController(duration: AppDurations.glow);

    useEffect(() {
      fadeCtrl.forward();
      floatCtrl.repeat(reverse: true);
      glowCtrl.repeat(reverse: true);
      return null;
    }, []);

    final fadeAnim = useAnimation(
      CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut),
    );
    final floatAnim = useAnimation(
      Tween<double>(
        begin: 0,
        end: -16,
      ).animate(CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut)),
    );
    final glowAnim = useAnimation(
      CurvedAnimation(parent: glowCtrl, curve: Curves.easeInOut),
    );

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          // ── Background glow ─────────────────────────────────────────────────
          Positioned(
            top: -100.h,
            left: -80.w,
            right: -80.w,
            child: AnimatedBuilder(
              animation: glowCtrl,
              builder: (_, __) => Container(
                height: 500.h,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08 + glowAnim * 0.06),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
              ),
            ),
          ),

          // ── Particles ──────────────────────────────────────────────────────
          const Positioned.fill(child: _Particles()),

          // ── Main content ───────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: AlwaysStoppedAnimation(fadeAnim),
              child: Column(
                children: [
                  const Spacer(),

                  // Sorty floating
                  Transform.translate(
                    offset: Offset(0, floatAnim),
                    child: SortyWidget(mood: SortyMood.happy, size: 140.w),
                  ),

                  SizedBox(height: 32.h),

                  // App wordmark
                  Text(
                    'SNAP & DIAGNOSE',
                    style: AppTextStyles.appName.copyWith(
                      fontSize: 14.sp,
                      letterSpacing: 0.28,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Headline
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Meet ',
                            style: GoogleFonts.syne(
                              fontSize: 46.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMain,
                              height: 1.05,
                            ),
                          ),
                          TextSpan(
                            text: 'Lung Lens',
                            style: GoogleFonts.syne(
                              fontSize: 46.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Your AI companion that scans chest X-rays to help catch pneumonia early',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSub,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // CTA button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: _GetStartedButton(
                      onTap: () => onboardingController.mapEventToState(
                        OnboardingEvent.nextPage(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Get Started Button ────────────────────────────────────────────────────────

class _GetStartedButton extends HookWidget {
  final VoidCallback onTap;
  const _GetStartedButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pressed = useState(false);
    final glowCtrl = useAnimationController(duration: AppDurations.glow);
    useEffect(() {
      glowCtrl.repeat(reverse: true);
      return null;
    }, []);
    final glowAnim = useAnimation(
      CurvedAnimation(parent: glowCtrl, curve: Curves.easeInOut),
    );

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
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.lgBr,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.30 + glowAnim * 0.20),
              blurRadius: 24 + glowAnim * 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Let's go ⚡",
              style: GoogleFonts.syne(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating particles ────────────────────────────────────────────────────────

class _Particles extends HookWidget {
  const _Particles();

  @override
  Widget build(BuildContext context) {
    final ctrl = useAnimationController(duration: const Duration(seconds: 6));
    useEffect(() {
      ctrl.repeat(reverse: true);
      return null;
    }, []);
    final anim = useAnimation(
      CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
    );

    return CustomPaint(
      painter: _ParticlesPainter(progress: anim),
      size: Size.infinite,
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double progress;
  _ParticlesPainter({required this.progress});

  static const _particles = [
    [0.10, 0.20, 4.0],
    [0.85, 0.15, 3.0],
    [0.20, 0.70, 5.0],
    [0.90, 0.55, 3.5],
    [0.50, 0.10, 4.5],
    [0.75, 0.80, 3.0],
    [0.05, 0.50, 2.5],
    [0.95, 0.35, 4.0],
    [0.40, 0.88, 3.0],
    [0.60, 0.30, 2.5],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final offset = (i.isEven ? progress : 1 - progress) * 12;
      final paint = Paint()
        ..color = AppColors.primary.withOpacity(0.12 + (i % 3) * 0.06)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width * p[0], size.height * p[1] + offset),
        p[2],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.progress != progress;
}
