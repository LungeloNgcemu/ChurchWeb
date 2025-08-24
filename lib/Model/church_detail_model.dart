class ChurchDetailModel {
  String? id;
  String? createdAt;
  String? churchName;
  String? logo;
  String? address;
  String? read;
  String? gpsLat;
  String? gpsLong;
  String? about;
  String? timeOpen;
  String? contactNumber;
  String? color;
  String? bucket;
  String? churchUser;
  String? email;
  String? churchUserId;
  String? profileImage;
  String? plan;
  String? payed;
  String? expire;
  String? uniqueId;

  ChurchDetailModel({
    this.id,
    this.createdAt,
    this.churchName,
    this.logo,
    this.address,
    this.read,
    this.gpsLat,
    this.gpsLong,
    this.about,
    this.timeOpen,
    this.contactNumber,
    this.color,
    this.bucket,
    this.churchUser,
    this.email,
    this.churchUserId,
    this.profileImage,
    this.plan,
    this.payed,
    this.expire,
    this.uniqueId,
  });

  factory ChurchDetailModel.fromJson(Map<String, dynamic> json) {
    return ChurchDetailModel(
      id: json['id'],
      createdAt: json['created_at'],
      churchName: json['ChurchName'],
      logo: json['Logo'],
      address: json['Address'],
      read: json['Read'],
      gpsLat: json['GpsLat'],
      gpsLong: json['GpsLong'],
      about: json['About'],
      timeOpen: json['TimeOpen'],
      contactNumber: json['ContactNumber'],
      color: json['Color'],
      bucket: json['Bucket'],
      churchUser: json['ChurchUser'],
      email: json['Email'],
      churchUserId: json['ChurchUserId'],
      profileImage: json['ProfileImage'],
      plan: json['Plan'],
      payed: json['Payed'],
      expire: json['Expire'],
      uniqueId: json['UniqueId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'ChurchName': churchName,
      'Logo': logo,
      'Address': address,
      'Read': read,
      'GpsLat': gpsLat,
      'GpsLong': gpsLong,
      'About': about,
      'TimeOpen': timeOpen,
      'ContactNumber': contactNumber,
      'Color': color,
      'Bucket': bucket,
      'ChurchUser': churchUser,
      'Email': email,
      'ChurchUserId': churchUserId,
      'ProfileImage': profileImage,
      'Plan': plan,
      'Payed': payed,
      'Expire': expire,
      'UniqueId': uniqueId,
    };
  }
}
