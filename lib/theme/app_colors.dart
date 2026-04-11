import 'package:flutter/material.dart';

/// Connect App — Design System Colors
/// Source of truth: CLAUDE.md § 4.1 Color Palette
/// Matches the approved v2 mockups exactly.
/// DO NOT add one-off colors in screens — use these tokens.
abstract class AppColors {
  // ─── Navy ──────────────────────────────────────────────────────────────────
  /// Primary background, top bars, dark headers
  static const Color navy = Color(0xFF1E293B);

  /// Deepest navy — page background behind content
  static const Color navyDeep = Color(0xFF0F172A);

  /// Elevated dark surface (cards on dark bg)
  static const Color navyCard = Color(0xFF252F45);

  // ─── Purple ────────────────────────────────────────────────────────────────
  /// Primary accent — active states, badges, icons, active nav
  static const Color purple = Color(0xFF7C3AED);

  /// Gradient partner to purple (header gradients, card gradients)
  static const Color purpleLight = Color(0xFF4F46E5);

  /// Purple-tinted light background (chip bg, icon bg, input active bg)
  static const Color purpleTint = Color(0xFFF5F3FF);

  /// Subtle purple border
  static const Color purpleBorder = Color(0xFFDDD6FE);

  /// Purple badge / pill text background
  static const Color purpleBadge = Color(0xFFEDE9FE);

  // ─── Orange ────────────────────────────────────────────────────────────────
  /// CTA buttons, FABs, event date blocks, notification badge
  static const Color orange = Color(0xFFF97316);

  /// Orange pressed / gradient end
  static const Color orangeDeep = Color(0xFFEA580C);

  /// Orange tint for backgrounds
  static const Color orangeTint = Color(0xFFFFF7ED);

  // ─── Neutrals ──────────────────────────────────────────────────────────────
  /// Pure white — card surfaces, bottom nav, light panels
  static const Color white = Color(0xFFFFFFFF);

  /// Light page background
  static const Color surface = Color(0xFFF8FAFC);

  /// Dividers, inactive input backgrounds, borders
  static const Color surfaceAlt = Color(0xFFF1F5F9);

  // ─── Text ──────────────────────────────────────────────────────────────────
  /// Primary body text on light surfaces (charcoal)
  static const Color textPrimary = Color(0xFF1C1917);

  /// Secondary body text
  static const Color textSecondary = Color(0xFF475569);

  /// Placeholders, timestamps, muted labels
  static const Color textMuted = Color(0xFF94A3B8);

  /// Inactive icon / border colour
  static const Color textDisabled = Color(0xFFCBD5E1);

  /// Mid-tone label (form labels, inactive chip text)
  static const Color textMid = Color(0xFF64748B);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  /// Online dots, success states, valid badges
  static const Color success = Color(0xFF22C55E);

  /// Destructive actions, error states
  static const Color error = Color(0xFFDC2626);

  /// Info badges, media highlights
  static const Color blueAccent = Color(0xFF2563EB);

  static const Color blueAccentDeep = Color(0xFF1D4ED8);

  static const Color blueAccentTint = Color(0xFFEFF6FF);

  // ─── Transparent / Overlay ─────────────────────────────────────────────────
  /// White text at reduced opacity on dark surfaces
  static const Color whiteDim = Color(0x73FFFFFF); // ~45% opacity

  static const Color whiteFaint = Color(0x1AFFFFFF); // ~10% opacity

  /// Navy overlay on topbar icon buttons
  static const Color navyIconBg = Color(0x14FFFFFF); // ~8% opacity

  // ─── Standard Gradients ────────────────────────────────────────────────────
  /// Purple hero header gradient (160°: navy → purpleLight → purple)
  static const LinearGradient purpleHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(160 * 3.14159 / 180),
    colors: [navy, purpleLight, purple],
    stops: [0.0, 0.6, 1.0],
  );

  /// Purple card gradient (135°: purple → purpleLight)
  static const LinearGradient purpleCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleLight],
  );

  /// Orange CTA gradient (135°: orange → orangeDeep)
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeDeep],
  );

  /// Dark split-screen top gradient (auth screens)
  static const LinearGradient darkSplitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(160 * 3.14159 / 180),
    colors: [navy, navyCard],
  );

  // ─── Avatar Role Gradients ─────────────────────────────────────────────────
  static const LinearGradient avatarLeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleLight],
  );

  static const LinearGradient avatarCoordinator = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeDeep],
  );

  static const LinearGradient avatarMedia = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueAccent, blueAccentDeep],
  );

  static const LinearGradient avatarMember = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF047857)],
  );

  static const LinearGradient avatarNewMember = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
  );

  /// Returns the correct avatar gradient for a given role string.
  static LinearGradient avatarGradientForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'leader':
        return avatarLeader;
      case 'coordinator':
      case 'coord':
        return avatarCoordinator;
      case 'media':
        return avatarMedia;
      case 'new':
        return avatarNewMember;
      default:
        return avatarMember;
    }
  }
}
