import 'package:flutter/material.dart';

/// One complete set of color tokens for a Connect App visual theme.
///
/// Five predefined themes live in [ConnectThemes].
/// All tokens are derived from 5 base values:
///   background, primary, accent, card, text.
class ConnectThemeData {
  final String id;
  final String name;
  final String emoji;
  final bool isDark;

  // ── Core surfaces ──────────────────────────────────────────────────────────
  /// Main scaffold / page background.
  final Color background;

  /// Dividers, inactive input borders, muted backgrounds.
  final Color backgroundAlt;

  /// Deepest background (behind phone frames / hero sections).
  final Color backgroundDeep;

  /// Default card / panel surface.
  final Color card;

  /// Elevated card on dark surfaces.
  final Color cardElevated;

  // ── Top / navigation bar (intentionally kept dark across all themes) ───────
  final Color topBar;
  final Color topBarElevated;

  // ── Primary accent (purple → blue → cyan → coral → emerald) ───────────────
  final Color primary;
  final Color primaryLight;
  final Color primaryTint;
  final Color primaryBorder;
  final Color primaryBadge;

  // ── Secondary accent (orange → lime → gold) ───────────────────────────────
  final Color accent;
  final Color accentDeep;
  final Color accentTint;

  // ── Text ──────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color textMid;

