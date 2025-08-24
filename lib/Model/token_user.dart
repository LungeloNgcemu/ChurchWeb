class TokenUser {
  String? userId;
  String? userName;
  String? phoneNumber;
  String? role;
  String? church;
  String? uniqueChurchId;
  int? iat;
  int? exp;

  TokenUser({
    this.userId,
    this.userName,
    this.phoneNumber,
    this.role,
    this.church,
    this.uniqueChurchId,
    this.iat,
    this.exp,
  });

  factory TokenUser.fromJson(Map<String, dynamic> json) {
    return TokenUser(
      userId: json['userId'],
      userName: json['userName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      church: json['church'],
      uniqueChurchId: json['uniqueChurchId'],
      iat: json['iat'],
      exp: json['exp'],
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
      'iat': iat,
      'exp': exp,
    };
  }
}
