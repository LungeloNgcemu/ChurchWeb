class ChurchTokenData {
  final String churchName;
  final String? imageUrl;
  final DateTime expiry;
  final bool isExpired;
  final String? role;
  final bool isLeader;
  final String? uniqueChurchId;

  ChurchTokenData({
    required this.churchName,
    this.imageUrl,
    required this.expiry,
    bool? isExpired,
    this.role,
    bool? isLeader,
    this.uniqueChurchId,
  })  : isExpired = isExpired ?? DateTime.now().isAfter(expiry),
        isLeader = isLeader ?? (role?.toLowerCase() == 'ADMIN');

  // Convert from JSON
  factory ChurchTokenData.fromJson(Map<String, dynamic> json) {
    return ChurchTokenData(
      churchName: json['churchName'] as String,
      imageUrl: json['imageUrl'] as String?,
      expiry: json['expiry'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['expiry'] as int)
          : json['expiry'] as DateTime,
      isExpired: json['isExpired'] as bool?,
      role: json['role'] as String?,
      isLeader: json['isLeader'] as bool?,
      uniqueChurchId: json['uniqueChurchId'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'churchName': churchName,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'expiry': expiry.millisecondsSinceEpoch,
      'isExpired': isExpired,
      'role': role,
      'isLeader': isLeader,
      if (uniqueChurchId != null) 'uniqueChurchId': uniqueChurchId,
    };
  }

  // For debugging
  @override
  String toString() {
    return 'ChurchTokenData(churchName: $churchName, imageUrl: $imageUrl, expiry: $expiry, isExpired: $isExpired)';
  }

  // For equality checks
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChurchTokenData &&
        other.churchName == churchName &&
        other.imageUrl == imageUrl &&
        other.expiry == expiry &&
        other.role == role &&
        other.isExpired == isExpired &&
        other.isLeader == isLeader &&
        other.uniqueChurchId == uniqueChurchId;
  }

  @override
  int get hashCode {
    return churchName.hashCode ^
        (imageUrl?.hashCode ?? 0) ^
        expiry.hashCode ^
        isExpired.hashCode ^
        (role?.hashCode ?? 0) ^
        isLeader.hashCode ^
        (uniqueChurchId?.hashCode ?? 0);
  }
}
