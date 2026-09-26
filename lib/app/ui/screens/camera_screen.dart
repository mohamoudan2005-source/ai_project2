import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/providers/cameras_provider.dart';
import 'package:ai_project/app/ui/screens/cam_grid.dart';
import 'package:ai_project/app/ui/widgets/camera/bottom_bar.dart';
import 'package:ai_project/app/ui/widgets/camera/cam_beam.dart';
import 'package:ai_project/app/ui/widgets/camera/cam_corners.dart';
import 'package:ai_project/app/ui/widgets/camera/camera_placeholder.dart';
import 'package:ai_project/app/ui/widgets/camera/camera_top_bar.dart';
import 'package:ai_project/app/ui/widgets/camera/live_camera.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends HookConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final camerasAsync = ref.watch(camerasProvider);
    final appController = ref.read(appProvider.notifier);
    final appState = ref.watch(appProvider);

    final isSnapping = useState(false);

    // ── Animation controllers ─────────────────────────────────────────────────
    final floatCtrl = useAnimationController(
      duration: const Duration(milliseconds: 3500),
    );
    final beamCtrl = useAnimationController(
      duration: const Duration(seconds: 3),
    );

    // ── Sorty float ───────────────────────────────────────────────────────────
    final floatAnim = useAnimation(
      Tween<double>(
        begin: 0,
        end: -12,
      ).animate(CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut)),
    );

    useEffect(() {
      floatCtrl.repeat(reverse: true);
      beamCtrl.repeat();
      return null;
    }, []);

    Future<void> pickFromGallery() async {
      if (isSnapping.value) return;
      isSnapping.value = true;
      try {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1200,
        );
        if (picked == null) return;
        await appController.mapEventToState(
          AppEvent.setPhoto(File(picked.path)),
        );
      } finally {
        isSnapping.value = false;
      }
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          alignment: AlignmentGeometry.center,
          children: [
            camerasAsync.when(
              loading: () => CameraPlaceholder(onGallery: pickFromGallery),
              error: (_, __) => CameraPlaceholder(onGallery: pickFromGallery),
              data: (cameras) => cameras.isEmpty
                  ? CameraPlaceholder(onGallery: pickFromGallery)
                  : LiveCamera(
                      cameras: cameras,
                      beamCtrl: beamCtrl,
                      floatAnim: floatAnim,
                      streak: appState.streak,
                      isSnapping: isSnapping,
                      onGallery: pickFromGallery,
                      onSnap: (file) async {
                        await appController.mapEventToState(
                          AppEvent.setPhoto(file),
                        );
                      },
                    ),
            ),
            Positioned(top: 70.sp, child: CameraTopBar()),
          ],
        ),
      ),
    );
  }
}
