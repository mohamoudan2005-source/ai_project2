import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/providers/cameras_provider.dart';
import 'package:ai_project/app/ui/widgets/camera/camera_placeholder.dart';
import 'package:ai_project/app/ui/widgets/camera/camera_top_bar.dart';
import 'package:ai_project/app/ui/widgets/camera/live_camera.dart';
import 'package:ai_project/app/ui/widgets/patient_info_modal.dart';
import 'package:ai_project/utils/app_theme.dart';

class CameraScreen extends HookConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // ── Patient Info Workflow ─────────────────────────────────────────────────
    Future<bool> ensurePatientInfo() async {
      if (appState.hasPatientInfo) return true;
      final patient = await PatientInfoModal.show(context);
      if (patient != null) {
        appController.setPatientInfo(
          fullName: patient.fullName,
          age: patient.age,
          gender: patient.gender,
          phone: patient.phone,
        );
        return true;
      }
      return false;
    }

    Future<void> startNewExamination() async {
      final patient = await PatientInfoModal.show(
        context,
        initialData: appState.hasPatientInfo
            ? PatientInfo(
                fullName: appState.patientName!,
                age: appState.patientAge!,
                gender: appState.patientGender ?? 'Male',
                phone: appState.patientPhone!,
              )
            : null,
      );
      if (patient != null) {
        appController.setPatientInfo(
          fullName: patient.fullName,
          age: patient.age,
          gender: patient.gender,
          phone: patient.phone,
        );
      }
    }

    Future<void> pickFromGallery() async {
      if (isSnapping.value) return;
      final ready = await ensurePatientInfo();
      if (!ready) return;

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

    Future<void> handleSnap(File file) async {
      final ready = await ensurePatientInfo();
      if (!ready) return;

      await appController.mapEventToState(AppEvent.setPhoto(file));
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
                      onSnap: handleSnap,
                    ),
            ),

            // Top Bar
            Positioned(top: 70.sp, child: const CameraTopBar()),

            // Patient Information Badge / "New Examination" Trigger
            Positioned(
              top: 124.h,
              child: GestureDetector(
                onTap: startNewExamination,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: appState.hasPatientInfo
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.16),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        appState.hasPatientInfo
                            ? Icons.person_rounded
                            : Icons.person_add_rounded,
                        color: appState.hasPatientInfo
                            ? AppColors.primary
                            : AppColors.primary,
                        size: 14.sp,
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        appState.hasPatientInfo
                            ? 'Patient: ${appState.patientName!} (${appState.patientAge}y, ${appState.patientGender})'
                            : 'New Examination • Enter Patient Details',
                        style: GoogleFonts.nunito(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: appState.hasPatientInfo
                              ? AppColors.textMain
                              : AppColors.textMain,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.edit_outlined,
                        color: AppColors.textSub,
                        size: 13.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
