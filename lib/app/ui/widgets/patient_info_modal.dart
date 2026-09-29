import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_project/utils/app_theme.dart';

class PatientInfo {
  final String fullName;
  final int age;
  final String gender;
  final String phone;

  const PatientInfo({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.phone,
  });
}

/// Modal bottom sheet allowing doctors to enter and validate patient details
/// before an AI examination result is saved to Firebase.
class PatientInfoModal extends StatefulWidget {
  final PatientInfo? initialData;
  const PatientInfoModal({super.key, this.initialData});

  static Future<PatientInfo?> show(
    BuildContext context, {
    PatientInfo? initialData,
  }) {
    return showModalBottomSheet<PatientInfo>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PatientInfoModal(initialData: initialData),
    );
  }

  @override
  State<PatientInfoModal> createState() => _PatientInfoModalState();
}

class _PatientInfoModalState extends State<PatientInfoModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialData?.fullName ?? '',
    );
    _ageController = TextEditingController(
      text: widget.initialData != null ? '${widget.initialData!.age}' : '',
    );
    _phoneController = TextEditingController(
      text: widget.initialData?.phone ?? '',
    );
    _selectedGender = widget.initialData?.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final patient = PatientInfo(
      fullName: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _selectedGender,
      phone: _phoneController.text.trim(),
    );

    Navigator.of(context).pop(patient);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title and Subtitle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Information',
                        style: GoogleFonts.syne(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Required for medical examination & PDF report',
                        style: GoogleFonts.nunito(
                          fontSize: 13.sp,
                          color: AppColors.textSub,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              _buildFieldLabel('Patient Full Name *'),
              _buildTextField(
                controller: _nameController,
                hintText: 'e.g. Jane Doe',
                icon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Patient full name is required';
                  }
                  if (val.trim().length < 2) {
                    return 'Please enter a valid patient name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 14.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Age *'),
                        _buildTextField(
                          controller: _ageController,
                          hintText: 'e.g. 42',
                          icon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Required';
                            }
                            final parsed = int.tryParse(val.trim());
                            if (parsed == null || parsed < 0 || parsed > 125) {
                              return 'Invalid age';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Gender *'),
                        Container(
                          height: 52.h,
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: ['Male', 'Female', 'Other'].map((gender) {
                              final isSelected = _selectedGender == gender;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedGender = gender),
                                  child: Container(
                                    height: 40.h,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      gender,
                                      style: GoogleFonts.syne(
                                        fontSize: 12.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.dark
                                            : AppColors.textSub,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              _buildFieldLabel('Patient Phone Number *'),
              _buildTextField(
                controller: _phoneController,
                hintText: 'e.g. +1 555 123 4567',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Patient phone number is required';
                  }
                  if (val.trim().length < 6) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.dark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Confirm Patient & Proceed',
                    style: GoogleFonts.syne(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 6.h),
      child: Text(
        label,
        style: GoogleFonts.syne(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSub,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.nunito(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.nunito(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textHint,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSub, size: 18.sp),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: const Color(0xFFFF5252).withValues(alpha: 0.8),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
        ),
        errorStyle: GoogleFonts.nunito(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF8A80),
        ),
      ),
      validator: validator,
    );
  }
}
