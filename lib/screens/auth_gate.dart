import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/app/ui/screens/main_screen.dart';
import 'package:ai_project/main.dart';
import 'package:ai_project/screens/login_screen.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

/// Master Authentication Gate.
/// Controls application routing dynamically based on Firebase Auth state:
/// - Unauthenticated: [LoginScreen]
/// - Authenticated + Onboarded: [MainScreen]
/// - Authenticated + New User: [OnboardingRouter]
class AuthGate extends ConsumerStatefulWidget {
  final bool onboardingDone;
  const AuthGate({super.key, required this.onboardingDone});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  String? _lastLoadedUid;
  String? _loadedUid;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // ── 1. Waiting for Firebase Auth Initial State ────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        final user = snapshot.data;

        // ── 2. Unauthenticated ───────────────────────────────────────────────
        if (user == null) {
          final shouldResetUserData = _lastLoadedUid != null;
          _lastLoadedUid = null;
          _loadedUid = null;
          if (shouldResetUserData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && authService.currentUser == null) {
                ref.read(appProvider.notifier).resetUserData();
              }
            });
          }
          return const LoginScreen();
        }

        // ── 3. Authenticated: Reload user-specific data on user change ───────
        if (_lastLoadedUid != user.uid) {
          _lastLoadedUid = user.uid;
          _loadedUid = null;
          final uid = user.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted ||
                _lastLoadedUid != uid ||
                authService.currentUser?.uid != uid) {
              return;
            }
            final controller = ref.read(appProvider.notifier);
            controller.resetUserData();
            await controller.reloadUserData();
            if (mounted &&
                _lastLoadedUid == uid &&
                authService.currentUser?.uid == uid) {
              setState(() => _loadedUid = uid);
            }
          });
        }

        if (_loadedUid != user.uid) {
          return const _AuthLoadingScreen();
        }

        // ── 4. Route to Main App or Onboarding ───────────────────────────────
        if (widget.onboardingDone) {
          return const MainScreen();
        } else {
          return const OnboardingRouter();
        }
      },
    );
  }
}

/// Themed splash screen displayed during initial Firebase auth verification.
class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SortyWidget(mood: SortyMood.happy, size: 70.w),
            SizedBox(height: 24.h),
            Text(
              'Lung Lens',
              style: GoogleFonts.syne(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
