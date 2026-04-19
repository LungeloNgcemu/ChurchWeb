/// A single organisation entry embedded in the JWT `organisations` array.
class UserOrg {
  final String uniqueChurchId;
  final String churchName;
  final String role;

  const UserOrg({
    required this.uniqueChurchId,
    required this.churchName,
    required this.role,
  });

  factory UserOrg.fromJson(Map<String, dynamic> json) {
    return UserOrg(
      uniqueChurchId: json['uniqueChurchId'] as String? ?? '',
      churchName: json['churchName'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'uniqueChurchId': uniqueChurchId,
        'churchName': churchName,
        'role': role,
      };
}
