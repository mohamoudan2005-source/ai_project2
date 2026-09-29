import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_project/app/ui/screens/is_not_xray_screen.dart';
import 'package:ai_project/app/ui/widgets/patient_info_modal.dart';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/services/pdf_service.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/application/app_event.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

import '../widgets/streak_pill.dart';

class CompleteScreen extends HookConsumerWidget {
  const CompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final appController = ref.read(appProvider.notifier);

    // Prediction result coming from the AI model
    final result = appState.result;
    final isPneumonia = result?.isPneumonia ?? false;
    final label = result?.label ?? 'Unknown';
    final probability = result?.probability ?? 0.0;
    final probabilityPct = (probability * 100).toStringAsFixed(2);

    // PDF generation states
    final isGeneratingPdf = useState(false);
    final generatedPdfBytes = useState<Uint8List?>(null);
    final pdfError = useState<String?>(null);

    // Only celebrate with confetti when the result is Normal
    final confettiCtrl = useMemoized(
      () => ConfettiController(duration: const Duration(seconds: 4)),
    );
    useEffect(() {
      if (!isPneumonia) {
        confettiCtrl.play();
      }
      return confettiCtrl.dispose;
    }, [isPneumonia]);

    // Sorty pop animation
    final popCtrl = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );
    useEffect(() {
      popCtrl.forward();
      return null;
    }, []);
    final popAnim = useAnimation(
      CurvedAnimation(parent: popCtrl, curve: Curves.elasticOut),
    );

    final resultColor = isPneumonia ? AppColors.orange : AppColors.primary;

    // ── Generate PDF Report Handler ─────────────────────────────────────────
    Future<void> handleGeneratePdf() async {
      // If patient details are missing, prompt doctor before generating report
      if (!appState.hasPatientInfo) {
        final patient = await PatientInfoModal.show(context);
        if (patient == null) return;
        await appController.updateCurrentCasePatientInfo(
          fullName: patient.fullName,
          age: patient.age,
          gender: patient.gender,
          phone: patient.phone,
        );
      }

      isGeneratingPdf.value = true;
      pdfError.value = null;

      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        final pdfService = ref.read(pdfServiceProvider);

        // Retrieve authenticated doctor's profile (strictly extracting fullName, gender, phone)
        final userProfile = await firestoreService.getUserProfile();
        final doctorInfo = DoctorReportInfo(
          fullName: userProfile?.fullName?.isNotEmpty == true
              ? userProfile!.fullName!
              : (userProfile?.displayName.isNotEmpty == true
                    ? userProfile!.displayName
                    : 'Medical Officer'),
          gender: userProfile?.gender?.isNotEmpty == true
              ? userProfile!.gender!
              : 'Not Specified',
          phone: userProfile?.phone?.isNotEmpty == true
              ? userProfile!.phone!
              : 'Not Specified',
        );

        // Raw image bytes from memory as reliable fallback
        Uint8List? fallbackBytes;
        if (appState.photoBase64 != null) {
          fallbackBytes = base64Decode(appState.photoBase64!);
        }

        final currentCase =
            appState.currentCase ??
            PredictionHistoryItem(
              id: appState.currentCaseId,
              patientName: appState.patientName,
              patientAge: appState.patientAge,
              patientGender: appState.patientGender,
              patientPhone: appState.patientPhone,
              photoPath: appState.photoPath ?? '',
              photoURL: appState.currentPhotoURL,
              completedAt: DateTime.now(),
              label: label,
              probability: probability,
              isPneumonia: isPneumonia,
            );

        final bytes = await pdfService.generateMedicalReport(
          caseItem: currentCase,
          doctor: doctorInfo,
          fallbackImageBytes: fallbackBytes,
        );

        generatedPdfBytes.value = bytes;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.card,
              content: Text(
                'PDF Report generated! Tap "Download PDF" to save.',
                style: GoogleFonts.nunito(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        pdfError.value =
            'Failed to generate medical PDF report. Please try again.';
      } finally {
        isGeneratingPdf.value = false;
      }
    }

    // ── Download PDF Handler ────────────────────────────────────────────────
    Future<void> handleDownloadPdf() async {
      if (generatedPdfBytes.value == null) return;
      try {
        final pdfService = ref.read(pdfServiceProvider);
        final examId = appState.currentCaseId ?? 'examination';
        await pdfService.downloadPdf(
          pdfBytes: generatedPdfBytes.value!,
          filename: 'examination_report_$examId.pdf',
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF281110),
              content: Text(
                'Download failed: $e',
                style: GoogleFonts.nunito(color: const Color(0xFFFF8A80)),
              ),
            ),
          );
        }
      }
    }

    return !appState.isXray
        ? IsNotXrayScreen(appController: appController, popAnim: popAnim)
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              appController.mapEventToState(AppEvent.goToCamera());
            },
            child: Scaffold(
              backgroundColor: AppColors.dark,
              body: Stack(
                children: [
                  // Confetti (fires for Normal results)
                  if (!isPneumonia)
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: confettiCtrl,
                        blastDirectionality: BlastDirectionality.explosive,
                        colors: const [
                          AppColors.primary,
                          AppColors.orange,
                          Colors.white,
                        ],
                        numberOfParticles: 40,
                        maxBlastForce: 30,
                        minBlastForce: 10,
                      ),
                    ),

                  // Content
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10.h),

                          // Sorty reacting to the result
                          Transform.scale(
                            scale: popAnim,
                            child: SortyWidget(
                              mood: isPneumonia
                                  ? SortyMood.concerned
                                  : SortyMood.celebrating,
                              size: AppSizes.sortyComplete,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Result label
                          Text(
                            label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.displayLarge.copyWith(
                              color: resultColor,
                              height: 1.0,
                              fontSize: isPneumonia ? 32.sp : 42.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Probability percentage
                          Text(
                            'Probability: $probabilityPct%',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge,
                          ),
                          SizedBox(height: 6.h),

                          Text(
                            isPneumonia
                                ? 'The scan shows signs consistent with pneumonia. Please consult a doctor for a proper diagnosis.'
                                : 'No signs of pneumonia were detected in this scan.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall,
                          ),
                          SizedBox(height: 18.h),

                          // Streak
                          StreakPill(streak: appState.streak, large: true),
                          SizedBox(height: 20.h),

                          // ── Patient Info Banner ───────────────────────────
                          GestureDetector(
                            onTap: () async {
                              final updated = await PatientInfoModal.show(
                                context,
                                initialData: appState.hasPatientInfo
                                    ? PatientInfo(
                                        fullName: appState.patientName!,
                                        age: appState.patientAge!,
                                        gender:
                                            appState.patientGender ?? 'Male',
                                        phone: appState.patientPhone!,
                                      )
                                    : null,
                              );
                              if (updated != null) {
                                await appController
                                    .updateCurrentCasePatientInfo(
                                      fullName: updated.fullName,
                                      age: updated.age,
                                      gender: updated.gender,
                                      phone: updated.phone,
                                    );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_pin_rounded,
                                    color: AppColors.primary,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appState.hasPatientInfo
                                              ? 'Patient: ${appState.patientName!}'
                                              : 'Patient: Not Specified',
                                          style: GoogleFonts.nunito(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMain,
                                          ),
                                        ),
                                        if (appState.hasPatientInfo) ...[
                                          Text(
                                            '${appState.patientAge} yrs • ${appState.patientGender} • ${appState.patientPhone}',
                                            style: GoogleFonts.nunito(
                                              fontSize: 11.sp,
                                              color: AppColors.textSub,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.textSub,
                                    size: 14.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // ── PDF Error Message ─────────────────────────────
                          if (pdfError.value != null) ...[
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF281110),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFF5252,
                                  ).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                pdfError.value!,
                                style: GoogleFonts.nunito(
                                  fontSize: 12.sp,
                                  color: const Color(0xFFFF8A80),
                                ),
                              ),
                            ),
                          ],

                          // ── BUTTON: GENERATE PDF REPORT ───────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton.icon(
                              onPressed: isGeneratingPdf.value
                                  ? null
                                  : handleGeneratePdf,
                              icon: isGeneratingPdf.value
                                  ? SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.dark,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.picture_as_pdf_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                isGeneratingPdf.value
                                    ? 'Generating PDF Report...'
                                    : (generatedPdfBytes.value != null
                                          ? 'Regenerate PDF Report'
                                          : 'Generate PDF Report'),
                                style: GoogleFonts.syne(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: generatedPdfBytes.value != null
                                    ? AppColors.cardAlt
                                    : AppColors.primary,
                                foregroundColor: generatedPdfBytes.value != null
                                    ? AppColors.primary
                                    : AppColors.dark,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  side: generatedPdfBytes.value != null
                                      ? BorderSide(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                        )
                                      : BorderSide.none,
                                ),
                              ),
                            ),
                          ),

                          // ── BUTTON: DOWNLOAD PDF ──────────────────────────
                          if (generatedPdfBytes.value != null) ...[
                            SizedBox(height: 10.h),
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton.icon(
                                onPressed: handleDownloadPdf,
                                icon: const Icon(
                                  Icons.download_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  'Download PDF',
                                  style: GoogleFonts.syne(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.dark,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 16.h),

                          // New scan button
                          GestureDetector(
                            onTap: () {
                              appController.clearPatientInfo();
                              appController.mapEventToState(
                                const AppEvent.goToCamera(),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: AppDecorations.buttonPrimary,
                              child: Text(
                                'Scan Another X-Ray',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.buttonText,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // History button
                          GestureDetector(
                            onTap: () => appController.mapEventToState(
                              const AppEvent.goToHistory(),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: AppDecorations.buttonGhost,
                              child: Text(
                                'See All Scans',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.buttonTextLight.copyWith(
                                  color: AppColors.textSub,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
