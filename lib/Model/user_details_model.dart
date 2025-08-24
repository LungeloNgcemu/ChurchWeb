class UserDetails {
  String? id;
  String? createdAt;
  String? userName;
  String? userId;
  List<dynamic>? singleChatId;
  String? profileImage;
  String? phoneNumber;
  String? idPrimaryKey;
  String? role;
  String? gender;
  String? church;
  String? uniqueChurchId;

  UserDetails({
    this.id,
    this.createdAt,
    this.userName,
    this.userId,
    this.singleChatId,
    this.profileImage,
    this.phoneNumber,
    this.idPrimaryKey,
    this.role,
    this.gender,
    this.church,
    this.uniqueChurchId,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      createdAt: json['created_at'],
      userName: json['UserName'],
      userId: json['UserId'],
      singleChatId: json['SingleChatId'] != null
          ? List<dynamic>.from(json['SingleChatId'])
          : null,
      profileImage: json['ProfileImage'],
      phoneNumber: json['PhoneNumber'],
      idPrimaryKey: json['id PRIMARY KEY'],
      role: json['Role'],
      gender: json['Gender'],
      church: json['Church'],
      uniqueChurchId: json['UniqueChurchId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'UserName': userName,
      'UserId': userId,
      'SingleChatId': singleChatId,
      'ProfileImage': profileImage,
      'PhoneNumber': phoneNumber,
      'id PRIMARY KEY': idPrimaryKey,
      'Role': role,
      'Gender': gender,
      'Church': church,
      'UniqueChurchId': uniqueChurchId,
    };
  }
}
