import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/ui/widgets/camera/gallery_button.dart';
import 'package:ai_project/app/ui/widgets/camera/snap_button.dart';
import 'package:ai_project/utils/app_theme.dart';

class BottomBar extends HookConsumerWidget {
  BottomBar({super.key, required this.pickImage, required this.takePhoto});
  final Function() pickImage, takePhoto;
  final List<String> _hints = [
    "Capture a chest X-ray 🩻",
    "Let's check the X-ray 👀",
    "Ready for an X-ray?",
    "Capture it. I'll analyze it.",
    "Let's detect pneumonia. ⚡",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintIndex = useState(0);

    // ── Hint rotation ─────────────────────────────────────────────────────────
    useEffect(() {
      final timer = Stream.periodic(const Duration(seconds: 3));
      final sub = timer.listen((_) {
        hintIndex.value = (hintIndex.value + 1) % _hints.length;
      });
      return sub.cancel;
    }, []);

    return Column(
      children: [
        Text('LUNG LENS', style: AppTextStyles.appName),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _hints[hintIndex.value],
            key: ValueKey(hintIndex.value),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSub),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 30.h),

        Row(
          children: [
            Opacity(opacity: 0.0, child: GalleryButton(onTap: () {})),
            SizedBox(width: 30.w),
            SnapButton(onTap: takePhoto),
            SizedBox(width: 30.w),
            GalleryButton(onTap: pickImage),
          ],
        ),
        SizedBox(height: 20.h),
        Text('TAP TO CAPTURE X-RAY 🩻', style: AppTextStyles.hint),
      ],
    );
  }
}
