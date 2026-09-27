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
    final double buttonSize = size ?? 43.w;

    final photoUrl = user?.photoURL;
    final initial =
        (user?.displayName?.isNotEmpty == true
                ? user!.displayName![0]
                : (user?.email?.isNotEmpty == true ? user!.email![0] : 'U'))
            .toUpperCase();

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
          child: photoUrl != null && photoUrl.isNotEmpty
              ? Image.network(
                  photoUrl,
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
