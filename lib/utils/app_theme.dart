import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppFonts {
  static const String myanmar = 'NotoSansMyanmarCondensed';
}

abstract final class AppColors {
  static const Color accent = Color.fromARGB(255, 71, 8, 195);
  static const Color error = Color(0xFFE53935);

  // Dark palette (Figma source of truth).
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF13131A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkChip = Color(0x33787878);
  static const Color mutedText = Color(0xFFAEAEB2);

  // Light palette (derived counterparts using the same accent).
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0A0A0F);
  static const Color lightTextSecondary = Color(0xFF59595E);
  static const Color lightChip = Color(0x14000000);

  // Shimmer placeholders, tuned to read on each theme's card surface.
  static const Color lightShimmerBase = Color(0xFFE9EAEC);
  static const Color lightShimmerHighlight = Color(0xFFFFFFFF);
  static const Color darkShimmerBase = Color(0xFF1D1D26);
  static const Color darkShimmerHighlight = Color(0xFF2C2C38);
}

abstract final class AppTheme {
  /// English builds use Roboto from GoogleFonts.
  static ThemeData get light => lightFor(const Locale('en'));

  static ThemeData get dark => darkFor(const Locale('en'));

  /// Myanmar builds use the bundled NotoSansMyanmarCondensed asset (1sp smaller).
  static ThemeData lightFor(Locale locale) => _build(
    brightness: Brightness.light,
    locale: locale,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    chip: AppColors.lightChip,
  );

  static ThemeData darkFor(Locale locale) => _build(
    brightness: Brightness.dark,
    locale: locale,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    chip: AppColors.darkChip,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Locale locale,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color chip,
  }) {
    final isDark = brightness == Brightness.dark;
    final isMyanmar = locale.languageCode == 'my';
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: background,
      onSurface: textPrimary,
      surfaceContainerHighest: chip,
      onSurfaceVariant: textSecondary,
      outline: textSecondary.withValues(alpha: 0.4),
      outlineVariant: textSecondary.withValues(alpha: 0.2),
    );

    // Roboto (GoogleFonts) for English, NotoSansMyanmarCondensed (asset) 1sp
    // smaller for Myanmar.
    TextStyle font({
      required double fontSize,
      required Color color,
      FontWeight fontWeight = FontWeight.w400,
      double? height,
      double? letterSpacing,
      bool inter = false,
    }) {
      if (isMyanmar) {
        return TextStyle(
          fontFamily: AppFonts.myanmar,
          fontSize: fontSize - 1.sp,
          fontWeight: fontWeight,
          height: height,
          letterSpacing: letterSpacing,
          color: color,
        );
      }
      if (inter) {
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          letterSpacing: letterSpacing,
          color: color,
        );
      }
      return GoogleFonts.roboto(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }

    final baseTextTheme = isMyanmar
        ? GoogleFonts.robotoTextTheme().apply(fontFamily: AppFonts.myanmar)
        : GoogleFonts.robotoTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: baseTextTheme.copyWith(
        titleLarge: font(
          fontSize: 20.sp,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          inter: true,
        ),
        // OLLIO wordmark.
        displayLarge: font(
          fontSize: 64.sp,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: AppColors.accent,
          inter: true,
        ),
        // Onboarding step titles ("Choose your Interests").
        displayMedium: font(
          fontSize: 40.sp,
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: textPrimary,
          inter: true,
        ),
        // Profile image step title ("Profile Picture").
        displaySmall: font(
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: textPrimary,
          inter: true,
        ),
        // Primary screen titles ("Sign in!").
        headlineMedium: font(
          fontSize: 26.sp,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: textPrimary,
          inter: true,
        ),
        // Form & wizard titles ("Create Account!", "Sign up").
        headlineSmall: font(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        // Step questions (birthday / gender).
        titleMedium: font(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
          color: textPrimary,
        ),
        // Selectable option rows.
        titleSmall: font(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: -0.18,
          color: textPrimary,
          inter: true,
        ),
        // 16sp body text ("Birth of Date").
        bodyLarge: font(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: textSecondary,
        ),
        // Primary 14sp body / input text.
        bodyMedium: font(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: textPrimary,
          inter: true,
        ),
        // Secondary 12sp text (subtitles, terms, dividers).
        bodySmall: font(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: textPrimary,
        ),
        // Button labels.
        labelMedium: font(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          color: textPrimary,
        ),
        // Large button labels (M3/title/medium).
        labelLarge: font(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          height: 24 / 16,
          color: textPrimary,
        ),
        // Small secondary text (11sp).
        labelSmall: font(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          inter: true,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: font(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: font(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: colorScheme.onInverseSurface,
          inter: true,
        ),
        actionTextColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.accent.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: font(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        unselectedLabelStyle: font(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          textStyle: font(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: textSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.r)),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
