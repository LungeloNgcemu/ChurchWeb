import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Connect App — Material ThemeData
/// Source of truth: CLAUDE.md § 4 Design System
///
/// Usage in main.dart:
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.light,
///
/// NOTE: existing main.dart uses `useMaterial3: false` — we keep that.
/// Apply this theme to the existing MaterialApp without removing
/// any existing routes or providers.
abstract class AppTheme {
  // ─── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: false,
      scaffoldBackgroundColor: AppColors.surface,
      primaryColor: AppColors.navy,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        secondary: AppColors.purple,
        tertiary: AppColors.orange,
        surface: AppColors.surface,
        background: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      textTheme: _textTheme(base.textTheme),
      appBarTheme: _appBarTheme(),
      bottomNavigationBarTheme: _bottomNavTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      cardTheme: _cardTheme(),
      chipTheme: _chipTheme(),
      floatingActionButtonTheme: _fabTheme(),
      iconTheme: const IconThemeData(color: AppColors.textMid),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceAlt,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusCard)),
        ),
      ),
    );
  }

  // ─── Text theme ────────────────────────────────────────────────────────────
  static TextTheme _textTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(
          fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.white),
      displayMedium: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.white),
      headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary),
      titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          letterSpacing: -0.5),
      titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary),
      titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary),
      bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.65),
      bodySmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted),
      labelLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.white),
      labelMedium: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMid),
      labelSmall: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.5),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────
  static AppBarTheme _appBarTheme() {
    return AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      elevation: 0,
      toolbarHeight: AppSpacing.topBarHeight,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        letterSpacing: -0.5,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  // ─── Bottom Nav ────────────────────────────────────────────────────────────
  static BottomNavigationBarThemeData _bottomNavTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.purple,
      unselectedItemColor: AppColors.textMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.purple),
      unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted),
    );
  }

  // ─── Elevated Button (orange CTA) ──────────────────────────────────────────
  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: const StadiumBorder(),
        elevation: 0,
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
        shadowColor: Colors.transparent,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? AppColors.orangeDeep.withOpacity(0.2)
              : null,
        ),
      ),
    );
  }

  // ─── Outlined Button (ghost) ───────────────────────────────────────────────
  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMid,
        minimumSize: const Size(double.infinity, 50),
        shape: const StadiumBorder(),
        side: const BorderSide(color: AppColors.surfaceAlt, width: 2),
        textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      ),
    );
  }

  // ─── Input Decoration ──────────────────────────────────────────────────────
  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: AppColors.surfaceAlt, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: AppColors.surfaceAlt, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted),
      labelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.purple,
          letterSpacing: 0.8),
    );
  }

  // ─── Card ──────────────────────────────────────────────────────────────────
  static CardTheme _cardTheme() {
    return CardTheme(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      margin: EdgeInsets.zero,
    );
  }

  // ─── Chips ─────────────────────────────────────────────────────────────────
  static ChipThemeData _chipTheme() {
    return ChipThemeData(
      backgroundColor: AppColors.white,
      selectedColor: AppColors.navy,
      labelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMid),
      secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.white),
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.surfaceAlt, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      pressElevation: 0,
    );
  }

  // ─── FAB ───────────────────────────────────────────────────────────────────
  static FloatingActionButtonThemeData _fabTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
      ),
      elevation: 0,
      highlightElevation: 0,
    );
  }
}
