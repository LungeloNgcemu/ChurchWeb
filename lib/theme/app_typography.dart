import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Connect App — Typography System
/// Source of truth: CLAUDE.md § 4.2 Typography — Inter
/// All text styles use Inter via google_fonts.
/// Usage: AppTypography.screenTitle, AppTypography.bodyText, etc.
abstract class AppTypography {
  // ─── Base helper ───────────────────────────────────────────────────────────
  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // ─── Display / Wordmark ────────────────────────────────────────────────────
  /// App wordmark / splash title — 34px Black on dark
  static TextStyle get wordmark => _inter(
        size: 34,
        weight: FontWeight.w900,
        color: AppColors.white,
        letterSpacing: -1.5,
      );

  // ─── Screen Titles ─────────────────────────────────────────────────────────
  /// Topbar screen title — 20px ExtraBold white
  static TextStyle get screenTitle => _inter(
        size: 20,
        weight: FontWeight.w800,
        color: AppColors.white,
        letterSpacing: -0.5,
      );

  /// Auth hero title (e.g. "Welcome Back.") — 28px Black white
  static TextStyle get heroTitle => _inter(
        size: 28,
        weight: FontWeight.w900,
        color: AppColors.white,
        letterSpacing: -1.0,
      );

  // ─── Section & Card Headings ───────────────────────────────────────────────
  /// Large section heading (card header) — 22px ExtraBold on light
  static TextStyle get headingLarge => _inter(
        size: 22,
        weight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// Standard section heading — 18px ExtraBold on light
  static TextStyle get headingMedium => _inter(
        size: 18,
        weight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );

  /// Small section heading / feed row title — 15px ExtraBold on light
  static TextStyle get headingSmall => _inter(
        size: 15,
        weight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  // ─── Card Content ──────────────────────────────────────────────────────────
  /// Card title / bold row label — 14px Bold on light
  static TextStyle get cardTitle => _inter(
        size: 14,
        weight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Card subtitle / secondary label — 13px Bold on light
  static TextStyle get cardSubtitle => _inter(
        size: 13,
        weight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // ─── Body Text ─────────────────────────────────────────────────────────────
  /// Standard body — 13px Regular/Medium on light
  static TextStyle get bodyText => _inter(
        size: 13,
        weight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.65,
      );

  /// Body medium weight — 13px SemiBold on light
  static TextStyle get bodyMedium => _inter(
        size: 13,
        weight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.65,
      );

  // ─── Form Fields ───────────────────────────────────────────────────────────
  /// Form field value text — 14px SemiBold on light
  static TextStyle get fieldValue => _inter(
        size: 14,
        weight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Form field placeholder — 14px Regular muted
  static TextStyle get fieldPlaceholder => _inter(
        size: 14,
        weight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  /// Form field label — 10px Bold purple UPPERCASE
  static TextStyle get fieldLabel => _inter(
        size: 10,
        weight: FontWeight.w700,
        color: AppColors.purple,
        letterSpacing: 0.8,
      );

  // ─── Buttons ───────────────────────────────────────────────────────────────
  /// Primary/secondary button label — 15px Bold white
  static TextStyle get buttonPrimary => _inter(
        size: 15,
        weight: FontWeight.w700,
        color: AppColors.white,
      );

  /// Ghost button label — 13px SemiBold muted
  static TextStyle get buttonGhost => _inter(
        size: 13,
        weight: FontWeight.w600,
        color: AppColors.textMid,
      );

  // ─── Chips & Badges ────────────────────────────────────────────────────────
  /// Filter chip / category chip — 11px SemiBold
  static TextStyle get chipLabel => _inter(
        size: 11,
        weight: FontWeight.w600,
        color: AppColors.textMid,
      );

  /// Badge text (count / role) — 10–11px Bold
  static TextStyle get badge => _inter(
        size: 10,
        weight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // ─── Captions & Meta ───────────────────────────────────────────────────────
  /// Timestamp, metadata — 11px Medium muted
  static TextStyle get caption => _inter(
        size: 11,
        weight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  /// Tiny label (nav labels, section headers) — 9–10px SemiBold
  static TextStyle get labelTiny => _inter(
        size: 9,
        weight: FontWeight.w600,
        color: AppColors.textMuted,
      );

  /// Uppercase section divider — 10px Bold muted with letter spacing
  static TextStyle get sectionDivider => _inter(
        size: 10,
        weight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.0,
      );

  // ─── Stats / Numbers ───────────────────────────────────────────────────────
  /// Hero stat value — 18–22px ExtraBold white
  static TextStyle get statValue => _inter(
        size: 18,
        weight: FontWeight.w800,
        color: AppColors.white,
      );

  /// OTP digit — 24px ExtraBold purple
  static TextStyle get otpDigit => _inter(
        size: 24,
        weight: FontWeight.w800,
        color: AppColors.purple,
      );

  // ─── Links ─────────────────────────────────────────────────────────────────
  /// Inline text link — 12px Bold purple
  static TextStyle get link => _inter(
        size: 12,
        weight: FontWeight.w700,
        color: AppColors.purple,
      );

  /// "See all →" link — 12px Bold orange
  static TextStyle get linkOrange => _inter(
        size: 12,
        weight: FontWeight.w700,
        color: AppColors.orange,
      );

  // ─── Dark surface overrides ────────────────────────────────────────────────
  /// Any of the above styles, copied with white color, for use on dark bg.
  /// e.g. AppTypography.onDark(AppTypography.cardTitle)
  static TextStyle onDark(TextStyle base) => base.copyWith(color: AppColors.white);

  /// Same but dimmed white (subtitles on dark)
  static TextStyle onDarkDim(TextStyle base) =>
      base.copyWith(color: AppColors.whiteDim);
}
