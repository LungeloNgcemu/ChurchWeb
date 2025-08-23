class ExistingUser {
  String? userId;
  String? role;
  String? phoneNumber;
  String? uniqueChurchId;

  ExistingUser({this.userId, this.role, this.phoneNumber, this.uniqueChurchId});

  factory ExistingUser.fromJson(Map<String, dynamic> json) {
    return ExistingUser(
      userId: json['UserId'],
      role: json['Role'],
      phoneNumber: json['PhoneNumber'],
      uniqueChurchId: json['UniqueChurchId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Role': role,
      'PhoneNumber': phoneNumber,
      'UniqueChurchId': uniqueChurchId,
    };
  }
}
