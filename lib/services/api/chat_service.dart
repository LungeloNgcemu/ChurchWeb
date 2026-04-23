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

  /// Fetch paginated message history.
  /// Page 1 = newest [limit] messages, page 2 = next [limit] older ones, etc.
  /// Messages are returned oldest-first so they can be prepended to the list.
  static Future<Map<String, dynamic>> fetchMessages({
    required String uniqueId,
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse(
      '${BaseUrl.baseUrl}/api/chat/messages/$uniqueId?page=$page&limit=$limit',
    );
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch messages: ${response.statusCode}');
    }
  }
}
