import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ai_project/utils/app_theme.dart';

class CamGrid extends HookWidget {
  const CamGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = useAnimationController(duration: AppDurations.grid);
    useEffect(() {
      ctrl.repeat();
      return null;
    }, []);
    final offset = useAnimation(Tween<double>(begin: 0, end: 44).animate(ctrl));

    return CustomPaint(
      painter: _GridPainter(offset: offset),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  final double offset;
  _GridPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.038)
      ..strokeWidth = 1;

    // Vertical lines — static
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines — drift downward with animation
    for (double y = -(44 - offset % 44); y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.offset != offset;
}
