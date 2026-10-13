import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_project/app/providers/cameras_provider.dart';
import 'package:ai_project/app/ui/screens/cam_grid.dart';
import 'package:ai_project/app/ui/widgets/camera/bottom_bar.dart';
import 'package:ai_project/app/ui/widgets/camera/cam_beam.dart';
import 'package:ai_project/app/ui/widgets/camera/cam_corners.dart';
import 'package:ai_project/app/ui/widgets/camera/camera_placeholder.dart';
import 'package:ai_project/app/ui/widgets/streak_pill.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

class LiveCamera extends HookConsumerWidget {
  final List<CameraDescription> cameras;
  final AnimationController beamCtrl;
  final double floatAnim;
  final int streak;
  final ValueNotifier<bool> isSnapping;
  final VoidCallback onGallery;
  final void Function(File) onSnap;

  const LiveCamera({
    super.key,
    required this.cameras,
    required this.beamCtrl,
    required this.floatAnim,
    required this.streak,
    required this.isSnapping,
    required this.onGallery,
    required this.onSnap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useState<CameraController?>(null);
    final isReady = useState(false);

    useEffect(() {
      final cam = cameras.first;
      final ctrl = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      controller.value = ctrl;

      ctrl
          .initialize()
          .then((_) {
            isReady.value = true;
          })
          .catchError((_) {
            isReady.value = false;
          });

      return () {
        ctrl.dispose();
      };
    }, []);

    Future<void> takePhoto() async {
      if (isSnapping.value) return;
      final ctrl = controller.value;
      if (ctrl == null || !ctrl.value.isInitialized) return;

      isSnapping.value = true;
      try {
        final xFile = await ctrl.takePicture();
        onSnap(File(xFile.path));
      } catch (_) {
        isSnapping.value = false;
      }
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          // ── Camera preview ──────────────────────────────────────────────────────
          if (isReady.value && controller.value != null)
            Positioned.fill(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 1,
                      height: controller.value!.value.aspectRatio,
                      child: CameraPreview(controller.value!),
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned.fill(child: CameraPlaceholder(onGallery: onGallery)),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Grid overlay ───────────────────────────────────────────────────────
          const Positioned.fill(child: CamGrid()),

          // ── Scan beam ──────────────────────────────────────────────────────────
          Positioned.fill(child: CamBeam(ctrl: beamCtrl)),

          // ── Corner brackets ─────────────────────────────────────────────────────
          const Positioned.fill(child: CamCorners()),

          // ── Sorty floating in center ─────────────────────────────────────────
          Center(
            child: Transform.translate(
              offset: Offset(0, floatAnim),
              child: SortyWidget(
                mood: SortyMood.happy,
                size: AppSizes.sortyCam,
              ),
            ),
          ),

          // ── Top bar ─────────────────────────────────────────────────────────────
          Positioned(
            bottom: 60.h,
            child: BottomBar(pickImage: onGallery, takePhoto: takePhoto),
          ),
        ],
      ),
    );
  }
}
