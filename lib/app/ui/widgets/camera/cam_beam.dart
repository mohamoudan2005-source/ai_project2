import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ai_project/utils/app_theme.dart';

class CamBeam extends HookWidget {
  final AnimationController ctrl;
  const CamBeam({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final anim = useAnimation(
      CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final beamY = 32 + anim * (h - 64);
        final isVisible = anim > 0.05 && anim < 0.95;

        return CustomPaint(
          painter: _BeamPainter(beamY: beamY, isVisible: isVisible),
          size: Size(constraints.maxWidth, h),
        );
      },
    );
  }
}

class _BeamPainter extends CustomPainter {
  final double beamY;
  final bool isVisible;
  _BeamPainter({required this.beamY, required this.isVisible});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isVisible) return;

    // ── Beam line ─────────────────────────────────────────────────────────────
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary.withOpacity(0.75),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, beamY - 1, size.width, 2))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(28, beamY),
      Offset(size.width - 28, beamY),
      beamPaint,
    );

    // ── Glow below beam ───────────────────────────────────────────────────────
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary.withOpacity(0.10), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, beamY, size.width, 55));

    canvas.drawRect(Rect.fromLTWH(0, beamY, size.width, 55), glowPaint);
  }

  @override
  bool shouldRepaint(_BeamPainter old) =>
      old.beamY != beamY || old.isVisible != isVisible;
}
