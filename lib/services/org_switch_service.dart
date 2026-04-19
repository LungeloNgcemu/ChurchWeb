import 'package:master/classes/sql_database.dart';
import 'package:master/services/api/auth_service.dart';

/// Handles switching the user's active organisation.
///
/// Usage:
///   final ok = await OrgSwitchService.switchTo(uniqueChurchId: id);
///
/// On success the caller is responsible for navigating to RoutePaths.church
/// (with pushNamedAndRemoveUntil) so every screen rebuilds with the new JWT.
class OrgSwitchService {
  /// Calls the switchOrg endpoint and persists the new JWT.
  ///
  /// Returns `true` on success, `false` on any failure.
  /// Does NOT touch the socket or provider — the caller navigates to /church
  /// which causes ChurchScreen + HomeScreen to reinitialise from scratch.
  static Future<bool> switchTo({
    required String uniqueChurchId,
  }) async {
    try {
      // ── 1. Current token for Authorization header ─────────────────────────
      final currentToken = await SqlDatabase.getToken();
      if (currentToken.isEmpty) return false;

      // ── 2. Call the backend ───────────────────────────────────────────────
      final result = await AuthService.switchOrg(
        uniqueChurchId: uniqueChurchId,
        bearerToken: currentToken,
      );

      if (result == null || result['success'] != true) return false;

      final newToken = result['token'] as String?;
      if (newToken == null || newToken.isEmpty) return false;

      // ── 3. Persist the new JWT — everything else reloads via navigation ───
      await SqlDatabase.insertToken(token: newToken);

      return true;
    } catch (_) {
      return false;
    }
  }
}
