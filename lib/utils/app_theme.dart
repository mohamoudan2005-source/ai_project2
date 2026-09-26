import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colors ────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFFC8F135);
  static const orange = Color(0xFFFF6B35);

  // Backgrounds
  static const dark = Color(0xFF0A0A09);
  static const card = Color(0xFF161614);
  static const cardAlt = Color(0xFF1C1C1A);
  static const muted = Color(0xFF3A3A36);

  // Text
  static const textMain = Color(0xFFF0EFE8);
  static const textSub = Color(0xFF8A8A80);
  static const textHint = Color(0xFF555550);
  static const textDead = Color(0xFF444440);

  // Lime variants
  static const limeBg = Color(0x1FC8F135);
  static const limeBorder = Color(0x4DC8F135);
  static const limeGlow = Color(0x26C8F135);

  // Orange variants
  static const orangeBg = Color(0x26FF6B35);
  static const orangeBorder = Color(0x4DFF6B35);
}

// ── Typography ────────────────────────────────────────────────────────────────
// All font sizes use .sp for screen-density scaling
// Call AppTextStyles inside the widget tree ONLY (after ScreenUtil.init)

class AppTextStyles {
  AppTextStyles._();

  // ── Syne ──────────────────────────────────────────────────────────────────

  static TextStyle get appName => GoogleFonts.syne(
    fontSize: 19.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    letterSpacing: 0.22,
  );

  static TextStyle get displayLarge => GoogleFonts.syne(
    fontSize: 44.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.0,
    letterSpacing: -0.02,
  );

  static TextStyle get displayMedium => GoogleFonts.syne(
    fontSize: 32.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.1,
    letterSpacing: -0.01,
  );

  static TextStyle get headingLarge => GoogleFonts.syne(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.1,
  );

  static TextStyle get headingMedium => GoogleFonts.syne(
    fontSize: 20.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.2,
  );

  static TextStyle get headingSmall => GoogleFonts.syne(
    fontSize: 23.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    height: 1.2,
  );

  static TextStyle get label => GoogleFonts.syne(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.12,
  );

  static TextStyle get buttonText => GoogleFonts.syne(
    fontSize: 17.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.dark,
  );

  static TextStyle get buttonTextLight => GoogleFonts.syne(
    fontSize: 15.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
  );

  static TextStyle get missionTitle => GoogleFonts.syne(
    fontSize: 22.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.1,
  );

  // ── Nunito ────────────────────────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: 19.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
    height: 1.55,
  );

  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSub,
    height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.nunito(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSub,
    height: 1.4,
  );

  static TextStyle get hint => GoogleFonts.nunito(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDead,
    letterSpacing: 0.16,
  );

  static TextStyle get italic => GoogleFonts.nunito(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSub,
    fontStyle: FontStyle.italic,
    height: 1.6,
  );

  static TextStyle get streakNum => GoogleFonts.syne(
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static TextStyle get scanPhrase => GoogleFonts.syne(
    fontSize: 20.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.2,
  );

  static TextStyle get progressLabel => GoogleFonts.syne(
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.05,
  );
}

// ── Spacing ───────────────────────────────────────────────────────────────────
// All values use .w / .h / .r for responsive sizing

class AppSpacing {
  AppSpacing._();

  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
  static double get huge => 48.w;

  // Screen padding
  static EdgeInsets get screenH => EdgeInsets.symmetric(horizontal: 20.w);

  static EdgeInsets get screenPad =>
      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);

  static EdgeInsets get cardPad =>
      EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h);

  static EdgeInsets get modalPad => EdgeInsets.fromLTRB(26.w, 20.h, 26.w, 48.h);

  static EdgeInsets get stepPad =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h);
}

// ── Radius ────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static double get sm => 10.r;
  static double get md => 14.r;
  static double get lg => 18.r;
  static double get xl => 24.r;
  static double get xxl => 32.r;
  static double get pill => 100.r;

  static BorderRadius get smBr => BorderRadius.circular(sm);
  static BorderRadius get mdBr => BorderRadius.circular(md);
  static BorderRadius get lgBr => BorderRadius.circular(lg);
  static BorderRadius get xlBr => BorderRadius.circular(xl);
  static BorderRadius get xxlBr => BorderRadius.circular(xxl);
  static BorderRadius get pillBr => BorderRadius.circular(pill);
}

// ── Sizes ─────────────────────────────────────────────────────────────────────
// Fixed component dimensions using .w / .h / .r

class AppSizes {
  AppSizes._();

  // Buttons
  static double get buttonHeight => 52.h;
  static double get buttonHeightSm => 40.h;

  // Icons
  static double get iconSm => 16.w;
  static double get iconMd => 24.w;
  static double get iconLg => 28.w;

