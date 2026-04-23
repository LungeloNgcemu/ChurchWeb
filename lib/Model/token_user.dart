import 'user_org.dart';

class TokenUser {
  String? userId;
  String? userName;
  String? phoneNumber;
  String? role;
  String? church;

  /// The currently active organisation ID.
  /// Populated from `activeChurchId` (new JWTs) or `uniqueChurchId` (legacy
  /// JWTs), so all existing code using `uniqueChurchId` continues to work.
  String? uniqueChurchId;

  /// All organisations this user is a member of.
  /// Present on JWTs issued after the multi-org rollout; null on older tokens.
  List<UserOrg>? organisations;

  int? iat;
  int? exp;

  TokenUser({
    this.userId,
    this.userName,
    this.phoneNumber,
    this.role,
    this.church,
    this.uniqueChurchId,
    this.organisations,
    this.iat,
    this.exp,
  });

  factory TokenUser.fromJson(Map<String, dynamic> json) {
    // Prefer the explicit new fields; fall back to legacy field names so tokens
    // issued before the multi-org rollout still work.
    final activeId =
        (json['activeChurchId'] as String?) ?? (json['uniqueChurchId'] as String?);
    final activeName =
        (json['activeChurchName'] as String?) ?? (json['church'] as String?);

    List<UserOrg>? orgs;
    final rawOrgs = json['organisations'];
    if (rawOrgs is List && rawOrgs.isNotEmpty) {
      orgs = rawOrgs
          .map((o) => UserOrg.fromJson(Map<String, dynamic>.from(o as Map)))
          .toList();
    }

    return TokenUser(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String?,
      church: activeName,
      uniqueChurchId: activeId,
      organisations: orgs,
      iat: json['iat'] as int?,
      exp: json['exp'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'role': role,
      'church': church,
      'uniqueChurchId': uniqueChurchId,
      'organisations': organisations?.map((o) => o.toJson()).toList(),
      'iat': iat,
      'exp': exp,
    };
  }
}
