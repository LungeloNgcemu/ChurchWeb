class RegistrationModel {
  String? phoneNumber;
  String? userName;
  String? role;
  String? gender;
  String? uniqueChurchId;
  String? password;

  RegistrationModel({
    this.phoneNumber,
    this.userName,
    this.role,
    this.gender,
    this.uniqueChurchId,
    this.password,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      phoneNumber: json['PhoneNumber'],
      userName: json['UserName'],
      role: json['Role'],
      gender: json['Gender'],
      uniqueChurchId: json['UniqueChurchId'],
      password: json['Password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PhoneNumber': phoneNumber,
      'UserName': userName,
      'Role': role,
      'Gender': gender,
      'UniqueChurchId': uniqueChurchId,
      'Password': password,
    };
  }

  RegistrationModel copyWith({
    String? phoneNumber,
    String? userName,
    String? role,
    String? gender,
    String? uniqueChurchId,
    String? password,
  }) {
    return RegistrationModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      uniqueChurchId: uniqueChurchId ?? this.uniqueChurchId,
      password: password ?? this.password,
    );
  }
}
