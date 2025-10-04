import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master/constants/constants.dart';

class ChatService {
  static Future<void> sendMessage({
    required String message,
    required String sender,
    required String senderId,
    required String time,
    required String church,
    required String uniqueId,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/api/chat/sendMessage'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "message": message,
        "sender": sender,
        "senderId": senderId,
        "time": time,
        "church": church,
        "uniqueId": uniqueId,
      }),
    );

    if (response.statusCode == 200) {
      print("Message sent successfully: ${response.body}");
    } else {
      print(
          "Failed to send message: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<void> deleteMessage({required String id, required String uniqueId}) async {
    final response = await http.delete(
      Uri.parse('${BaseUrl.baseUrl}/api/chat/deleteMessage/$id/$uniqueId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("Message deleted successfully: ${response.body}");
    } else {
      print(
          "Failed to delete message: ${response.statusCode} - ${response.body}");
    }
  }
}
