import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/screens/register_screen.dart';
import 'package:ai_project/services/auth_service.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

/// Modern authentication screen providing Google Sign-In, Facebook Login,
/// Email/Password Sign-In, and navigation to the Register page.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;
  bool _isEmailLoading = false;
  bool _showEmailForm = false;
  bool _obscurePassword = true;

  String? _errorMessage;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _floatAnim;

  bool get _isLoading =>
      _isGoogleLoading || _isFacebookLoading || _isEmailLoading;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _floatAnim = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── EMAIL SIGN-IN HANDLER ───────────────────────────────────────────────────

  Future<void> _handleEmailSignIn() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isEmailLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        await ref.read(appProvider.notifier).reloadUserData();
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'An unexpected error occurred during sign-in. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isEmailLoading = false);
      }
    }
  }

  // ── GOOGLE SIGN-IN HANDLER ──────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.signInWithGoogle();

      if (credential != null && mounted) {
        await ref.read(appProvider.notifier).reloadUserData();
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'An unexpected error occurred during Google Sign-In. Please check your connection and configuration.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  // ── FACEBOOK LOGIN HANDLER ──────────────────────────────────────────────────

  Future<void> _handleFacebookLogin() async {
    if (_isLoading) return;
    setState(() {
      _isFacebookLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.signInWithFacebook();

      if (credential != null && mounted) {
        await ref.read(appProvider.notifier).reloadUserData();
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Facebook sign-in failed. Please verify your Facebook Developer app configuration.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
      }
    }
  }

  // ── LOGOUT HANDLER (WHEN ALREADY SIGNED IN) ─────────────────────────────────

  Future<void> _handleSignOut() async {
    if (_isLoading) return;
    setState(() {
      _errorMessage = null;
    });
    try {
      ref.read(appProvider.notifier).resetUserData();
      await ref.read(authServiceProvider).signOut();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to sign out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          // ── Background Glow ─────────────────────────────────────────────────
          Positioned(
            top: -120.h,
            left: -80.w,
            right: -80.w,
            child: Container(
              height: 480.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  radius: 0.85,
                ),
              ),
            ),
          ),

          // ── Main Content ────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),

                        // Animated Mascot
                        AnimatedBuilder(
                          animation: _animCtrl,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: child,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.card,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: SortyWidget(
                              mood: SortyMood.happy,
                              size: 72.w,
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // App Name
                        Text(
                          'Lung Lens',
                          style: GoogleFonts.syne(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                            letterSpacing: -0.5,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Subtitle Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            'AI CHEST X-RAY DIAGNOSTICS',
                            style: GoogleFonts.syne(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Value Proposition
                        Text(
                          'Sign in to access your medical scans, analysis history, and personalized diagnostic trends.',
                          style: GoogleFonts.nunito(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSub,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 22.h),

                        // ── Error Banner ──────────────────────────────────────────
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF281110),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: const Color(
                                  0xFFFF5252,
                                ).withValues(alpha: 0.45),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFFF5252),
                                  size: 20,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.nunito(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFF8A80),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _errorMessage = null),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ── Active Session / Auth Methods ─────────────────────────
                        if (currentUser != null) ...[
                          // Already Authenticated Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      radius: 20.r,
                                      child: Text(
                                        (currentUser.displayName?.isNotEmpty ==
                                                    true
                                                ? currentUser.displayName![0]
                                                : 'U')
                                            .toUpperCase(),
                                        style: GoogleFonts.syne(
                                          color: AppColors.dark,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentUser.displayName ??
                                                'Signed In',
                                            style: GoogleFonts.syne(
                                              color: AppColors.textMain,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Text(
                                            currentUser.email ??
                                                currentUser.uid,
                                            style: GoogleFonts.nunito(
                                              color: AppColors.textSub,
                                              fontSize: 12.sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _handleSignOut,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: const Color(
                                              0xFFFF5252,
                                            ).withValues(alpha: 0.4),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Sign Out',
                                          style: GoogleFonts.syne(
                                            color: const Color(0xFFFF5252),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ] else ...[
                          // ── Google Sign-In Button ───────────────────────────────
                          _SocialAuthButton(
                            label: 'Continue with Google',
                            icon: const _GoogleIcon(),
                            backgroundColor: Colors.white,
                            textColor: const Color(0xFF1F1F1F),
                            isLoading: _isGoogleLoading,
                            loadingLabel: 'Signing in with Google...',
                            onTap: _isLoading ? null : _handleGoogleSignIn,
                          ),

                          SizedBox(height: 12.h),

                          // ── Facebook Login Button ───────────────────────────────
                          _SocialAuthButton(
                            label: 'Continue with Facebook',
                            icon: const _FacebookIcon(),
                            backgroundColor: const Color(0xFF1877F2),
                            textColor: Colors.white,
                            isLoading: _isFacebookLoading,
                            loadingLabel: 'Connecting Facebook...',
                            onTap: _isLoading ? null : _handleFacebookLogin,
                          ),

                          SizedBox(height: 16.h),

                          // ── Email Login Section / Toggle ────────────────────────
                          if (!_showEmailForm) ...[
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showEmailForm = true),
                              child: Container(
                                width: double.infinity,
                                height: 52.h,
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      color: AppColors.textMain,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'Sign in with Email',
                                      style: GoogleFonts.syne(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Expandable Email/Password Form
                            Form(
                              key: _formKey,
                              child: Container(
                                padding: EdgeInsets.all(18.w),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Email Sign In',
                                          style: GoogleFonts.syne(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMain,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => _showEmailForm = false,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: AppColors.textSub,
                                            size: 20.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 14.h),

                                    // Email Input
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14.sp,
                                        color: AppColors.textMain,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Email address',
                                        hintStyle: GoogleFonts.nunito(
                                          color: AppColors.textHint,
                                          fontSize: 14.sp,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: AppColors.textSub,
                                          size: 18.sp,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.cardAlt,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 14.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14.r,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        return null;
                                      },
                                    ),

                                    SizedBox(height: 12.h),

                                    // Password Input
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14.sp,
                                        color: AppColors.textMain,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        hintStyle: GoogleFonts.nunito(
                                          color: AppColors.textHint,
                                          fontSize: 14.sp,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppColors.textSub,
                                          size: 18.sp,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppColors.textSub,
                                            size: 18.sp,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: AppColors.cardAlt,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 14.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14.r,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                    ),

                                    SizedBox(height: 16.h),

                                    // Sign In Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48.h,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleEmailSignIn,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.dark,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14.r,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isEmailLoading
                                            ? SizedBox(
                                                width: 18.w,
                                                height: 18.w,
                                                child:
                                                    const CircularProgressIndicator(
                                                      strokeWidth: 2.2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(AppColors.dark),
                                                    ),
                                              )
                                            : Text(
                                                'Sign In',
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
                          ],
                        ],

                        SizedBox(height: 28.h),

                        // ── Register Navigation Link ──────────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.nunito(
                                  fontSize: 15.sp,
                                  color: AppColors.textSub,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Don't have an account? ",
                                  ),
                                  TextSpan(
                                    text: 'Create Account',
                                    style: GoogleFonts.syne(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Privacy / Security notice
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: AppColors.textDead,
                              size: 14.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Data is encrypted & strictly isolated to your UID',
                              style: GoogleFonts.nunito(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDead,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Social Auth Button Widget ────────────────────────────────────────

class _SocialAuthButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final String loadingLabel;
  final VoidCallback? onTap;

  const _SocialAuthButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.isLoading,
    required this.loadingLabel,
    required this.onTap,
  });

  @override
  State<_SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<_SocialAuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: _pressed
            ? Matrix4.diagonal3Values(0.97, 0.97, 1.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.textColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      widget.loadingLabel,
                      style: GoogleFonts.syne(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.icon,
                    SizedBox(width: 12.w),
                    Text(
                      widget.label,
                      style: GoogleFonts.syne(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Google Icon Painter ───────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(22.w, 22.w), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final greenPaint = Paint()..color = const Color(0xFF34A853);

    final pathBlue = Path()
      ..moveTo(w * 0.95, h * 0.5)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.5, h * 0.68)
      ..lineTo(w * 0.77, h * 0.68)
      ..cubicTo(w * 0.75, h * 0.79, w * 0.65, h * 0.88, w * 0.5, h * 0.88)
      ..lineTo(w * 0.5, h * 1.0)
      ..cubicTo(w * 0.75, h * 1.0, w * 0.98, h * 0.78, w * 0.95, h * 0.5);

    final pathGreen = Path()
      ..moveTo(w * 0.5, h * 0.88)
      ..cubicTo(w * 0.35, h * 0.88, w * 0.22, h * 0.77, w * 0.17, h * 0.63)
      ..lineTo(w * 0.03, h * 0.74)
      ..cubicTo(w * 0.12, h * 0.92, w * 0.29, h * 1.0, w * 0.5, h * 1.0)
      ..close();

    final pathYellow = Path()
      ..moveTo(w * 0.17, h * 0.63)
      ..cubicTo(w * 0.15, h * 0.57, w * 0.14, h * 0.5, w * 0.14, h * 0.44)
      ..cubicTo(w * 0.14, h * 0.37, w * 0.15, h * 0.31, w * 0.17, h * 0.24)
      ..lineTo(w * 0.03, h * 0.14)
      ..cubicTo(w * 0.01, h * 0.23, 0, h * 0.33, 0, h * 0.44)
      ..cubicTo(0, h * 0.54, w * 0.01, h * 0.64, w * 0.03, h * 0.74)
      ..close();

    final pathRed = Path()
      ..moveTo(w * 0.17, h * 0.24)
      ..cubicTo(w * 0.22, h * 0.11, w * 0.35, h * 0.02, w * 0.5, h * 0.02)
      ..cubicTo(w * 0.64, h * 0.02, w * 0.76, h * 0.07, w * 0.85, h * 0.15)
      ..lineTo(w * 0.98, h * 0.02)
      ..cubicTo(w * 0.85, -0.01, w * 0.68, -0.02, w * 0.5, 0.0)
      ..cubicTo(w * 0.29, 0.0, w * 0.12, h * 0.12, w * 0.03, h * 0.14)
      ..close();

    canvas.drawPath(pathBlue, bluePaint);
    canvas.drawPath(pathGreen, greenPaint);
    canvas.drawPath(pathYellow, yellowPaint);
    canvas.drawPath(pathRed, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Facebook Icon ─────────────────────────────────────────────────────────────

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'f',
        style: TextStyle(
          color: const Color(0xFF1877F2),
          fontWeight: FontWeight.w900,
          fontSize: 16.sp,
          fontFamily: 'sans-serif',
          height: 1.1,
        ),
      ),
    );
  }
}
