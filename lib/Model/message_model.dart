class MessageModel {
  final String? id;
  final String? createdAt;
  final String? sender;
  final String? profileImage;
  final String? message;
  final String? time;
  final String? phoneNumber;
  final String? church;
  final String? uniqueChurchId;
  final String? imageUrl;
  final String? mediaType;

  MessageModel({
    this.id,
    this.createdAt,
    this.sender,
    this.profileImage,
    this.message,
    this.time,
    this.phoneNumber,
    this.church,
    this.uniqueChurchId,
    this.imageUrl,
    this.mediaType,
  });

  factory MessageModel.fromJson(Map<dynamic?, dynamic> json) {
    return MessageModel(
      id: json['id'],
      createdAt: json['created_at'],
      sender: json['Sender'],
      profileImage: json['ProfileImage'],
      message: json['Message'],
      time: json['Time'],
      phoneNumber: json['PhoneNumber'],
      church: json['Church'],
      uniqueChurchId: json['UniqueChurchId'],
      imageUrl: json['ImageUrl'],
      mediaType: json['MediaType'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'id': id ?? '',
      'created_at': createdAt ?? '',
      'Sender': sender ?? '',
      'ProfileImage': profileImage ?? '',
      'Message': message ?? '',
      'Time': time ?? '',
      'PhoneNumber': phoneNumber,
      'Church': church,
      'UniqueChurchId': uniqueChurchId,
      'ImageUrl': imageUrl ?? '',
      'MediaType': mediaType ?? 'text',
    };
  }

  MessageModel copyWith({
    String? id,
    String? createdAt,
    String? sender,
    String? chatRoomId,
    String? senderId,
    String? profileImage,
    String? status,
    String? docId,
    String? message,
    String? time,
    String? phoneNumber,
    String? church,
    String? uniqueChurchId,
    String? imageUrl,
    String? mediaType,
  }) {
    return MessageModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      profileImage: profileImage ?? this.profileImage,
      message: message ?? this.message,
      time: time ?? this.time,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      church: church ?? this.church,
      uniqueChurchId: uniqueChurchId ?? this.uniqueChurchId,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaType: mediaType ?? this.mediaType,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, sender: $sender, message: $message, time: $time)';
  }
}