  const ConnectThemeData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isDark,
    required this.background,
    required this.backgroundAlt,
    required this.backgroundDeep,
    required this.card,
    required this.cardElevated,
    required this.topBar,
    required this.topBarElevated,
    required this.primary,
    required this.primaryLight,
    required this.primaryTint,
    required this.primaryBorder,
    required this.primaryBadge,
    required this.accent,
    required this.accentDeep,
    required this.accentTint,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textMid,
  });

  // ── Fixed colours (never change with theme) ────────────────────────────────
  static const Color white   = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF22C55E);
  static const Color error   = Color(0xFFDC2626);
  static const Color blueAccent     = Color(0xFF2563EB);
  static const Color blueAccentDeep = Color(0xFF1D4ED8);
  static const Color blueAccentTint = Color(0xFFEFF6FF);

  // ── Derived transparent overlays ──────────────────────────────────────────
  Color get whiteDim   => Colors.white.withOpacity(0.45);
  Color get whiteFaint => Colors.white.withOpacity(0.10);
  Color get navyIconBg => Colors.white.withOpacity(0.08);

  // ── Standard gradients ────────────────────────────────────────────────────
  LinearGradient get primaryHeaderGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: const GradientRotation(160 * 3.14159 / 180),
    colors: [topBar, primaryLight, primary],
    stops: const [0.0, 0.6, 1.0],
  );

  LinearGradient get primaryCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  LinearGradient get accentGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDeep],
  );

  LinearGradient get darkSplitGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: const GradientRotation(160 * 3.14159 / 180),
    colors: [topBar, topBarElevated],
  );

  // ── Avatar gradients (role-based, not themed) ──────────────────────────────
  static const LinearGradient avatarLeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  );
  static const LinearGradient avatarCoordinator = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
  );
  static const LinearGradient avatarMedia = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
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

  static LinearGradient avatarGradientForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'leader':       return avatarLeader;
      case 'coordinator':
      case 'coord':        return avatarCoordinator;
      case 'media':        return avatarMedia;
      case 'new':          return avatarNewMember;
      default:             return avatarMember;
    }
  }

  // ── Build a Flutter ThemeData from this token set ─────────────────────────
  ThemeData toMaterialTheme() {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      useMaterial3: false,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: white,
        secondary: accent,
        onSecondary: white,
        tertiary: primaryLight,
        onTertiary: white,
        error: error,
        onError: white,
        surface: card,
        onSurface: textPrimary,
        // ignore: deprecated_member_use
        background: background,
        // ignore: deprecated_member_use
        onBackground: textPrimary,
      ),
      cardColor: card,
      dividerColor: backgroundAlt,
      iconTheme: IconThemeData(color: textMid),
      appBarTheme: AppBarTheme(
        backgroundColor: topBar,
        foregroundColor: white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: backgroundAlt, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: backgroundAlt, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: TextStyle(color: textMuted),
        labelStyle: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? white : white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : backgroundAlt,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// The five built-in Connect App themes.
// ─────────────────────────────────────────────────────────────────────────────
abstract class ConnectThemes {
  // ── 1. Midnight (dark navy — default v2 design) ───────────────────────────
  static const ConnectThemeData midnight = ConnectThemeData(
    id: 'midnight',
    name: 'Midnight',
    emoji: '🌙',
    isDark: true,
    background:     Color(0xFF0F172A),  // dark navy
    backgroundAlt:  Color(0xFF182340),  // slightly lighter dark
    backgroundDeep: Color(0xFF070D17),  // deepest
    card:           Color(0xFF1E293B),  // navy card (user-specified)
    cardElevated:   Color(0xFF252F45),  // elevated dark card
    topBar:         Color(0xFF1E293B),  // same as card (flat look)
    topBarElevated: Color(0xFF252F45),
    primary:        Color(0xFF7C3AED),
    primaryLight:   Color(0xFF4F46E5),
    primaryTint:    Color(0xFF1E1A3E),  // dark purple tint (was light #F5F3FF)
    primaryBorder:  Color(0xFF3D2E7A),  // dark purple border
    primaryBadge:   Color(0xFF2A1F5E),  // dark purple badge
    accent:         Color(0xFFF97316),
    accentDeep:     Color(0xFFEA580C),
    accentTint:     Color(0xFF2A1800),  // dark orange tint (was light #FFF7ED)
    textPrimary:    Color(0xFFFFFFFF),  // white text (was dark #1C1917)
    textSecondary:  Color(0xFFB0BDCF),  // light blue-grey
    textMuted:      Color(0xFF64748B),
    textDisabled:   Color(0xFF334155),
    textMid:        Color(0xFF94A3B8),
  );

  // ── 2. Cloud (light blue) ─────────────────────────────────────────────────
  static const ConnectThemeData cloud = ConnectThemeData(
    id: 'cloud',
    name: 'Cloud',
    emoji: '☁️',
    isDark: false,
    background:     Color(0xFFFFFFFF),
    backgroundAlt:  Color(0xFFE8EDF3),
    backgroundDeep: Color(0xFFF0F4F8),
    card:           Color(0xFFF1F5F9),
    cardElevated:   Color(0xFFE2E8F0),
    topBar:         Color(0xFF1E3A5F),
    topBarElevated: Color(0xFF243B55),
    primary:        Color(0xFF2563EB),
    primaryLight:   Color(0xFF3B82F6),
    primaryTint:    Color(0xFFEFF6FF),
    primaryBorder:  Color(0xFFBFDBFE),
    primaryBadge:   Color(0xFFDBEAFE),
    accent:         Color(0xFFF97316),
    accentDeep:     Color(0xFFEA580C),
    accentTint:     Color(0xFFFFF7ED),
    textPrimary:    Color(0xFF1C1917),
    textSecondary:  Color(0xFF475569),
    textMuted:      Color(0xFF94A3B8),
    textDisabled:   Color(0xFFCBD5E1),
    textMid:        Color(0xFF64748B),
  );

  // ── 3. Ocean (deep blue) ──────────────────────────────────────────────────
  static const ConnectThemeData ocean = ConnectThemeData(
    id: 'ocean',
    name: 'Ocean',
    emoji: '🌊',
    isDark: true,
    background:     Color(0xFF0C1A2E),
    backgroundAlt:  Color(0xFF122033),
    backgroundDeep: Color(0xFF070F1C),
    card:           Color(0xFF112240),
    cardElevated:   Color(0xFF1A3A5C),
    topBar:         Color(0xFF0A1628),
    topBarElevated: Color(0xFF112240),
    primary:        Color(0xFF06B6D4),
    primaryLight:   Color(0xFF22D3EE),
    primaryTint:    Color(0xFF0E3548),
    primaryBorder:  Color(0xFF164E63),
    primaryBadge:   Color(0xFF0E4058),
    accent:         Color(0xFF84CC16),
    accentDeep:     Color(0xFF65A30D),
    accentTint:     Color(0xFF1A2E0A),
    textPrimary:    Color(0xFFFFFFFF),
    textSecondary:  Color(0xFFB0C4DE),
    textMuted:      Color(0xFF6B8CAE),
    textDisabled:   Color(0xFF3A5A7A),
    textMid:        Color(0xFF8AA8C4),
  );

  // ── 4. Sunset (warm light) ────────────────────────────────────────────────
  static const ConnectThemeData sunset = ConnectThemeData(
    id: 'sunset',
    name: 'Sunset',
    emoji: '🌅',
    isDark: false,
    background:     Color(0xFFFFFBF5),
    backgroundAlt:  Color(0xFFFEF3E2),
    backgroundDeep: Color(0xFFFFF8EE),
    card:           Color(0xFFFFFFFF),
    cardElevated:   Color(0xFFFEF9F0),
    topBar:         Color(0xFF7C2D12),
    topBarElevated: Color(0xFF9A3412),
    primary:        Color(0xFFF97316),
    primaryLight:   Color(0xFFFB923C),
    primaryTint:    Color(0xFFFFF7ED),
    primaryBorder:  Color(0xFFFED7AA),
    primaryBadge:   Color(0xFFFFEDD5),
    accent:         Color(0xFF7C3AED),
    accentDeep:     Color(0xFF6D28D9),
    accentTint:     Color(0xFFF5F3FF),
    textPrimary:    Color(0xFF1C1917),
    textSecondary:  Color(0xFF57534E),
    textMuted:      Color(0xFFA8A29E),
    textDisabled:   Color(0xFFD6D3D1),
    textMid:        Color(0xFF78716C),
  );

  // ── 5. Forest (dark green) ────────────────────────────────────────────────
  static const ConnectThemeData forest = ConnectThemeData(
    id: 'forest',
    name: 'Forest',
    emoji: '🌲',
    isDark: true,
    background:     Color(0xFF0D1F16),
    backgroundAlt:  Color(0xFF132A1E),
    backgroundDeep: Color(0xFF071210),
    card:           Color(0xFF132A1E),
    cardElevated:   Color(0xFF1A3828),
    topBar:         Color(0xFF0A1A10),
    topBarElevated: Color(0xFF132A1E),
    primary:        Color(0xFF10B981),
    primaryLight:   Color(0xFF34D399),
    primaryTint:    Color(0xFF0A2018),
    primaryBorder:  Color(0xFF065F46),
    primaryBadge:   Color(0xFF0D2E1E),
    accent:         Color(0xFFF59E0B),
    accentDeep:     Color(0xFFD97706),
    accentTint:     Color(0xFF1F1500),
    textPrimary:    Color(0xFFFFFFFF),
    textSecondary:  Color(0xFF9DC4AC),
    textMuted:      Color(0xFF5A8C6E),
    textDisabled:   Color(0xFF2D5C3F),
    textMid:        Color(0xFF7AAF8A),
  );

  /// All five themes in display order.
  static const List<ConnectThemeData> all = [
    midnight,
    cloud,
    ocean,
    sunset,
    forest,
  ];
}
