import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/models/prediction_result.dart';

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

/// Doctor profile information strictly filtered for the medical PDF report.
/// Excludes private/internal fields like UID, email, photoURL, provider, streaks.
class DoctorReportInfo {
  final String fullName;
  final String gender;
  final String phone;

  const DoctorReportInfo({
    required this.fullName,
    required this.gender,
    required this.phone,
  });

  factory DoctorReportInfo.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return const DoctorReportInfo(
        fullName: 'Medical Officer',
        gender: 'Not Specified',
        phone: 'Not Specified',
      );
    }
    return DoctorReportInfo(
      fullName: (data['fullName'] as String?)?.isNotEmpty == true
          ? data['fullName'] as String
          : ((data['displayName'] as String?)?.isNotEmpty == true
                ? data['displayName'] as String
                : 'Medical Officer'),
      gender: (data['gender'] as String?)?.isNotEmpty == true
          ? data['gender'] as String
          : 'Not Specified',
      phone: (data['phone'] as String?)?.isNotEmpty == true
          ? data['phone'] as String
          : 'Not Specified',
    );
  }
}

/// Service dedicated to generating standardized AI Pneumonia Detection
/// examination reports and enabling seamless downloads on Android and Web.
class PdfService {
  /// Generates a professional single-page medical PDF document in bytes.
  Future<Uint8List> generateMedicalReport({
    required PredictionHistoryItem caseItem,
    required DoctorReportInfo doctor,
    Uint8List? fallbackImageBytes,
  }) async {
    final pdf = pw.Document(
      title: 'AI Pneumonia Detection Report - ${caseItem.id ?? 'Examination'}',
      author: 'Lung Lens AI Diagnostics',
    );

    Uint8List? imageBytes;

    if (caseItem.photoURL != null && caseItem.photoURL!.isNotEmpty) {
      try {
        final response = await http
            .get(Uri.parse(caseItem.photoURL!))
            .timeout(const Duration(seconds: 12));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      } catch (_) {
        // Fallback handled below
      }
    }
    imageBytes ??= fallbackImageBytes;

    final dateFormat = DateFormat('MMMM dd, yyyy - hh:mm a');
    final formattedDate = dateFormat.format(caseItem.completedAt);
    final examId = caseItem.id?.isNotEmpty == true
        ? caseItem.id!
        : 'EXAM-${caseItem.completedAt.millisecondsSinceEpoch}';
    final probabilityPct = (caseItem.probability * 100).toStringAsFixed(2);
    final isPneumonia = caseItem.isPneumonia;

    final primaryColor = PdfColor.fromHex('1A365D');
    final accentColor = isPneumonia
        ? PdfColor.fromHex('C53030')
        : PdfColor.fromHex('2F855A');
    final darkText = PdfColor.fromHex('1A202C');
    final mutedText = PdfColor.fromHex('4A5568');
    final lightBg = PdfColor.fromHex('F7FAFC');
    final borderColor = PdfColor.fromHex('E2E8F0');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'AI PNEUMONIA DETECTION EXAMINATION REPORT',
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: lightBg,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: borderColor),
                      ),
                      child: pw.Text(
                        'LUNG LENS MEDICAL AI',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Examination ID: ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                              color: darkText,
                            ),
                          ),
                          pw.TextSpan(
                            text: examId,
                            style: pw.TextStyle(fontSize: 10, color: mutedText),
                          ),
                        ],
                      ),
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Date: ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                              color: darkText,
                            ),
                          ),
                          pw.TextSpan(
                            text: formattedDate,
                            style: pw.TextStyle(fontSize: 10, color: mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildInfoCard(
                      title: 'Doctor Information',
                      fields: [
                        {'label': 'Full Name', 'value': doctor.fullName},
                        {'label': 'Gender', 'value': doctor.gender},
                        {'label': 'Phone', 'value': doctor.phone},
                      ],
                      primaryColor: primaryColor,
                      borderColor: borderColor,
                      lightBg: lightBg,
                      darkText: darkText,
                      mutedText: mutedText,
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: _buildInfoCard(
                      title: 'Patient Information',
                      fields: [
                        {
                          'label': 'Full Name',
                          'value': caseItem.patientName?.isNotEmpty == true
                              ? caseItem.patientName!
                              : 'Not Specified',
                        },
                        {
                          'label': 'Age',
                          'value': caseItem.patientAge != null
                              ? '${caseItem.patientAge} years'
                              : 'Not Specified',
                        },
                        {
                          'label': 'Gender',
                          'value': caseItem.patientGender?.isNotEmpty == true
                              ? caseItem.patientGender!
                              : 'Not Specified',
                        },
                        {
                          'label': 'Phone',
                          'value': caseItem.patientPhone?.isNotEmpty == true
                              ? caseItem.patientPhone!
                              : 'Not Specified',
                        },
                      ],
                      primaryColor: primaryColor,
                      borderColor: borderColor,
                      lightBg: lightBg,
                      darkText: darkText,
                      mutedText: mutedText,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: isPneumonia
                      ? PdfColor.fromHex('FFF5F5')
                      : PdfColor.fromHex('F0FFF4'),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: accentColor, width: 1.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'AI ANALYSIS',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: mutedText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          caseItem.label.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'PNEUMONIA PROBABILITY',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: mutedText,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          '$probabilityPct%',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              pw.Expanded(
                child: pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.black,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: borderColor),
                  ),
                  child: imageBytes != null
                      ? pw.Center(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Image(
                              pw.MemoryImage(imageBytes),
                              fit: pw.BoxFit.contain,
                            ),
                          ),
                        )
                      : pw.Center(
                          child: pw.Text(
                            'X-Ray Image Not Available for Preview',
                            style: const pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                ),
              ),

              pw.SizedBox(height: 12),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NOTICE: ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8.5,
                        color: darkText,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'This report contains an AI-assisted result and is intended to support '
                        'medical assessment. It does not replace professional medical diagnosis.',
                        style: pw.TextStyle(fontSize: 8.5, color: mutedText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildInfoCard({
    required String title,
    required List<Map<String, String>> fields,
    required PdfColor primaryColor,
    required PdfColor borderColor,
    required PdfColor lightBg,
    required PdfColor darkText,
    required PdfColor mutedText,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.6,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Divider(color: borderColor, height: 1, thickness: 1),
          pw.SizedBox(height: 6),
          ...fields.map(
            (field) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    field['label']!,
                    style: pw.TextStyle(fontSize: 9.5, color: mutedText),
                  ),
                  pw.Text(
                    field['value']!,
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> downloadPdf({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  Future<void> previewPdf({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: filename,
    );
  }
}
