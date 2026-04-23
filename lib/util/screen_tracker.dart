/// Tracks which screen is currently active so the notification toast
/// can be suppressed when the user is already inside that feature.
class ScreenTracker {
  static String _current = '';

  static void enter(String screen) => _current = screen;
  static void exit(String screen) {
    if (_current == screen) _current = '';
  }

  /// Returns true when the toast should NOT be shown.
  static bool isSuppressed(String notificationType) {
    if (notificationType == 'chat' && _current == 'message') return true;
    return false;
  }
}