  // Sorty
  static double get sortyCam => 130.w;
  static double get sortyScan => 130.w;
  static double get sortyTime => 90.w;
  static double get sortyTip => 50.w;
  static double get sortyComplete => 130.w;
  static double get sortyHistory => 110.w;

  // Snap button
  static double get snapBtnOuter => 100.w;
  static double get snapBtnInner => 70.w;

  // Gallery button
  static double get galleryBtn => 60.w;

  // History thumbnail
  static double get histThumb => 52.w;
  static double get histThumbRadius => 10.r;

  // Plan hero
  static double get planHeroHeight => 300.h;

  // Step check circle
  static double get stepCheck => 30.w;

  // Streak pill
  static double get streakDot => 6.w;

  // Progress bar
  static double get progressHeight => 5.h;

  // Scan rings
  static double get scanRingOuter => 220.w;
  static double get scanRingInner => 180.w;
  static double get scanRingContainer => 240.w;

  // Time thumb
  static double get timeThumb => 100.w;
  static double get timeThumbRadius => 18.r;

  // Modal handle
  static double get modalHandle => 40.w;
  static double get modalHandleHeight => 4.h;
}

// ── Decorations ───────────────────────────────────────────────────────────────

class AppDecorations {
  AppDecorations._();

  static BoxDecoration get card => BoxDecoration(
    color: AppColors.card,
    borderRadius: AppRadius.lgBr,
    border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
  );

  static BoxDecoration get cardAlt => BoxDecoration(
    color: AppColors.cardAlt,
    borderRadius: AppRadius.lgBr,
    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
  );

  static BoxDecoration get cardLime => BoxDecoration(
    color: AppColors.limeBg,
    borderRadius: AppRadius.lgBr,
    border: Border.all(color: AppColors.limeBorder, width: 1),
  );

  static BoxDecoration get cardOrange => BoxDecoration(
    color: AppColors.orangeBg,
    borderRadius: AppRadius.lgBr,
    border: Border.all(color: AppColors.orangeBorder, width: 1),
  );

  static BoxDecoration get badgeLime => BoxDecoration(
    color: AppColors.limeBg,
    borderRadius: AppRadius.pillBr,
    border: Border.all(color: AppColors.limeBorder, width: 1),
  );

  static BoxDecoration get badgeOrange => BoxDecoration(
    color: AppColors.orangeBg,
    borderRadius: AppRadius.smBr,
    border: Border.all(color: AppColors.orangeBorder, width: 1),
  );

  static BoxDecoration get buttonPrimary => BoxDecoration(
    color: AppColors.primary,
    borderRadius: AppRadius.lgBr,
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.25),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get buttonGhost => BoxDecoration(
    color: Colors.transparent,
    borderRadius: AppRadius.lgBr,
    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
  );

  static BoxDecoration get progressTrack => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(3.r),
  );

  static BoxDecoration get progressFill => BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(3.r),
    boxShadow: [
      BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 8),
    ],
  );

  static BoxDecoration get topSheet => BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
  );
}

// ── Durations ─────────────────────────────────────────────────────────────────

class AppDurations {
  AppDurations._();

  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const xslow = Duration(milliseconds: 800);
  static const bounce = Duration(milliseconds: 1200);
  static const glow = Duration(milliseconds: 1800);
  static const ring = Duration(milliseconds: 2200);
  static const float = Duration(milliseconds: 3500);
  static const grid = Duration(seconds: 8);
  static const hint = Duration(seconds: 3);
}

// ── Curves ────────────────────────────────────────────────────────────────────

class AppCurves {
  AppCurves._();

  static const snap = Curves.easeOut;
  static const smooth = Curves.easeInOut;
  static const spring = Curves.elasticOut;
  static const pop = Curves.easeOutBack;
}

// ── System UI ─────────────────────────────────────────────────────────────────

class AppSystemUI {
  AppSystemUI._();

  static void apply() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.dark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  static void setPortrait() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}

// ── Theme ─────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark,
    primaryColor: AppColors.primary,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.orange,
      surface: AppColors.card,
      error: AppColors.orange,
    ),

    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      headlineLarge: AppTextStyles.headingLarge,
      headlineMedium: AppTextStyles.headingMedium,
      headlineSmall: AppTextStyles.headingSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelSmall: AppTextStyles.caption,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.textMain,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headingMedium,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    iconTheme: IconThemeData(color: AppColors.textMain, size: AppSizes.iconMd),

    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.07),
      thickness: 1,
      space: 1,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardAlt,
      contentTextStyle: AppTextStyles.bodySmall,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
      behavior: SnackBarBehavior.floating,
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
