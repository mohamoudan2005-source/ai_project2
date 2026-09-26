import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_project/utils/app_theme.dart';

class CamCorners extends HookWidget {
  const CamCorners({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = useAnimationController(
      duration: const Duration(milliseconds: 1400),
    );
    useEffect(() {
      ctrl.repeat(reverse: true);
      return null;
    }, []);
    final opacity = useAnimation(
      Tween<double>(
        begin: 0.45,
        end: 1.0,
      ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut)),
    );

    return Opacity(
      opacity: opacity,
      child: Stack(
        children: [
          Positioned(
            top: 50.sp,
            left: 32.sp,
            child: _Corner(type: _CornerType.tl),
          ),
          Positioned(
            top: 50.sp,
            right: 32.sp,
            child: _Corner(type: _CornerType.tr),
          ),
          Positioned(
            bottom: 35.sp,
            left: 32.sp,
            child: _Corner(type: _CornerType.bl),
          ),
          Positioned(
            bottom: 35.sp,
            right: 32.sp,
            child: _Corner(type: _CornerType.br),
          ),
        ],
      ),
    );
  }
}

enum _CornerType { tl, tr, bl, br }

class _Corner extends StatelessWidget {
  final _CornerType type;
  const _Corner({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _CornerPainter(type: type)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final _CornerType type;
  _CornerPainter({required this.type});

  static const _len = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    switch (type) {
      case _CornerType.tl:
        canvas.drawLine(Offset.zero, const Offset(_len, 0), paint);
        canvas.drawLine(Offset.zero, const Offset(0, _len), paint);
        break;
      case _CornerType.tr:
        canvas.drawLine(
          Offset(size.width, 0),
          Offset(size.width - _len, 0),
          paint,
        );
        canvas.drawLine(Offset(size.width, 0), Offset(size.width, _len), paint);
        break;
      case _CornerType.bl:
        canvas.drawLine(
          Offset(0, size.height),
          Offset(_len, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(0, size.height),
          Offset(0, size.height - _len),
          paint,
        );
        break;
      case _CornerType.br:
        canvas.drawLine(
          Offset(size.width, size.height),
          Offset(size.width - _len, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(size.width, size.height),
          Offset(size.width, size.height - _len),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.type != type;
}
