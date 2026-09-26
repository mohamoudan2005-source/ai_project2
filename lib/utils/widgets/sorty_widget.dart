import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_project/utils/app_theme.dart';

// ── Mood enum ─────────────────────────────────────────────────────────────────

enum SortyMood {
  happy,
  thinking,
  celebrating,
  confident,
  surprised,
  idle,
  concerned,
}

// ── Public widget ─────────────────────────────────────────────────────────────

class SortyWidget extends StatelessWidget {
  final SortyMood mood;
  final double? size;

  const SortyWidget({super.key, required this.mood, this.size});

  @override
  Widget build(BuildContext context) {
    final s = size ?? AppSizes.sortyCam;
    return SizedBox(
      width: s,
      height: s * 1.25,
      child: CustomPaint(painter: _SortyPainter(mood: mood)),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _SortyPainter extends CustomPainter {
  final SortyMood mood;
  const _SortyPainter({required this.mood});

  // ── Paints ────────────────────────────────────────────────────────────────

  static final _bodyFill = Paint()
    ..color = AppColors.primary
    ..style = PaintingStyle.fill;

  static final _bodyStroke = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  static final _bronchiStroke = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final _shineFill = Paint()
    ..color = const Color(0x30FFFFFF)
    ..style = PaintingStyle.fill;

  static final _darkFill = Paint()
    ..color = AppColors.dark
    ..style = PaintingStyle.fill;

  static final _whiteFill = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  static final _blushFill = Paint()
    ..color = const Color(0x55FF6B35)
    ..style = PaintingStyle.fill;

  static final _darkStroke = Paint()
    ..color = AppColors.dark
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // ── Main paint ────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawShadow(canvas, w, h);
    _drawBody(canvas, w, h);
    _drawBronchi(canvas, w, h);
    _drawShine(canvas, w, h);
    _drawBlush(canvas, w, h);
    _drawFace(canvas, w, h);
    _drawExtras(canvas, w, h);
  }

  @override
  bool shouldRepaint(_SortyPainter old) => old.mood != mood;

  // ── Shadow ────────────────────────────────────────────────────────────────

  void _drawShadow(Canvas canvas, double w, double h) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.97),
        width: w * 0.58,
        height: h * 0.06,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  // ── Body (lungs) ──────────────────────────────────────────────────────────

  void _drawBody(Canvas canvas, double w, double h) {
    _bodyStroke.strokeWidth = w * 0.032;
    final path = _lungsPath(w, h);
    canvas.drawPath(path, _bodyFill);
    canvas.drawPath(path, _bodyStroke);
  }

  /// Trachea + two branching lobes, built as three contours that share
  /// vertices along the centerline so they read as one solid silhouette.
  Path _lungsPath(double w, double h) {
    final path = Path();

    // Trachea (windpipe) at the top.
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.00, w * 0.12, h * 0.24),
        Radius.circular(w * 0.04),
      ),
    );

    // Left lobe.
    path.moveTo(w * 0.50, h * 0.22);
    path.cubicTo(w * 0.40, h * 0.16, w * 0.28, h * 0.14, w * 0.20, h * 0.20);
    path.cubicTo(w * 0.10, h * 0.26, w * 0.05, h * 0.38, w * 0.06, h * 0.52);
    path.cubicTo(w * 0.07, h * 0.68, w * 0.11, h * 0.83, w * 0.22, h * 0.91);
    path.cubicTo(w * 0.30, h * 0.96, w * 0.39, h * 0.87, w * 0.43, h * 0.75);
    path.cubicTo(w * 0.47, h * 0.62, w * 0.49, h * 0.48, w * 0.50, h * 0.36);
    path.cubicTo(w * 0.50, h * 0.30, w * 0.50, h * 0.26, w * 0.50, h * 0.22);
    path.close();

    // Right lobe (mirror of the left about x = 0.5).
    path.moveTo(w * 0.50, h * 0.22);
    path.cubicTo(w * 0.60, h * 0.16, w * 0.72, h * 0.14, w * 0.80, h * 0.20);
    path.cubicTo(w * 0.90, h * 0.26, w * 0.95, h * 0.38, w * 0.94, h * 0.52);
    path.cubicTo(w * 0.93, h * 0.68, w * 0.89, h * 0.83, w * 0.78, h * 0.91);
    path.cubicTo(w * 0.70, h * 0.96, w * 0.61, h * 0.87, w * 0.57, h * 0.75);
    path.cubicTo(w * 0.53, h * 0.62, w * 0.51, h * 0.48, w * 0.50, h * 0.36);
    path.cubicTo(w * 0.50, h * 0.30, w * 0.50, h * 0.26, w * 0.50, h * 0.22);
    path.close();

    return path;
  }

  // ── Bronchial tree ────────────────────────────────────────────────────────

  void _drawBronchi(Canvas canvas, double w, double h) {
    _bronchiStroke.strokeWidth = w * 0.024;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.50, h * 0.20)
        ..quadraticBezierTo(w * 0.44, h * 0.28, w * 0.34, h * 0.34),
      _bronchiStroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.50, h * 0.20)
        ..quadraticBezierTo(w * 0.56, h * 0.28, w * 0.66, h * 0.34),
      _bronchiStroke,
    );
  }

  // ── Inner shine ───────────────────────────────────────────────────────────

  void _drawShine(Canvas canvas, double w, double h) {
    // A soft highlight on the upper-outer curve of each lobe.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.20, h * 0.34),
        width: w * 0.10,
        height: h * 0.16,
      ),
      _shineFill,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.78, h * 0.32),
        width: w * 0.10,
        height: h * 0.16,
      ),
      _shineFill,
    );
  }

  // ── Blush ─────────────────────────────────────────────────────────────────

  void _drawBlush(Canvas canvas, double w, double h) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.34, h * 0.56),
        width: w * 0.20,
        height: h * 0.09,
      ),
      _blushFill,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.62, h * 0.52),
        width: w * 0.20,
        height: h * 0.09,
      ),
      _blushFill,
    );
  }

  // ── Face dispatcher ───────────────────────────────────────────────────────

  void _drawFace(Canvas canvas, double w, double h) {
    switch (mood) {
      case SortyMood.happy:
        _faceHappy(canvas, w, h);
        break;
      case SortyMood.thinking:
        _faceThinking(canvas, w, h);
        break;
      case SortyMood.celebrating:
        _faceCelebrating(canvas, w, h);
        break;
      case SortyMood.confident:
        _faceConfident(canvas, w, h);
        break;
      case SortyMood.surprised:
        _faceSurprised(canvas, w, h);
        break;
      case SortyMood.idle:
        _faceIdle(canvas, w, h);
        break;
      case SortyMood.concerned:
        _faceConcerned(canvas, w, h);
        break;
    }
  }

  // ── Happy ─────────────────────────────────────────────────────────────────

  void _faceHappy(Canvas canvas, double w, double h) {
    _drawRoundEyes(
      canvas,
      w,
      h,
      left: Offset(w * 0.42, h * 0.49),
      right: Offset(w * 0.60, h * 0.45),
      r: w * 0.086,
    );
    _drawSmile(
      canvas,
      w,
      h,
      from: Offset(w * 0.37, h * 0.61),
      control: Offset(w * 0.50, h * 0.72),
      to: Offset(w * 0.63, h * 0.61),
    );
  }

  // ── Thinking ──────────────────────────────────────────────────────────────

  void _faceThinking(Canvas canvas, double w, double h) {
    _drawRoundEyes(
      canvas,
      w,
      h,
      left: Offset(w * 0.42, h * 0.49),
      right: Offset(w * 0.60, h * 0.45),
      r: w * 0.086,
      leftPupilDx: -0.018,
      leftPupilDy: -0.018,
    );
    _drawBrow(
      canvas,
      w,
      h,
      from: Offset(w * 0.32, h * 0.41),
      to: Offset(w * 0.48, h * 0.39),
    );
    _drawBrow(
      canvas,
      w,
      h,
      from: Offset(w * 0.52, h * 0.37),
      to: Offset(w * 0.68, h * 0.35),
    );
    _drawSmile(
      canvas,
      w,
      h,
      from: Offset(w * 0.40, h * 0.61),
      control: Offset(w * 0.50, h * 0.60),
      to: Offset(w * 0.60, h * 0.61),
      width: w * 0.030,
    );
    _drawThoughtDots(canvas, w, h);
  }

  // ── Celebrating ───────────────────────────────────────────────────────────

  void _faceCelebrating(Canvas canvas, double w, double h) {
    _drawStarEye(canvas, Offset(w * 0.42, h * 0.48), w * 0.096);
    _drawStarEye(canvas, Offset(w * 0.60, h * 0.44), w * 0.096);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.63),
        width: w * 0.20,
        height: h * 0.11,
      ),
      _darkFill,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.64),
        width: w * 0.14,
        height: h * 0.07,
      ),
      Paint()
        ..color = const Color(0xFFE05030)
        ..style = PaintingStyle.fill,
    );
  }

  // ── Confident ─────────────────────────────────────────────────────────────

  void _faceConfident(Canvas canvas, double w, double h) {
    _drawSquintEye(canvas, Offset(w * 0.42, h * 0.49), w * 0.17, h * 0.075);
    _drawSquintEye(canvas, Offset(w * 0.60, h * 0.45), w * 0.17, h * 0.075);
    _drawBrow(
      canvas,
      w,
      h,
      from: Offset(w * 0.32, h * 0.41),
      to: Offset(w * 0.50, h * 0.40),
      width: w * 0.032,
    );
    _drawBrow(
      canvas,
      w,
      h,
      from: Offset(w * 0.52, h * 0.37),
      to: Offset(w * 0.70, h * 0.36),
      width: w * 0.032,
    );
    _drawSmile(
      canvas,
      w,
      h,
      from: Offset(w * 0.38, h * 0.61),
      control: Offset(w * 0.52, h * 0.68),
      to: Offset(w * 0.63, h * 0.60),
    );
  }

  // ── Surprised ─────────────────────────────────────────────────────────────

  void _faceSurprised(Canvas canvas, double w, double h) {
    _drawRoundEyes(
      canvas,
      w,
      h,
      left: Offset(w * 0.42, h * 0.48),
      right: Offset(w * 0.60, h * 0.44),
      r: w * 0.106,
    );
    _drawBrow(
      canvas,
      w,
      h,
      from: Offset(w * 0.30, h * 0.38),
      to: Offset(w * 0.50, h * 0.34),
    );
    _drawBrow(
      canvas,
      w,
      h,
      from: Offset(w * 0.52, h * 0.32),
      to: Offset(w * 0.70, h * 0.29),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.63),
        width: w * 0.15,
        height: h * 0.11,
      ),
      _darkFill,
    );
  }

  // ── Idle ──────────────────────────────────────────────────────────────────

  void _faceIdle(Canvas canvas, double w, double h) {
    _darkStroke.strokeWidth = w * 0.030;
    final leftEye = Path()
      ..moveTo(w * 0.33, h * 0.49)
      ..quadraticBezierTo(w * 0.42, h * 0.45, w * 0.51, h * 0.49);
    canvas.drawPath(leftEye, _darkStroke);
    final rightEye = Path()
      ..moveTo(w * 0.50, h * 0.46)
      ..quadraticBezierTo(w * 0.59, h * 0.42, w * 0.68, h * 0.46);
    canvas.drawPath(rightEye, _darkStroke);
    _drawSmile(
      canvas,
      w,
      h,
      from: Offset(w * 0.40, h * 0.61),
      control: Offset(w * 0.50, h * 0.66),
      to: Offset(w * 0.60, h * 0.61),
      width: w * 0.026,
    );
    _drawZs(canvas, w, h);
  }

  // ── Concerned ─────────────────────────────────────────────────────────────

  void _faceConcerned(Canvas canvas, double w, double h) {
    _drawRoundEyes(
      canvas,
      w,
      h,
      left: Offset(w * 0.42, h * 0.50),
      right: Offset(w * 0.60, h * 0.47),
      r: w * 0.076,
    );
    // Worried brows: inner corners raised, outer corners drop away.
    _drawBrow(
      canvas,
      w,
      h,
      from: Offset(w * 0.30, h * 0.42),
      to: Offset(w * 0.47, h * 0.35),
      width: w * 0.028,
    );
    _drawBrow(
      canvas,
      w,
      h,
      from: Offset(w * 0.53, h * 0.35),
      to: Offset(w * 0.70, h * 0.42),
      width: w * 0.028,
    );
    // Small frown (control point above the endpoints curves it upward).
    _drawSmile(
      canvas,
      w,
      h,
      from: Offset(w * 0.41, h * 0.66),
      control: Offset(w * 0.50, h * 0.60),
      to: Offset(w * 0.59, h * 0.66),
      width: w * 0.028,
    );
  }

  // ── Reusable face parts ───────────────────────────────────────────────────

  void _drawRoundEyes(
    Canvas canvas,
    double w,
    double h, {
    required Offset left,
    required Offset right,
    required double r,
    double leftPupilDx = 0,
    double leftPupilDy = 0,
    double rightPupilDx = 0,
    double rightPupilDy = 0,
  }) {
    canvas.drawCircle(left, r, _darkFill);
    canvas.drawCircle(right, r, _darkFill);

    canvas.drawCircle(left + Offset(r * 0.36, -r * 0.26), r * 0.34, _whiteFill);
    canvas.drawCircle(
      right + Offset(r * 0.36, -r * 0.26),
      r * 0.34,
      _whiteFill,
    );

    final pupilPaint = Paint()
      ..color = const Color(0xFF111100)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      left + Offset(leftPupilDx * w, leftPupilDy * h),
      r * 0.50,
      pupilPaint,
    );
    canvas.drawCircle(
      right + Offset(rightPupilDx * w, rightPupilDy * h),
      r * 0.50,
      pupilPaint,
    );
  }

  void _drawSquintEye(
    Canvas canvas,
    Offset center,
    double width,
    double height,
  ) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: height),
      _darkFill,
    );
    canvas.drawCircle(
      center + Offset(width * 0.18, -height * 0.15),
      width * 0.12,
      _whiteFill,
    );
  }

  void _drawStarEye(Canvas canvas, Offset center, double r) {
    final path = Path();
    const points = 5;
    for (int i = 0; i < points; i++) {
      final outerAngle = (i * 2 * _pi / points) - _pi / 2;
      final innerAngle = outerAngle + _pi / points;
      final ox = center.dx + r * _cos(outerAngle);
      final oy = center.dy + r * _sin(outerAngle);
      final ix = center.dx + r * 0.42 * _cos(innerAngle);
      final iy = center.dy + r * 0.42 * _sin(innerAngle);
      if (i == 0)
        path.moveTo(ox, oy);
      else
        path.lineTo(ox, oy);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, _darkFill);
    canvas.drawCircle(
      center + Offset(r * 0.28, -r * 0.22),
      r * 0.26,
      _whiteFill,
    );
  }

  void _drawSmile(
    Canvas canvas,
    double w,
    double h, {
    required Offset from,
    required Offset control,
    required Offset to,
    double? width,
  }) {
    _darkStroke.strokeWidth = width ?? w * 0.034;
    canvas.drawPath(
      Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy),
      _darkStroke,
    );
  }

  void _drawBrow(
    Canvas canvas,
    double w,
    double h, {
    required Offset from,
    required Offset to,
    double? width,
  }) {
    _darkStroke.strokeWidth = width ?? w * 0.026;
    canvas.drawLine(from, to, _darkStroke);
  }

  void _drawThoughtDots(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.80, h * 0.24), w * 0.030, paint);
    canvas.drawCircle(Offset(w * 0.86, h * 0.16), w * 0.044, paint);
    canvas.drawCircle(Offset(w * 0.93, h * 0.08), w * 0.058, paint);
  }

  void _drawZs(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.026
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawZ(double x, double y, double s) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + s, y)
          ..lineTo(x, y + s)
          ..lineTo(x + s, y + s),
        paint,
      );
    }

    drawZ(w * 0.74, h * 0.20, w * 0.060);
    drawZ(w * 0.80, h * 0.13, w * 0.076);
    drawZ(w * 0.87, h * 0.05, w * 0.092);
  }

  // ── Extras (sparkles & confetti) ──────────────────────────────────────────

  void _drawExtras(Canvas canvas, double w, double h) {
    switch (mood) {
      case SortyMood.celebrating:
        _drawConfetti(canvas, w, h);
        break;
      case SortyMood.idle:
      case SortyMood.thinking:
      case SortyMood.concerned:
        break;
      default:
        _drawSparkles(canvas, w, h);
        break;
    }
  }

  void _drawSparkles(Canvas canvas, double w, double h) {
    _drawStar4(
      canvas,
      center: Offset(w * 0.84, h * 0.12),
      r: w * 0.052,
      paint: Paint()
        ..color = AppColors.primary.withOpacity(0.60)
        ..style = PaintingStyle.fill,
    );
    _drawStar4(
      canvas,
      center: Offset(w * 0.14, h * 0.22),
      r: w * 0.036,
      paint: Paint()
        ..color = AppColors.primary.withOpacity(0.38)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(w * 0.90, h * 0.44),
      w * 0.020,
      Paint()
        ..color = AppColors.primary.withOpacity(0.32)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawStar4(
    Canvas canvas, {
    required Offset center,
    required double r,
    required Paint paint,
  }) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = i * _pi / 2 - _pi / 4;
      final a2 = a + _pi / 4;
      final ox = center.dx + r * _cos(a);
      final oy = center.dy + r * _sin(a);
      final ix = center.dx + r * 0.36 * _cos(a2);
      final iy = center.dy + r * 0.36 * _sin(a2);
      if (i == 0)
        path.moveTo(ox, oy);
      else
        path.lineTo(ox, oy);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawConfetti(Canvas canvas, double w, double h) {
    final pieces = [
      _ConfettiPiece(
        x: 0.08,
        y: 0.16,
        sw: 0.072,
        sh: 0.058,
        angle: 0.35,
        color: AppColors.primary,
      ),
      _ConfettiPiece(
        x: 0.80,
        y: 0.18,
        sw: 0.060,
        sh: 0.050,
        angle: -0.28,
        color: AppColors.orange,
      ),
      _ConfettiPiece(
        x: 0.82,
        y: 0.52,
        sw: 0.058,
        sh: 0.048,
        angle: 0.55,
        color: AppColors.primary,
      ),
      _ConfettiPiece(
        x: 0.06,
        y: 0.52,
        sw: 0.048,
        sh: 0.040,
        angle: -0.40,
        color: Colors.white,
      ),
      _ConfettiPiece(
        x: 0.44,
        y: 0.04,
        sw: 0.044,
        sh: 0.036,
        angle: 0.20,
        color: AppColors.orange,
      ),
    ];

    for (final p in pieces) {
      canvas.save();
      canvas.translate(w * p.x + w * p.sw / 2, h * p.y + h * p.sh / 2);
      canvas.rotate(p.angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: w * p.sw,
            height: h * p.sh,
          ),
          const Radius.circular(2),
        ),
        Paint()
          ..color = p.color.withOpacity(0.82)
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }

    canvas.drawCircle(
      Offset(w * 0.88, h * 0.36),
      w * 0.038,
      Paint()
        ..color = AppColors.primary.withOpacity(0.70)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(w * 0.12, h * 0.38),
      w * 0.028,
      Paint()
        ..color = AppColors.orange.withOpacity(0.65)
        ..style = PaintingStyle.fill,
    );
  }

  // ── Math helpers ──────────────────────────────────────────────────────────

  static const _pi = 3.14159265358979;

  static double _cos(double a) {
    a = a % (2 * _pi);
    if (a < 0) a += 2 * _pi;
    double r = 1, t = 1;
    for (int i = 1; i <= 12; i++) {
      t *= -a * a / ((2 * i - 1) * (2 * i));
      r += t;
    }
    return r;
  }

  static double _sin(double a) => _cos(a - _pi / 2);
}

// ── Confetti piece data ───────────────────────────────────────────────────────

class _ConfettiPiece {
  final double x, y, sw, sh, angle;
  final Color color;
  const _ConfettiPiece({
    required this.x,
    required this.y,
    required this.sw,
    required this.sh,
    required this.angle,
    required this.color,
  });
}
