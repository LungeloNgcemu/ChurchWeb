class ChurchDataModel {
  final String? churchName;
  final String? logoAddress;
  final String? address;
  final String? read;
  final double? gpsLat;
  final double? gpsLong;
  final String? about;
  final String? timeOpen;
  final String? contactNumber;
  final String? color;
  final String? url;
  final String? api;
  final String? projectId;
  final String? bucket;
  final String? role;
  final String? expire;

  ChurchDataModel({
    this.churchName,
    this.logoAddress,
    this.address,
    this.read,
    this.gpsLat,
    this.gpsLong,
    this.about,
    this.timeOpen,
    this.contactNumber,
    this.color,
    this.url,
    this.api,
    this.projectId,
    this.bucket,
    this.role,
    this.expire,
  });

  factory ChurchDataModel.fromJson(Map<String, dynamic> data) {
    Map<String, dynamic> json = data['Project'];
    return ChurchDataModel(
      churchName: json['ChurchName'],
      logoAddress: json['LogoAddress'],
      address: json['Address'],
      read: json['Read'],
      gpsLat: json['GpsLat']?.toDouble(),
      gpsLong: json['GpsLong']?.toDouble(),
      about: json['About'],
      timeOpen: json['TimeOpen'],
      contactNumber: json['ContactNumber'],
      color: json['Color'],
      url: json['URL'],
      api: json['API'],
      projectId: json['ProjectId'],
      bucket: json['Bucket'],
      role: json['Role'],
      expire: json['Expire'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'ChurchName': churchName,
      'LogoAddress': logoAddress,
      'Address': address,
      'Read': read,
      'GpsLat': gpsLat,
      'GpsLong': gpsLong,
      'About': about,
      'TimeOpen': timeOpen,
      'ContactNumber': contactNumber,
      'Color': color,
      'URL': url,
      'API': api,
      'ProjectId': projectId,
      'Bucket': bucket,
      'Role': role,
      'Expire': expire,
    };
  }
}