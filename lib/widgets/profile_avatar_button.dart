import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/widgets/user_profile_modal.dart';

/// Reusable user profile avatar button that opens [UserProfileModal] on tap.
class ProfileAvatarButton extends ConsumerWidget {
  final double? size;
  const ProfileAvatarButton({super.key, this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final userProfile = ref.watch(userProfileStreamProvider).value;
    final double buttonSize = size ?? 43.w;

    // Display Priority:
    // 1. Custom profile image saved in Firestore
    // 2. Google/Facebook provider photoURL
    // 3. Default avatar
    final effectivePhotoUrl = (userProfile?.profileImage?.isNotEmpty == true)
        ? userProfile!.profileImage
        : (user?.photoURL?.isNotEmpty == true ? user!.photoURL : null);

    final displayName = (userProfile?.fullName?.isNotEmpty == true)
        ? userProfile!.fullName!
        : (userProfile?.displayName.isNotEmpty == true
              ? userProfile!.displayName
              : (user?.displayName?.isNotEmpty == true
                    ? user!.displayName!
                    : (user?.email?.isNotEmpty == true
                          ? user!.email!.split('@').first
                          : 'U')));

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return GestureDetector(
      onTap: () => UserProfileModal.show(context),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.45),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: effectivePhotoUrl != null && effectivePhotoUrl.isNotEmpty
              ? Image.network(
                  effectivePhotoUrl,
                  key: ValueKey(effectivePhotoUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallback(initial),
                )
              : _buildFallback(initial),
        ),
      ),
    );
  }

  Widget _buildFallback(String initial) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.syne(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
