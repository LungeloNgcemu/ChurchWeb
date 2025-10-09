class ChurchDataModel {
  final dynamic? churchName;
  final dynamic? logoAddress;
  final dynamic? address;
  final dynamic? read;
  final dynamic? gpsLat;
  final dynamic? gpsLong;
  final dynamic? about;
  final dynamic? timeOpen;
  final dynamic? contactNumber;
  final dynamic? color;
  final dynamic? url;
  final dynamic? api;
  final dynamic? projectId;
  final dynamic? bucket;
  final dynamic? role;
  final dynamic? expire;

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
      gpsLat: double.tryParse(json['GpsLat']?.toString() ?? ''),
      gpsLong: double.tryParse(json['GpsLong']?.toString() ?? ''),
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
