import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/utils/app_theme.dart';

/// Modal bottom sheet displaying authenticated user profile details,
/// authentication provider, and sign out control.
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
  bool _isLoggingOut = false;
  String? _copiedUid;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final appState = ref.watch(appProvider);

    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : (user?.email?.isNotEmpty == true
              ? user!.email!.split('@').first
              : 'Lung Lens User');
    final email = user?.email ?? 'No email associated';
    final photoUrl = user?.photoURL;
    final uid = user?.uid ?? 'Unknown';

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 44.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 24.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Profile Picture / Initial Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 84.w,
                height: 84.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: AppColors.primary, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildInitialAvatar(displayName),
                        )
                      : _buildInitialAvatar(displayName),
                ),
              ),
              // Provider badge
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: providerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardAlt, width: 2),
                ),
                child: Icon(providerIcon, size: 14.sp, color: Colors.white),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // User Name
          Text(
            displayName,
            style: GoogleFonts.syne(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Email
          Text(
            email,
            style: GoogleFonts.nunito(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSub,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // Provider & Streak Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Provider pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: providerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: providerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(providerIcon, size: 16.sp, color: providerColor),
                    SizedBox(width: 6.w),
                    Text(
                      providerName,
                      style: GoogleFonts.nunito(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: providerColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              // Streak pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 5.w),
                    Text(
                      '${appState.streak} Streak',
                      style: GoogleFonts.syne(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fingerprint_rounded,
                    color: AppColors.textSub,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'USER UID (DATA ISOLATED)',
                          style: GoogleFonts.syne(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDead,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          uid,
                          style: GoogleFonts.nunito(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSub,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    _copiedUid != null
                        ? Icons.check_circle_rounded
                        : Icons.copy_rounded,
                    size: 18.sp,
                    color: _copiedUid != null
                        ? AppColors.primary
                        : AppColors.textSub,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 28.h),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
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
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF5252),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 20),
                        SizedBox(width: 10.w),
                        Text(
                          'Log Out',
                          style: GoogleFonts.syne(
                            fontSize: 16.sp,
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
    );
  }

  Widget _buildInitialAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: AppColors.card,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.syne(
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
