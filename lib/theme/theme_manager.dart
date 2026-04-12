import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connect_theme_data.dart';

/// Manages the active Connect App theme and persists the choice to
/// SharedPreferences so it survives logout and app restart.
///
/// Usage:
///   // Read current theme
///   final tm = context.watch<ThemeManager>();
///   Color bg = tm.colors.background;
///
///   // Change theme
///   context.read<ThemeManager>().setTheme(ConnectThemes.ocean);
///
/// Registered as a ChangeNotifierProvider in main.dart so any
/// Consumer<ThemeManager> (or context.watch) rebuilds on change.
class ThemeManager extends ChangeNotifier {
  static const _kPrefKey = 'connect_theme_id';

  // ── Singleton for AppColors static-getter delegation ──────────────────────
  // We keep a static reference so AppColors.xxx getters (which run outside a
  // BuildContext) can still resolve the active theme.
  static ThemeManager _singleton = ThemeManager._();
  static ThemeManager get instance => _singleton;

  ThemeManager._() : _current = ConnectThemes.cloud;

  // ── Factory used by the ChangeNotifierProvider in main.dart ───────────────
  /// Creates the singleton-linked instance that Provider will own.
  factory ThemeManager() {
    return _singleton;
  }

  // ── State ─────────────────────────────────────────────────────────────────
  ConnectThemeData _current;

  /// The currently active theme token set.
  ConnectThemeData get colors => _current;

  /// The Flutter ThemeData derived from the active theme.
  ThemeData get materialTheme => _current.toMaterialTheme();

  // ── Persistence ───────────────────────────────────────────────────────────
  /// Call once at app startup (before runApp or inside main()).
  /// Reads the saved theme id from SharedPreferences and applies it.
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_kPrefKey);
      if (savedId != null) {
        final found = ConnectThemes.all.where((t) => t.id == savedId);
        if (found.isNotEmpty) {
          _current = found.first;
        } else {
          // Saved theme no longer exists (e.g. Midnight/Ocean/Forest removed)
          // — fall back to Cloud and persist the new default.
          _current = ConnectThemes.cloud;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_kPrefKey, ConnectThemes.cloud.id);
          // Update the singleton colours immediately so AppColors.xxx
          // returns the correct values before the first frame.
          _singleton = this;
          notifyListeners();
        }
      }
    } catch (_) {
      // SharedPreferences not available (e.g. test env) — stay on default.
    }
  }

  /// Switches to [theme] and saves the choice to SharedPreferences.
  Future<void> setTheme(ConnectThemeData theme) async {
    if (_current.id == theme.id) return;
    _current = theme;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, theme.id);
    } catch (_) {
      // Silently ignore write failures.
    }
  }
}
