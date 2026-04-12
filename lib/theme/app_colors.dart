import 'package:flutter/material.dart';
import 'connect_theme_data.dart';
import 'theme_manager.dart';

/// Connect App — Design System Colors
///
/// All themed colour tokens are now dynamic getters that delegate to the
/// currently active [ConnectThemeData] via [ThemeManager.instance].
///
/// When [ThemeManager.setTheme] is called the [Consumer<ThemeManager>] in
/// main.dart rebuilds the MaterialApp, causing the full widget tree to
/// rebuild.  Every [AppColors.xxx] getter call during that rebuild returns
/// the new theme's colour, so every screen updates automatically.
///
/// ⚠  Because these are getters (not compile-time constants) you CANNOT use
/// them inside `const` widget constructors.  Remove `const` from any
/// constructor that passes an AppColors value as a parameter.
///
/// Fixed colours (white, error, success, blueAccent) remain as true consts
/// and may still appear in `const` contexts.
abstract class AppColors {
  // ── Convenience accessor ──────────────────────────────────────────────────
  static ConnectThemeData get _t => ThemeManager.instance.colors;

  // ─── Navy / top-bar ───────────────────────────────────────────────────────
  static Color get navy        => _t.topBar;
  static Color get navyDeep    => _t.backgroundDeep;
  static Color get navyCard    => _t.cardElevated;

  // ─── Primary (purple / blue / cyan / coral / emerald) ────────────────────
  static Color get purple      => _t.primary;
  static Color get purpleLight => _t.primaryLight;
  static Color get purpleTint  => _t.primaryTint;
  static Color get purpleBorder => _t.primaryBorder;
  static Color get purpleBadge  => _t.primaryBadge;

  // ─── Accent (orange / lime / gold) ───────────────────────────────────────
  static Color get orange      => _t.accent;
  static Color get orangeDeep  => _t.accentDeep;
  static Color get orangeTint  => _t.accentTint;

  // ─── Neutrals ─────────────────────────────────────────────────────────────
  static const Color white     = Color(0xFFFFFFFF);
  static Color get surface     => _t.background;
  static Color get surfaceAlt  => _t.backgroundAlt;

  // ─── Text ─────────────────────────────────────────────────────────────────
  static Color get textPrimary   => _t.textPrimary;
  static Color get textSecondary => _t.textSecondary;
  static Color get textMuted     => _t.textMuted;
  static Color get textDisabled  => _t.textDisabled;
  static Color get textMid       => _t.textMid;

  // ─── Semantic (fixed) ─────────────────────────────────────────────────────
  static const Color success       = Color(0xFF22C55E);
  static const Color error         = Color(0xFFDC2626);
  static const Color blueAccent    = Color(0xFF2563EB);
  static const Color blueAccentDeep = Color(0xFF1D4ED8);
  static const Color blueAccentTint = Color(0xFFEFF6FF);

  // ─── Transparent overlays ─────────────────────────────────────────────────
  static Color get whiteDim   => Colors.white.withOpacity(0.45);
  static Color get whiteFaint => Colors.white.withOpacity(0.10);
  static Color get navyIconBg => Colors.white.withOpacity(0.08);

  // ─── Standard Gradients ───────────────────────────────────────────────────
  static LinearGradient get purpleHeaderGradient => _t.primaryHeaderGradient;
  static LinearGradient get purpleCardGradient   => _t.primaryCardGradient;
  static LinearGradient get orangeGradient        => _t.accentGradient;
  static LinearGradient get darkSplitGradient     => _t.darkSplitGradient;

  // ─── Avatar Role Gradients (fixed — not themed) ───────────────────────────
  static const LinearGradient avatarLeader = ConnectThemeData.avatarLeader;
  static const LinearGradient avatarCoordinator = ConnectThemeData.avatarCoordinator;
  static const LinearGradient avatarMedia = ConnectThemeData.avatarMedia;
  static const LinearGradient avatarMember = ConnectThemeData.avatarMember;
  static const LinearGradient avatarNewMember = ConnectThemeData.avatarNewMember;

  static LinearGradient avatarGradientForRole(String? role) =>
      ConnectThemeData.avatarGradientForRole(role);
}
