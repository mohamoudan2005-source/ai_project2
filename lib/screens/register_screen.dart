import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_project/app/providers/app_provider.dart';
import 'package:ai_project/services/auth_service.dart';
import 'package:ai_project/utils/app_theme.dart';
import 'package:ai_project/utils/widgets/sorty_widget.dart';

/// Modern, clean registration screen allowing users to create an account with
/// Email & Password or social providers (Google, Facebook).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Password visibility states
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Loading states
  bool _isRegisterLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  String? _errorMessage;

  bool get _isLoading =>
      _isRegisterLoading || _isGoogleLoading || _isFacebookLoading;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── EMAIL REGISTRATION HANDLER ──────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isRegisterLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      await authService.registerWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (!mounted) return;
      await ref.read(appProvider.notifier).reloadUserData();

      if (!mounted) return;
      // Pop back to root - AuthGate automatically routes to MainScreen/Onboarding
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'An unexpected error occurred during registration. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isRegisterLoading = false);
      }
    }
  }

  // ── SOCIAL REGISTRATION HANDLERS ────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.signInWithGoogle();

      if (credential != null) {
        if (!mounted) return;
        await ref.read(appProvider.notifier).reloadUserData();
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Google registration failed. Please check your connection and configuration.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleFacebookLogin() async {
    if (_isLoading) return;
    setState(() {
      _isFacebookLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.signInWithFacebook();

      if (credential != null) {
        if (!mounted) return;
        await ref.read(appProvider.notifier).reloadUserData();
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Facebook registration failed. Please verify your Facebook Developer app configuration.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          // ── Background Glow ─────────────────────────────────────────────────
          Positioned(
            top: -140.h,
            left: -80.w,
            right: -80.w,
            child: Container(
              height: 440.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.16),
                    AppColors.primary.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  radius: 0.85,
                ),
              ),
            ),
          ),

          // ── Scrollable Form ─────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button to Login
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 14.sp,
                                  color: AppColors.textMain,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Sign In',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // App Logo / Mascot Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.card,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: SortyWidget(
                                  mood: SortyMood.happy,
                                  size: 58.w,
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // Welcome Title
                              Text(
                                'Create Account',
                                style: GoogleFonts.syne(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMain,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              SizedBox(height: 6.h),

                              // Welcome Subtitle
                              Text(
                                'Create your account to get started',
                                style: GoogleFonts.nunito(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // ── Error Banner ──────────────────────────────────────────
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20.h),
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

                        // ── Form Fields ───────────────────────────────────────────

                        // 1. Full Name
                        _buildInputLabel('Full Name'),
                        _buildTextField(
                          controller: _fullNameController,
                          hintText: 'e.g. Dr. Alex Morgan',
                          icon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full Name cannot be empty';
                            }
                            if (value.trim().length < 2) {
                              return 'Please enter a valid full name';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // 2. Username
                        _buildInputLabel('Username'),
                        _buildTextField(
                          controller: _usernameController,
                          hintText: 'e.g. alexmorgan',
                          icon: Icons.alternate_email_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username cannot be empty';
                            }
                            if (value.trim().length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // 3. Email
                        _buildInputLabel('Email Address'),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'name@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email cannot be empty';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // 4. Password
                        _buildInputLabel('Password'),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'At least 6 characters',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSub,
                              size: 20.sp,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // 5. Confirm Password
                        _buildInputLabel('Confirm Password'),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Re-enter your password',
                          icon: Icons.lock_reset_rounded,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSub,
                              size: 20.sp,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 28.h),

                        // ── Register Button ───────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54.h,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.dark,
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: 0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              shadowColor: AppColors.primary.withValues(
                                alpha: 0.35,
                              ),
                            ),
                            child: _isRegisterLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.dark,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Creating Account...',
                                        style: GoogleFonts.syne(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Create Account',
                                    style: GoogleFonts.syne(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.dark,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // ── Divider ───────────────────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: GoogleFonts.syne(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDead,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 22.h),

                        // ── Social Registration Buttons ───────────────────────────
                        // Google
                        _SocialRegisterButton(
                          label: 'Continue with Google',
                          icon: const _GoogleIcon(),
                          backgroundColor: Colors.white,
                          textColor: const Color(0xFF1F1F1F),
                          isLoading: _isGoogleLoading,
                          loadingLabel: 'Connecting Google...',
                          onTap: _isLoading ? null : _handleGoogleSignIn,
                        ),

                        SizedBox(height: 12.h),

                        // Facebook
                        _SocialRegisterButton(
                          label: 'Continue with Facebook',
                          icon: const _FacebookIcon(),
                          backgroundColor: const Color(0xFF1877F2),
                          textColor: Colors.white,
                          isLoading: _isFacebookLoading,
                          loadingLabel: 'Connecting Facebook...',
                          onTap: _isLoading ? null : _handleFacebookLogin,
                        ),

                        SizedBox(height: 28.h),

                        // ── Login Navigation Link ─────────────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.nunito(
                                  fontSize: 15.sp,
                                  color: AppColors.textSub,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Already have an account? ',
                                  ),
                                  TextSpan(
                                    text: 'Sign In',
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

                        SizedBox(height: 24.h),
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

  // ── Input Helper Widgets ────────────────────────────────────────────────────

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
      child: Text(
        label,
        style: GoogleFonts.syne(
          fontSize: 13.sp,
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
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.nunito(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.nunito(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textHint,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSub, size: 20.sp),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.card,
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: const Color(0xFFFF5252).withValues(alpha: 0.8),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
        ),
        errorStyle: GoogleFonts.nunito(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF8A80),
        ),
      ),
      validator: validator,
    );
  }
}

// ── Social Register Button Widget ─────────────────────────────────────────────

class _SocialRegisterButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final String loadingLabel;
  final VoidCallback? onTap;

  const _SocialRegisterButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.isLoading,
    required this.loadingLabel,
    required this.onTap,
  });

  @override
  State<_SocialRegisterButton> createState() => _SocialRegisterButtonState();
}

class _SocialRegisterButtonState extends State<_SocialRegisterButton> {
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
        height: 52.h,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.textColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      widget.loadingLabel,
                      style: GoogleFonts.syne(
                        fontSize: 14.sp,
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
                    SizedBox(width: 10.w),
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
    return CustomPaint(size: Size(20.w, 20.w), painter: _GoogleLogoPainter());
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
      width: 20.w,
      height: 20.w,
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
          fontSize: 15.sp,
          fontFamily: 'sans-serif',
          height: 1.1,
        ),
      ),
    );
  }
}
