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
  String? _copiedUid;
  UserProfile? _profile;
  bool _isUploadingProfileImage = false;
  String? _customProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(firestoreServiceProvider).getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
        });
      }
    } catch (_) {}
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
      return Image.network(
        customPhotoUrl,
        key: ValueKey(customPhotoUrl),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildProviderOrInitialAvatar(
              displayName,
              providerPhotoUrl,
              customPhotoUrl,
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
      return Image.network(
        providerPhotoUrl,
        key: ValueKey(providerPhotoUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildInitialAvatar(displayName),
      );
    }
    return _buildInitialAvatar(displayName);
  }

  Future<void> _openEditDoctorDialog() async {
    final nameCtrl = TextEditingController(
      text: _profile?.fullName ?? _profile?.displayName ?? '',
    );
    final phoneCtrl = TextEditingController(text: _profile?.phone ?? '');
    String selectedGender = _profile?.gender ?? 'Male';

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardAlt,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              title: Text(
                'Doctor Information',
                style: GoogleFonts.nunito(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Information appears on medical PDF examination reports.',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        color: _secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Doctor Full Name
                    Text(
                      'Full Name',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Dr. Alex Morgan',
                        hintStyle: GoogleFonts.nunito(
                          color: _secondaryTextColor,
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Gender
                    Text(
                      'Gender',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: ['Male', 'Female', 'Other'].map((g) {
                        final isSel = selectedGender == g;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedGender = g),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2.w),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                g,
                                style: GoogleFonts.nunito(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isSel
                                      ? AppColors.dark
                                      : _secondaryTextColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12.h),

                    // Phone
                    Text(
                      'Phone',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. +1 555 123 4567',
                        hintStyle: GoogleFonts.nunito(
                          color: _secondaryTextColor,
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.nunito(color: _secondaryTextColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.dark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Save Details',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      await ref
          .read(firestoreServiceProvider)
          .updateDoctorProfile(
            fullName: nameCtrl.text.trim(),
            gender: selectedGender,
            phone: phoneCtrl.text.trim(),
          );
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final streamedProfile = ref.watch(userProfileStreamProvider).value;
    final activeProfile = _profile ?? streamedProfile;

    final displayName = activeProfile?.fullName?.isNotEmpty == true
        ? activeProfile!.fullName!
        : (activeProfile?.displayName.isNotEmpty == true
              ? activeProfile!.displayName
              : (user?.displayName?.isNotEmpty == true
                    ? user!.displayName!
                    : (user?.email?.isNotEmpty == true
                          ? user!.email!.split('@').first
                          : 'Medical Officer')));
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

    return Container(
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

            // ── DOCTOR REPORT INFORMATION CARD ────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DOCTOR REPORT CREDENTIALS',
                        style: GoogleFonts.nunito(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: _secondaryTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openEditDoctorDialog,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 12.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Edit',
                              style: GoogleFonts.nunito(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildDoctorDetail(
                    'Full Name',
                    activeProfile?.fullName ?? displayName,
                  ),
                  SizedBox(height: 6.h),
                  _buildDoctorDetail(
                    'Gender',
                    activeProfile?.gender ?? 'Not Specified',
                  ),
                  SizedBox(height: 6.h),
                  _buildDoctorDetail(
                    'Phone',
                    _formatPhoneNumber(activeProfile?.phone),
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
    );
  }

  Widget _buildDoctorDetail(String label, String value) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 8.w,
      runSpacing: 2.h,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12.sp,
            color: _secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 12.sp,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatPhoneNumber(String? phone) {
    final value = phone?.trim() ?? '';
    if (value.isEmpty) return 'Not Specified';
    if (!value.startsWith('+212')) return value;

    final nationalNumber = value.substring(4).replaceAll(RegExp(r'\D'), '');
    if (nationalNumber.length <= 3) return '+212 $nationalNumber'.trim();

    return '+212 ${nationalNumber.substring(0, 3)}-'
        '${nationalNumber.substring(3)}';
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
