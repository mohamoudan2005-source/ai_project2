import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakPill extends HookWidget {
  final int streak;
  final bool large;

  const StreakPill({super.key, required this.streak, this.large = false});

  @override
  Widget build(BuildContext context) {
    final glowCtrl = useAnimationController(
      duration: const Duration(milliseconds: 1800),
    );

    useEffect(() {
      glowCtrl.repeat(reverse: true);
      return null;
    }, []);

    final glowAnim = useAnimation(
      CurvedAnimation(parent: glowCtrl, curve: Curves.easeInOut),
    );

    final isOnFire = streak >= 7;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: _bgColor(streak).withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _borderColor(streak).withOpacity(0.3 + glowAnim * 0.25),
          width: 1,
        ),
        boxShadow: isOnFire
            ? [
                BoxShadow(
                  color: const Color(
                    0xFFC8F135,
                  ).withOpacity(0.15 + glowAnim * 0.15),
                  blurRadius: 12 + glowAnim * 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StreakIcon(streak: streak, glowAnim: glowAnim),
          SizedBox(width: large ? 8 : 5),
          Text(
            '$streak',
            style: GoogleFonts.syne(
              fontSize: large ? 16 : 13,
              fontWeight: FontWeight.w800,
              color: _textColor(streak),
            ),
          ),
          if (large) ...[
            const SizedBox(width: 4),
            Text(
              streak == 1 ? 'time' : 'times',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textColor(streak).withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _bgColor(int s) {
    if (s == 0) return const Color(0xFF8A8A80);
    if (s < 3) return const Color(0xFFC8F135);
    if (s < 7) return const Color(0xFFFF6B35);
    return const Color(0xFFC8F135);
  }

  Color _borderColor(int s) {
    if (s == 0) return const Color(0xFF8A8A80);
    if (s < 3) return const Color(0xFFC8F135);
    if (s < 7) return const Color(0xFFFF6B35);
    return const Color(0xFFC8F135);
  }

  Color _textColor(int s) {
    if (s == 0) return const Color(0xFF8A8A80);
    if (s < 3) return const Color(0xFFC8F135);
    if (s < 7) return const Color(0xFFFF6B35);
    return const Color(0xFFC8F135);
  }
}

// ── Streak icon ───────────────────────────────────────────────────────────────

class _StreakIcon extends HookWidget {
  final int streak;
  final double glowAnim;

  const _StreakIcon({required this.streak, required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    final scaleCtrl = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );

    useEffect(() {
      scaleCtrl.forward(from: 0);
      return null;
    }, [streak]);

    final scaleAnim = useAnimation(
      TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.90), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(parent: scaleCtrl, curve: Curves.easeOut)),
    );

    return Transform.scale(
      scale: scaleAnim,
      child: Text(_icon, style: TextStyle(fontSize: 14 + glowAnim * 1.5)),
    );
  }

  String get _icon {
    if (streak == 0) return '💤';
    if (streak < 3) return '⚡';
    if (streak < 7) return '🔥';
    if (streak < 14) return '🔥🔥';
    if (streak < 30) return '⚡🔥';
    return '👑';
  }
}

// ── Milestone banner ──────────────────────────────────────────────────────────

class StreakMilestoneBanner extends HookWidget {
  final int streak;
  final VoidCallback onDismiss;

  const StreakMilestoneBanner({
    super.key,
    required this.streak,
    required this.onDismiss,
  });

  static bool isMilestone(int streak) =>
      streak == 3 || streak == 7 || streak == 14 || streak == 30;

  String get _message {
    switch (streak) {
      case 3:
        return "3 days in a row. We're building something here. ⚡";
      case 7:
        return "A whole week. Sorty is officially proud of you. 🔥";
      case 14:
        return "Two weeks straight. You're on another level. 🚀";
      case 30:
        return "30 days. You're not the same person who downloaded this app. 👑";
      default:
        return "$streak day streak. Keep going!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final slideCtrl = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final fadeCtrl = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // ✅ Animation<Offset> — NOT unwrapped with useAnimation
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideCtrl, curve: Curves.elasticOut));

    // ✅ Animation<double> — NOT unwrapped with useAnimation
    final fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: fadeCtrl, curve: Curves.easeIn));

    useEffect(() {
      slideCtrl.forward();
      Future.delayed(const Duration(seconds: 4), () {
        if (slideCtrl.isCompleted) {
          fadeCtrl.forward().then((_) => onDismiss());
        }
      });
      return null;
    }, []);

    return SlideTransition(
      position: slideAnimation, // ✅ Animation<Offset>
      child: FadeTransition(
        opacity: fadeAnimation, // ✅ Animation<double>
        child: GestureDetector(
          onTap: () => fadeCtrl.forward().then((_) => onDismiss()),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC8F135).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC8F135).withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                StreakPill(streak: streak),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _message,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF0EFE8),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF8A8A80),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
