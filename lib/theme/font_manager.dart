import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One font option for the Connect App typography system.
class ConnectFontData {
  final String id;
  final String name;
  final String emoji;
  final String tagline;

  const ConnectFontData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tagline,
  });
}

/// The four built-in Connect App font options.
abstract class ConnectFonts {
  static const ConnectFontData inter = ConnectFontData(
    id: 'inter',
    name: 'Inter',
    emoji: '🔤',
    tagline: 'Clean & modern',
  );
  static const ConnectFontData poppins = ConnectFontData(
    id: 'poppins',
    name: 'Poppins',
    emoji: '✨',
    tagline: 'Friendly & rounded',
  );
  static const ConnectFontData dmSans = ConnectFontData(
    id: 'dm_sans',
    name: 'DM Sans',
    emoji: '📐',
    tagline: 'Minimal & editorial',
  );
  static const ConnectFontData nunito = ConnectFontData(
    id: 'nunito',
    name: 'Nunito',
    emoji: '🌸',
    tagline: 'Soft & approachable',
  );

  static const List<ConnectFontData> all = [inter, poppins, dmSans, nunito];

  static String familyFor(String id) {
    switch (id) {
      case 'poppins': return 'Poppins';
      case 'dm_sans': return 'DM Sans';
      case 'nunito':  return 'Nunito';
      default:        return 'Inter';
    }
  }
}

/// Manages the active Connect App font and persists the choice to
/// SharedPreferences so it survives logout and app restart.
///
/// Mirrors the ThemeManager singleton pattern so AppTypography static
/// getters can read the active font without a BuildContext.
class FontManager extends ChangeNotifier {
  static const _kPrefKey = 'connect_font_id';

  // ── Singleton ─────────────────────────────────────────────────────────────
  static FontManager _singleton = FontManager._();
  static FontManager get instance => _singleton;
  factory FontManager() => _singleton;
  FontManager._() : _current = ConnectFonts.inter;

  // ── State ─────────────────────────────────────────────────────────────────
  ConnectFontData _current;

  ConnectFontData get font => _current;
  String get fontFamily => ConnectFonts.familyFor(_current.id);

  // ── Build helpers (used by AppTypography and AppTheme) ───────────────────
  /// Returns a TextStyle using the active font.
  TextStyle textStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
      );

  /// Returns a full TextTheme using the active font applied to [base].
  TextTheme textTheme(TextTheme base) {
    switch (_current.id) {
      case 'poppins': return GoogleFonts.poppinsTextTheme(base);
      case 'dm_sans': return GoogleFonts.dmSansTextTheme(base);
      case 'nunito':  return GoogleFonts.nunitoTextTheme(base);
      default:        return GoogleFonts.interTextTheme(base);
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────
  /// Call once at app startup before runApp.
  Future<void> loadFont() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_kPrefKey);
      if (savedId != null) {
        final found = ConnectFonts.all.where((f) => f.id == savedId);
        if (found.isNotEmpty) {
          _current = found.first;
          _singleton = this;
          notifyListeners();
        }
      }
    } catch (_) {
      // SharedPreferences unavailable (e.g. test env) — stay on default.
    }
  }

  /// Switches to [font] and persists the choice.
  Future<void> setFont(ConnectFontData font) async {
    if (_current.id == font.id) return;
    _current = font;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, font.id);
    } catch (_) {}
  }
}
