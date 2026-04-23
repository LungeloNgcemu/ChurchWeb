import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Animation option descriptor ───────────────────────────────────────────────
class ConnectAnimationData {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const ConnectAnimationData({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

// ── Built-in animation catalogue ──────────────────────────────────────────────
abstract class ConnectAnimations {
  static const ConnectAnimationData expandRipple = ConnectAnimationData(
    id: 'expand_ripple',
    name: 'Expand Ripple',
    description: 'Rings grow outward and fade',
    emoji: '🔵',
  );
  static const ConnectAnimationData dualSpin = ConnectAnimationData(
    id: 'dual_spin',
    name: 'Dual Spin',
    description: 'Two arcs spinning in opposite directions',
    emoji: '🔄',
  );
  static const ConnectAnimationData cometTrail = ConnectAnimationData(
    id: 'comet_trail',
    name: 'Comet Trail',
    description: 'Sweeping arcs at different speeds',
    emoji: '☄️',
  );
  static const ConnectAnimationData ripplePulse = ConnectAnimationData(
    id: 'ripple_pulse',
    name: 'Ripple Pulse',
    description: 'Rings pulse in soft sequence',
    emoji: '🌊',
  );

  static const List<ConnectAnimationData> all = [
    expandRipple,
    dualSpin,
    cometTrail,
    ripplePulse,
  ];
}

// ── LoadingManager — mirrors the ThemeManager singleton pattern ───────────────
/// Persists the user's chosen loading animation across sessions.
///
/// Usage:
///   final lm = context.watch<LoadingManager>();
///   lm.animation  // current ConnectAnimationData
///   lm.setAnimation(ConnectAnimations.dualSpin)
///
/// Registered in main.dart MultiProvider alongside ThemeManager and FontManager.
class LoadingManager extends ChangeNotifier {
  static const _kPrefKey = 'connect_animation_id';

  // ── Singleton ─────────────────────────────────────────────────────────────
  static LoadingManager _singleton = LoadingManager._();
  static LoadingManager get instance => _singleton;
  factory LoadingManager() => _singleton;

  LoadingManager._() : _current = ConnectAnimations.expandRipple;

  // ── State ─────────────────────────────────────────────────────────────────
  ConnectAnimationData _current;

  ConnectAnimationData get animation => _current;

  // ── Persistence ───────────────────────────────────────────────────────────
  /// Call once at app startup (before runApp).
  Future<void> loadAnimation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_kPrefKey);
      if (savedId != null) {
        final found = ConnectAnimations.all.where((a) => a.id == savedId);
        if (found.isNotEmpty) {
          _current = found.first;
          _singleton = this;
          notifyListeners();
        }
      }
    } catch (_) {
      // SharedPreferences unavailable (test env) — stay on default.
    }
  }

  /// Switches to [animation] and saves the choice to SharedPreferences.
  Future<void> setAnimation(ConnectAnimationData animation) async {
    if (_current.id == animation.id) return;
    _current = animation;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, animation.id);
    } catch (_) {}
  }
}
