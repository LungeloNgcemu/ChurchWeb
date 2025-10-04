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
    };
  }

  // Optional: Add copyWith method for immutability
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
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, sender: $sender, message: $message, time: $time)';
  }
}