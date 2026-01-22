class ExistingUser {
  String? userId;
  String? role;
  String? phoneNumber;
  String? uniqueChurchId;
  String? churchName;

  ExistingUser({this.userId, this.role, this.phoneNumber, this.uniqueChurchId, this.churchName});

  factory ExistingUser.fromJson(Map<String, dynamic> json) {
    return ExistingUser(
      userId: json['UserId'],
      role: json['Role'],
      phoneNumber: json['PhoneNumber'],
      uniqueChurchId: json['UniqueChurchId'],
      churchName: json['ChurchName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Role': role,
      'PhoneNumber': phoneNumber,
      'UniqueChurchId': uniqueChurchId,
      'ChurchName': churchName,
    };
  }
}
