import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Connect App — Spacing & Radius System
/// Source of truth: CLAUDE.md § 4.3 & § 4.8
/// Use these constants everywhere — never hardcode spacing values in widgets.
abstract class AppSpacing {
  // ─── Spacing Scale ─────────────────────────────────────────────────────────
  /// 4px — icon gap, tiny padding
  static const double xs = 4.0;

  /// 8px — chip gap, small padding
  static const double sm = 8.0;

  /// 12px — card inner padding (compact)
  static const double md = 12.0;

  /// 14px — card inner padding (standard)
  static const double mdPlus = 14.0;

  /// 16px — section padding, topbar horizontal padding
  static const double lg = 16.0;

  /// 18px — topbar horizontal padding (standard)
  static const double lgPlus = 18.0;

  /// 20px — card inner padding (generous), modal padding
  static const double xl = 20.0;

  /// 24px — modal inner padding, large card padding
  static const double xl2 = 24.0;

  /// 28px — bottom sheet top padding
  static const double xl3 = 28.0;

  /// 32px — bottom sheet corner radius, hero section padding
  static const double xl4 = 32.0;

  // ─── Border Radii ──────────────────────────────────────────────────────────
  /// 10px — icon containers, topbar icon buttons
  static const double radiusIcon = 10.0;

  /// 12px — active nav pill, role/category chips (small)
  static const double radiusChipSm = 12.0;

  /// 14px — input fields, small cards
  static const double radiusInput = 14.0;

  /// 16px — standard cards
  static const double radiusCard = 16.0;

  /// 18px — FAB extended, video card
  static const double radiusFabExt = 18.0;

  /// 20–22px — gradient hero cards
  static const double radiusHeroCard = 20.0;

  /// 26px — org logo badge
  static const double radiusOrgLogo = 26.0;

  /// 32px — bottom sheet top corners
  static const double radiusBottomSheet = 32.0;

  /// 44px — phone frame (mockup reference)
  static const double radiusPhoneFrame = 44.0;

  /// 50px — pill buttons, filter chips, badge counts
  static const double radiusPill = 50.0;

  // ─── Component Sizes ───────────────────────────────────────────────────────
  /// Top navigation bar height
  static const double topBarHeight = 68.0;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 72.0;

  /// Active nav tab pill — width
  static const double navPillW = 48.0;

  /// Active nav tab pill — height
  static const double navPillH = 32.0;

  /// FAB size (square)
  static const double fabSize = 52.0;

  /// FAB border radius (square FAB)
  static const double fabRadius = 16.0;

  /// Topbar icon button size
  static const double topBarIconSize = 34.0;

  // ─── Avatar Sizes ──────────────────────────────────────────────────────────
  static const double avatarXs = 22.0;
  static const double avatarSm = 38.0;
  static const double avatarMd = 46.0;
  static const double avatarLg = 72.0;
  static const double avatarXl = 88.0;

  // ─── SizedBox helpers ──────────────────────────────────────────────────────
  static const Widget gapXs = SizedBox(width: xs, height: xs);
  static const Widget gapSm = SizedBox(width: sm, height: sm);
  static const Widget gapMd = SizedBox(width: md, height: md);
  static const Widget gapLg = SizedBox(width: lg, height: lg);
  static const Widget gapXl = SizedBox(width: xl, height: xl);

  static const Widget vXs = SizedBox(height: xs);
  static const Widget vSm = SizedBox(height: sm);
  static const Widget vMd = SizedBox(height: md);
  static const Widget vMdPlus = SizedBox(height: mdPlus);
  static const Widget vLg = SizedBox(height: lg);
  static const Widget vLgPlus = SizedBox(height: lgPlus);
  static const Widget vXl = SizedBox(height: xl);
  static const Widget vXl2 = SizedBox(height: xl2);
  static const Widget vXl3 = SizedBox(height: xl3);

  static const Widget hXs = SizedBox(width: xs);
  static const Widget hSm = SizedBox(width: sm);
  static const Widget hMd = SizedBox(width: md);
  static const Widget hLg = SizedBox(width: lg);
  static const Widget hXl = SizedBox(width: xl);

  // ─── EdgeInsets helpers ────────────────────────────────────────────────────
  /// Standard screen horizontal padding
  static const EdgeInsets screenPaddingH =
      EdgeInsets.symmetric(horizontal: lg);

  /// Standard card inner padding
  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: mdPlus);

  /// Standard topbar padding (bottom-aligned content)
  static const EdgeInsets topBarPadding =
      EdgeInsets.only(left: lgPlus, right: lgPlus, bottom: 13);

  /// Standard modal/form section padding
  static const EdgeInsets formPadding = EdgeInsets.all(xl);

  /// Bottom fixed CTA strip padding
  static const EdgeInsets ctaStripPadding =
      EdgeInsets.fromLTRB(xl, mdPlus, xl, 28);

  // ─── BoxShadow helpers ─────────────────────────────────────────────────────
  /// Subtle card shadow (light surfaces)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];

  /// Orange button shadow
  static List<BoxShadow> get orangeButtonShadow => [
        BoxShadow(
          color: AppColors.orange.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// Primary button shadow
  static List<BoxShadow> get purpleButtonShadow => [
        BoxShadow(
          color: AppColors.purple.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// Primary FAB shadow
  static List<BoxShadow> get fabShadow => [
        BoxShadow(
          color: AppColors.purple.withValues(alpha: 0.45),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];
}
