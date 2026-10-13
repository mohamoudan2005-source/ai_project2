import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ai_project/utils/app_theme.dart';

class SnapButton extends HookWidget {
  final VoidCallback onTap;
  const SnapButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scaleCtrl = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    useEffect(() {
      scaleCtrl.repeat(reverse: true);
      return null;
    }, []);
    final scaleAnim = useAnimation(
      Tween<double>(
        begin: 1.0,
        end: 0.94,
      ).animate(CurvedAnimation(parent: scaleCtrl, curve: Curves.easeInOut)),
    );

    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: scaleAnim,
        child: Container(
          width: AppSizes.snapBtnOuter,
          height: AppSizes.snapBtnOuter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: Center(
            child: Container(
              width: AppSizes.snapBtnInner,
              height: AppSizes.snapBtnInner,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
