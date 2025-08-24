class ChurchItemModel {
  String? churchName;
  String? uniqueId;
  String? plan;
  String? expire;
  String? logo;
  String? address;
  String? read;
  String? gpsLat;
  String? gpsLong;
  String? about;
  String? timeOpen;
  dynamic? contactNumber;
  String? bucket;

  ChurchItemModel(
      {this.churchName,
      this.uniqueId,
      this.plan,
      this.expire,
      this.logo,
      this.address,
      this.read,
      this.gpsLat,
      this.gpsLong,
      this.about,
      this.timeOpen,
      this.contactNumber,
      this.bucket});

  factory ChurchItemModel.fromJson(Map<String, dynamic> json) {
    return ChurchItemModel(
      churchName: json['ChurchName'],
      uniqueId: json['UniqueId'],
      plan: json['Plan'],
      expire: json['Expire'],
      logo: json['LogoAddress'],
      address: json['Address'],
      read: json['Read'],
      gpsLat: json['GpsLat'],
      gpsLong: json['GpsLong'],
      about: json['About'],
      timeOpen: json['TimeOpen'],
      contactNumber: json['ContactNumber'],
      bucket: json['Bucket'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ChurchName': churchName,
      'UniqueId': uniqueId,
      'Plan': plan,
      'Expire': expire,
      'Logo': logo,
      'Address': address,
      'Read': read,
      'GpsLat': gpsLat,
      'GpsLong': gpsLong,
      'About': about,
      'TimeOpen': timeOpen,
      'ContactNumber': contactNumber,
      'Bucket': bucket,
    };
  }
}
