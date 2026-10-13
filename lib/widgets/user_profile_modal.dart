import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/models/user_profile.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/widgets/circular_profile_image.dart';

/// Modal bottom sheet displaying authenticated doctor profile details,
/// editable report metadata (fullName, gender, phone), UID, and sign out control.
class UserProfileModal extends ConsumerStatefulWidget {
  const UserProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const UserProfileModal(),
    );
  }

  @override
  ConsumerState<UserProfileModal> createState() => _UserProfileModalState();
}

class _UserProfileModalState extends ConsumerState<UserProfileModal> {
  static const _secondaryTextColor = Color(0xFFCCCCCC);

  bool _isLoggingOut = false;
  bool _isSavingProfile = false;
  bool _isSendingPasswordReset = false;
  bool _isLoadingProfile = true;
  String? _copiedUid;
  String? _profileLoadError;
  UserProfile? _profile;
  bool _isUploadingProfileImage = false;
  String? _customProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoadingProfile = true;
        _profileLoadError = null;
      });
    }
    try {
      final profile = await ref.read(firestoreServiceProvider).getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _profileLoadError = 'Could not load your profile: $error';
        });
      }
    }
  }

  Future<void> _chooseProfileImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                'Take a photo',
                style: GoogleFonts.nunito(color: Colors.white),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                'Choose from gallery',
                style: GoogleFonts.nunito(color: Colors.white),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null && mounted) await _pickProfileImage(source);
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    if (_isUploadingProfileImage) return;
    setState(() => _isUploadingProfileImage = true);

    try {
      debugPrint('PROFILE IMAGE: picker started');
      final pickedImage = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedImage == null) {
        debugPrint('PROFILE IMAGE: picker cancelled by user');
        if (mounted) setState(() => _isUploadingProfileImage = false);
        return;
      }
      debugPrint('PROFILE IMAGE: image selected (${pickedImage.path})');

      final user = FirebaseAuth.instance.currentUser;
      debugPrint(
        'PROFILE IMAGE: auth state check - user exists: ${user != null}, uid: ${user?.uid}',
      );
      if (user == null) {
        throw StateError(
          'No authenticated user found for Firebase Storage operation.',
        );
      }

      debugPrint('PROFILE IMAGE: reading image bytes');
      final imageBytes = await pickedImage.readAsBytes();
      debugPrint(
        'PROFILE IMAGE: raw bytes read (${imageBytes.lengthInBytes} bytes)',
      );

      // 1. Upload the resized profile image to Cloudinary.
      final photoURL = await ref
          .read(firebaseStorageProvider)
          .uploadProfileImage(imageBytes: imageBytes);

      // 2. Persist the Cloudinary URL to users/{uid}.profileImage.
      debugPrint('PROFILE IMAGE: Firestore update started');
      await ref.read(firestoreServiceProvider).updateProfilePhotoUrl(photoURL);
      debugPrint('PROFILE IMAGE: Firestore update completed');

      // 3. Immediately update local state so current Profile widget rebuilds instantly
      if (mounted) {
        setState(() {
          _customProfileImageUrl = photoURL;
          if (_profile != null) {
            _profile = _profile!.copyWith(profileImage: photoURL);
          }
        });
      }
    } on PlatformException catch (error, stackTrace) {
      debugPrint('PROFILE IMAGE PLATFORM ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      final permissionDenied = error.code.toLowerCase().contains('denied');
      _showProfileImageError(
        permissionDenied
            ? 'Allow camera or photo access in Settings to choose a profile photo.'
            : 'Could not select the profile photo. Please try again.',
      );
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('PROFILE IMAGE ERROR: $e');
      debugPrint('PROFILE IMAGE ERROR CODE: ${e.code}');
      debugPrint('PROFILE IMAGE ERROR MESSAGE: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      _showProfileImageError(
        'Could not update the profile photo (${e.code}): ${e.message ?? "Check your connection and try again."}',
      );
    } catch (error, stackTrace) {
      debugPrint('PROFILE IMAGE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showProfileImageError(error.toString());
    } finally {
      if (mounted) setState(() => _isUploadingProfileImage = false);
    }
  }

  void _showProfileImageError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.nunito()),
        backgroundColor: AppColors.orange,
      ),
    );
  }

  Widget _buildProfileImage(
    String displayName,
    String? customPhotoUrl,
    String? providerPhotoUrl,
  ) {
    if (customPhotoUrl != null && customPhotoUrl.isNotEmpty) {
      return CircularProfileImage(
        imageUrl: customPhotoUrl,
        fallback: _buildProviderOrInitialAvatar(
          displayName,
          providerPhotoUrl,
          customPhotoUrl,
        ),
        loading: Center(
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
    return _buildProviderOrInitialAvatar(
      displayName,
      providerPhotoUrl,
      customPhotoUrl,
    );
  }

  Widget _buildProviderOrInitialAvatar(
    String displayName,
    String? providerPhotoUrl,
    String? customPhotoUrl,
  ) {
    if (providerPhotoUrl != null &&
        providerPhotoUrl.isNotEmpty &&
        providerPhotoUrl != customPhotoUrl) {
      return CircularProfileImage(
        imageUrl: providerPhotoUrl,
        fallback: _buildInitialAvatar(displayName),
      );
    }
    return _buildInitialAvatar(displayName);
  }

  Future<void> _openEditDoctorDialog() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      _showProfileImageError('Sign in to edit your profile.');
      return;
    }

    final profileDisplayName = _profile?.displayName.trim();
    final emailAlias = user.email?.split('@').first;
    final existingFullName = _profile?.fullName?.trim();
    final controllers = <String, TextEditingController>{
      'fullName': TextEditingController(
        text:
            existingFullName?.isNotEmpty == true &&
                existingFullName != emailAlias
            ? existingFullName!
            : (user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!.trim()
                  : (profileDisplayName?.isNotEmpty == true &&
                            profileDisplayName != emailAlias &&
                            profileDisplayName != 'User'
                        ? profileDisplayName!
                        : '')),
      ),
      'phone': TextEditingController(text: _profile?.phone ?? ''),
      'specialty': TextEditingController(text: _profile?.specialty ?? ''),
      'hospitalClinic': TextEditingController(
        text: _profile?.hospitalClinic ?? '',
      ),
      'city': TextEditingController(text: _profile?.city ?? ''),
      'country': TextEditingController(text: _profile?.country ?? ''),
      'licenseNumber': TextEditingController(
        text: _profile?.licenseNumber ?? '',
      ),
    };
    final formKey = GlobalKey<FormState>();
    String? selectedGender = _profile?.gender;
    String? saveError;
    BuildContext? editDialogContext;

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          editDialogContext = dialogContext;
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final screenWidth = MediaQuery.sizeOf(dialogContext).width;
              return AlertDialog(
                backgroundColor: AppColors.cardAlt,
                insetPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 24.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                title: Text(
                  'Edit Doctor Profile',
                  style: GoogleFonts.nunito(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                content: SizedBox(
                  width: screenWidth > 700 ? 620 : screenWidth * 0.88,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your email is managed by your sign-in account.',
                            style: GoogleFonts.nunito(
                              fontSize: 13.sp,
                              color: _secondaryTextColor,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildProfileFormField(
                            controller: controllers['fullName']!,
                            label: 'Full name',
                            icon: Icons.person_outline_rounded,
                            required: true,
                            validator: (value) =>
                                (value?.trim().isEmpty ?? true)
                                ? 'Enter your full name'
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          _buildProfileFormField(
                            controller: controllers['specialty']!,
                            label: 'Medical specialty',
                            icon: Icons.medical_services_outlined,
                          ),
                          SizedBox(height: 12.h),
                          _buildProfileFormField(
                            controller: controllers['hospitalClinic']!,
                            label: 'Hospital / clinic',
                            icon: Icons.local_hospital_outlined,
                          ),
                          SizedBox(height: 12.h),
                          _buildProfileFormField(
                            controller: controllers['phone']!,
                            label: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              final phone = value?.trim() ?? '';
                              if (phone.isEmpty) return null;
                              if (!RegExp(r'^[+() .\-\d]+$').hasMatch(phone) ||
                                  phone.replaceAll(RegExp(r'\D'), '').length <
                                      7 ||
                                  phone.replaceAll(RegExp(r'\D'), '').length >
                                      15) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProfileFormField(
                                  controller: controllers['city']!,
                                  label: 'City',
                                  icon: Icons.location_city_outlined,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildProfileFormField(
                                  controller: controllers['country']!,
                                  label: 'Country',
                                  icon: Icons.public_outlined,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _buildProfileFormField(
                            controller: controllers['licenseNumber']!,
                            label: 'Medical license number',
                            icon: Icons.badge_outlined,
                          ),
                          SizedBox(height: 12.h),
                          DropdownButtonFormField<String?>(
                            initialValue: selectedGender,
                            dropdownColor: AppColors.card,
                            style: GoogleFonts.nunito(color: Colors.white),
                            decoration: _profileInputDecoration(
                              label: 'Gender (optional)',
                              icon: Icons.wc_outlined,
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: const Text('Not specified'),
                              ),
                              if (selectedGender != null &&
                                  !const [
                                    'Female',
                                    'Male',
                                    'Other',
                                  ].contains(selectedGender))
                                DropdownMenuItem<String?>(
                                  value: selectedGender,
                                  child: Text(selectedGender!),
                                ),
                              const DropdownMenuItem<String?>(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              const DropdownMenuItem<String?>(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              const DropdownMenuItem<String?>(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (value) =>
                                setDialogState(() => selectedGender = value),
                          ),
                          if (saveError != null) ...[
                            SizedBox(height: 12.h),
                            Text(
                              saveError!,
                              style: GoogleFonts.nunito(
                                color: AppColors.orange,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: _isSavingProfile
                        ? null
                        : () => Navigator.of(dialogContext).pop(false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.nunito(color: _secondaryTextColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSavingProfile
                        ? null
                        : () async {
                            if (!mounted || _isSavingProfile) return;
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            setState(() => _isSavingProfile = true);
                            setDialogState(() => saveError = null);
                            var saveSucceeded = false;
                            try {
                              await ref
                                  .read(firestoreServiceProvider)
                                  .updateDoctorProfile(
                                    fullName: controllers['fullName']!.text,
                                    gender: selectedGender,
                                    phone: controllers['phone']!.text,
                                    specialty: controllers['specialty']!.text,
                                    hospitalClinic:
                                        controllers['hospitalClinic']!.text,
                                    city: controllers['city']!.text,
                                    country: controllers['country']!.text,
                                    licenseNumber:
                                        controllers['licenseNumber']!.text,
                                  );
                              await _loadProfile();
                              saveSucceeded = true;
                            } catch (error, stackTrace) {
                              debugPrint('PROFILE SAVE ERROR: $error');
                              debugPrintStack(stackTrace: stackTrace);
                              final message =
                                  error is FirebaseException &&
                                      error.code == 'permission-denied'
                                  ? 'You do not have permission to update this profile.'
                                  : 'Could not save your profile. Please check your connection and try again.';
                              if (dialogContext.mounted) {
                                setDialogState(() => saveError = message);
                              } else if (mounted) {
                                _showProfileImageError(message);
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isSavingProfile = false);
                              }
                              if (dialogContext.mounted) {
                                setDialogState(() => _isSavingProfile = false);
                              }
                            }
                            if (saveSucceeded && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.dark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isSavingProfile
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.dark,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (saved == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: AppColors.card,
          ),
        );
      }
    } finally {
      while (editDialogContext?.mounted ?? false) {
        await WidgetsBinding.instance.endOfFrame;
      }
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  Widget _buildProfileFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.nunito(color: Colors.white, fontSize: 14.sp),
      decoration: _profileInputDecoration(
        label: required ? '$label *' : label,
        icon: icon,
      ),
      validator: validator,
    );
  }

  InputDecoration _profileInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.nunito(color: _secondaryTextColor),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
      filled: true,
      fillColor: AppColors.card,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final streamedProfile = ref.watch(userProfileStreamProvider).value;
    final activeProfile = _profile ?? streamedProfile;
    final profileDisplayName = activeProfile?.displayName.trim();
    final emailAlias = user?.email?.split('@').first;
    final profileFullName = activeProfile?.fullName?.trim();

    final displayName =
        profileFullName?.isNotEmpty == true && profileFullName != emailAlias
        ? profileFullName!
        : (user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!.trim()
              : (profileDisplayName?.isNotEmpty == true &&
                        profileDisplayName != emailAlias &&
                        profileDisplayName != 'User'
                    ? profileDisplayName!
                    : 'Medical Officer'));
    final email = user?.email ?? 'No email associated';

    // Priority:
    // 1. Newly uploaded custom image in current session (_customProfileImageUrl)
    // 2. Saved Firestore custom profile image (activeProfile?.profileImage)
    // 3. Provider photoURL (user?.photoURL)
    // 4. Default avatar
    final photoUrl =
        _customProfileImageUrl ??
        (activeProfile?.profileImage?.isNotEmpty == true
            ? activeProfile!.profileImage
            : null);
    final uid = user?.uid ?? 'Unknown';
    final createdAt = activeProfile?.createdAt ?? user?.metadata.creationTime;
    final memberSince = createdAt == null
        ? 'Unknown'
        : DateFormat('MMM yyyy').format(createdAt);

    // Determine provider name and icon/color
    String providerName = 'Firebase';
    IconData providerIcon = Icons.lock_outline_rounded;
    Color providerColor = AppColors.primary;

    if (user != null && user.providerData.isNotEmpty) {
      final pid = user.providerData.first.providerId;
      if (pid.contains('google')) {
        providerName = 'Google Account';
        providerIcon = Icons.g_mobiledata_rounded;
        providerColor = const Color(0xFF4285F4);
      } else if (pid.contains('facebook')) {
        providerName = 'Facebook Account';
        providerIcon = Icons.facebook_rounded;
        providerColor = const Color(0xFF1877F2);
      }
    }

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 36.h),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag handle
              Container(
                width: 44.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Profile Picture / Initial Avatar
              Stack(
                children: [
                  Container(
                    width: 84.w,
                    height: 84.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildProfileImage(
                      displayName,
                      photoUrl,
                      user?.photoURL,
                    ),
                  ),
                  if (_isUploadingProfileImage)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: providerColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardAlt, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          providerIcon,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: AppColors.primary,
                      shape: CircleBorder(
                        side: BorderSide(color: AppColors.cardAlt, width: 2),
                      ),
                      child: InkWell(
                        onTap: _isUploadingProfileImage
                            ? null
                            : _chooseProfileImage,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 30.w,
                          height: 30.w,
                          child: Center(
                            child: _isUploadingProfileImage
                                ? SizedBox(
                                    width: 15.w,
                                    height: 15.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.dark,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt_rounded,
                                    size: 15.sp,
                                    color: AppColors.dark,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // Doctor Name
              Text(
                displayName,
                style: GoogleFonts.nunito(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              Text(
                'Doctor',
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h),

              // Doctor Email
              Text(
                email,
                style: GoogleFonts.nunito(
                  fontSize: 13.sp,
                  color: _secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 14.h),

              // Google Account indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: providerColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(providerIcon, size: 13.sp, color: providerColor),
                    SizedBox(width: 5.w),
                    Text(
                      providerName,
                      style: GoogleFonts.nunito(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              _buildProfileSection(
                title: 'Personal information',
                icon: Icons.person_outline_rounded,
                trailing: TextButton.icon(
                  onPressed: _openEditDoctorDialog,
                  icon: Icon(Icons.edit_outlined, size: 16.sp),
                  label: Text('Edit profile', style: GoogleFonts.nunito()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                child: Column(
                  children: [
                    if (_isLoadingProfile && activeProfile == null)
                      const Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    else if (_profileLoadError != null && activeProfile == null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _profileLoadError!,
                                style: GoogleFonts.nunito(
                                  color: AppColors.orange,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Retry loading profile',
                              onPressed: _loadProfile,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _buildDoctorDetail('Full name', displayName),
                      _buildDoctorDetail('Email', email, singleLineValue: true),
                      _buildDoctorDetail(
                        'Medical specialty',
                        activeProfile?.specialty,
                      ),
                      _buildDoctorDetail(
                        'Hospital / clinic',
                        activeProfile?.hospitalClinic,
                      ),
                      _buildDoctorDetail('Phone number', activeProfile?.phone),
                      _buildDoctorDetail(
                        'Location',
                        [activeProfile?.city, activeProfile?.country]
                            .whereType<String>()
                            .map((value) => value.trim())
                            .where((value) => value.isNotEmpty)
                            .join(', '),
                      ),
                      _buildDoctorDetail(
                        'Medical license',
                        activeProfile?.licenseNumber,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              _buildProfileSection(
                title: 'Account security',
                icon: Icons.shield_outlined,
                child: Column(
                  children: [
                    _buildDoctorDetail('Sign-in method', providerName),
                    _buildDoctorDetail(
                      'Email verification',
                      user?.emailVerified == true ? 'Verified' : 'Not verified',
                      valueColor: user?.emailVerified == true
                          ? AppColors.primary
                          : _secondaryTextColor,
                    ),
                    if (user?.providerData.any(
                          (provider) => provider.providerId == 'password',
                        ) ==
                        true)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _isSendingPasswordReset
                              ? null
                              : _sendPasswordReset,
                          icon: _isSendingPasswordReset
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(Icons.lock_reset_outlined),
                          label: Text(
                            'Send password reset email',
                            style: GoogleFonts.nunito(),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // UID Card with Tap to Copy
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: uid));
                  setState(() => _copiedUid = uid);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _copiedUid = null);
                  });
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
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        color: _secondaryTextColor,
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACCOUNT',
                              style: GoogleFonts.nunito(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: _secondaryTextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            _buildDoctorDetail('Member since', memberSince),
                            SizedBox(height: 4.h),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 8.w,
                              runSpacing: 2.h,
                              children: [
                                Text(
                                  'Account ID',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12.sp,
                                    color: _secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  uid,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        _copiedUid != null
                            ? Icons.check_circle_rounded
                            : Icons.copy_rounded,
                        size: 16.sp,
                        color: _copiedUid != null
                            ? AppColors.primary
                            : _secondaryTextColor,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 22.h),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isLoggingOut ? null : _handleSignOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF261210),
                    foregroundColor: const Color(0xFFFF5252),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoggingOut
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF5252),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, size: 18),
                            SizedBox(width: 8.w),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.nunito(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF5252),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 19.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }

  Widget _buildDoctorDetail(
    String label,
    String? value, {
    Color valueColor = Colors.white,
    bool singleLineValue = false,
  }) {
    final detailValue = value?.trim();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (singleLineValue)
            Expanded(
              flex: 1,
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  color: _secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  color: _secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(width: singleLineValue ? 8.w : 12.w),
          if (singleLineValue)
            Expanded(
              flex: 2,
              child: Text(
                detailValue == null || detailValue.isEmpty
                    ? 'Not provided'
                    : detailValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                detailValue == null || detailValue.isEmpty
                    ? 'Not provided'
                    : detailValue,
                textAlign: TextAlign.right,
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    final email = ref.read(authServiceProvider).currentUser?.email;
    if (email == null || email.isEmpty) {
      _showProfileImageError(
        'No account email is available for password reset.',
      );
      return;
    }

    setState(() => _isSendingPasswordReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent to $email',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: AppColors.card,
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      _showProfileImageError(
        error.message ??
            'Could not send a password reset email (${error.code}).',
      );
    } finally {
      if (mounted) setState(() => _isSendingPasswordReset = false);
    }
  }

  Widget _buildInitialAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: AppColors.card,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.nunito(
          fontSize: 34.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoggingOut = true);
    try {
      final authService = ref.read(authServiceProvider);
      // Reset user-specific app state
      ref.read(appProvider.notifier).resetUserData();
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: AppColors.orange,
          ),
        );
        setState(() => _isLoggingOut = false);
      }
    }
  }
}
