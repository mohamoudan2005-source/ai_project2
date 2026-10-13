import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ai_project/app/models/prediction_result.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/services/pdf_service.dart';
import 'package:ai_project/utils/app_theme.dart';

/// Detailed view of an examination case opened from History.
/// Displays patient details, AI prediction, Firebase Storage X-ray,
/// and provides the "Generate PDF Report" -> "Download PDF" flow.
class ExaminationDetailScreen extends ConsumerStatefulWidget {
  final PredictionHistoryItem item;
  final int index;

  const ExaminationDetailScreen({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  ConsumerState<ExaminationDetailScreen> createState() =>
      _ExaminationDetailScreenState();
}

class _ExaminationDetailScreenState
    extends ConsumerState<ExaminationDetailScreen> {
  bool _isGeneratingPdf = false;
  Uint8List? _generatedPdfBytes;
  String? _pdfErrorMessage;

  Future<void> _handleGeneratePdf() async {
    setState(() {
      _isGeneratingPdf = true;
      _pdfErrorMessage = null;
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final pdfService = ref.read(pdfServiceProvider);

      // 1. Retrieve authenticated doctor's profile (strictly extracting fullName, gender, phone)
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

      // 2. Read local image bytes if available as fallback
      Uint8List? fallbackBytes;
      if (widget.item.photoPath.isNotEmpty) {
        final localFile = File(widget.item.photoPath);
        if (await localFile.exists()) {
          fallbackBytes = await localFile.readAsBytes();
        }
      }

      // 3. Generate medical PDF report
      final bytes = await pdfService.generateMedicalReport(
        caseItem: widget.item,
        doctor: doctorInfo,
        fallbackImageBytes: fallbackBytes,
      );

      if (mounted) {
        setState(() {
          _generatedPdfBytes = bytes;
          _isGeneratingPdf = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.card,
            content: Text(
              'PDF Report generated successfully! Tap "Download PDF" to save or share.',
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
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
          _pdfErrorMessage =
              'Failed to generate PDF report. Please verify connection and try again.';
        });
      }
    }
  }

  Future<void> _handleDownloadPdf() async {
    if (_generatedPdfBytes == null) return;
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final examId = widget.item.id ?? 'exam_${widget.index + 1}';
      final filename = 'examination_report_$examId.pdf';

      await pdfService.downloadPdf(
        pdfBytes: _generatedPdfBytes!,
        filename: filename,
      );
    } catch (e) {
      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isPneumonia = item.isPneumonia;
    final probabilityPct = (item.probability * 100).toStringAsFixed(2);
    final dateFormat = DateFormat('MMMM dd, yyyy - hh:mm a');
    final formattedDate = dateFormat.format(item.completedAt);
    final resultColor = isPneumonia ? AppColors.orange : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textMain,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Examination #${widget.index + 1}',
          style: GoogleFonts.syne(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── X-RAY PREVIEW ─────────────────────────────────────────────
              Container(
                width: double.infinity,
                height: 240.h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildXrayImage(item),
              ),

              SizedBox(height: 20.h),

              // ── AI RESULT BANNER ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: resultColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12.w,
                      runSpacing: 8.h,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: resultColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'AI RESULT: ${item.label.toUpperCase()}',
                            style: GoogleFonts.syne(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: resultColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          'Probability: $probabilityPct%',
                          style: GoogleFonts.nunito(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      isPneumonia
                          ? 'Consistent with signs of pneumonia. Clinical correlation advised.'
                          : 'No signs of pneumonia detected on this chest radiograph.',
                      style: GoogleFonts.nunito(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSub,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12.sp,
                          color: AppColors.textDead,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          formattedDate,
                          style: GoogleFonts.nunito(
                            fontSize: 11.sp,
                            color: AppColors.textDead,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // ── PATIENT INFORMATION CARD ──────────────────────────────────
              Text(
                'PATIENT INFORMATION',
                style: GoogleFonts.syne(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDead,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 8.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Full Name',
                      value: item.patientName?.isNotEmpty == true
                          ? item.patientName!
                          : 'Not Recorded',
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.06),
                      height: 16.h,
                    ),
                    _buildDetailRow(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: item.patientAge != null
                          ? '${item.patientAge} years'
                          : 'Not Recorded',
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.06),
                      height: 16.h,
                    ),
                    _buildDetailRow(
                      icon: Icons.wc_outlined,
                      label: 'Gender',
                      value: item.patientGender?.isNotEmpty == true
                          ? item.patientGender!
                          : 'Not Recorded',
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.06),
                      height: 16.h,
                    ),
                    _buildDetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: item.patientPhone?.isNotEmpty == true
                          ? item.patientPhone!
                          : 'Not Recorded',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ── Error Message ─────────────────────────────────────────────
              if (_pdfErrorMessage != null) ...[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 14.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF281110),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _pdfErrorMessage!,
                    style: GoogleFonts.nunito(
                      fontSize: 12.sp,
                      color: const Color(0xFFFF8A80),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // ── BUTTON 1: GENERATE PDF REPORT ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingPdf ? null : _handleGeneratePdf,
                  icon: _isGeneratingPdf
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.dark,
                            ),
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded, size: 20),
                  label: Text(
                    _isGeneratingPdf
                        ? 'Generating Report...'
                        : (_generatedPdfBytes != null
                              ? 'Regenerate PDF Report'
                              : 'Generate PDF Report'),
                    style: GoogleFonts.syne(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _generatedPdfBytes != null
                        ? AppColors.cardAlt
                        : AppColors.primary,
                    foregroundColor: _generatedPdfBytes != null
                        ? AppColors.primary
                        : AppColors.dark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: _generatedPdfBytes != null
                          ? BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            )
                          : BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ── BUTTON 2: DOWNLOAD PDF (VISIBLE / ACTIVE AFTER GENERATION) ──
              if (_generatedPdfBytes != null) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: _handleDownloadPdf,
                    icon: const Icon(Icons.download_rounded, size: 20),
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

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXrayImage(PredictionHistoryItem item) {
    if (item.photoURL != null && item.photoURL!.isNotEmpty) {
      return Image.network(
        item.photoURL!,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildLocalFallback(item),
      );
    }
    return _buildLocalFallback(item);
  }

  Widget _buildLocalFallback(PredictionHistoryItem item) {
    if (item.photoPath.isNotEmpty) {
      final file = File(item.photoPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      }
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: AppColors.textSub,
            size: 36.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'X-Ray Image Preview Unavailable',
            style: GoogleFonts.nunito(
              fontSize: 13.sp,
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.textSub),
            SizedBox(width: 10.w),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }
}
