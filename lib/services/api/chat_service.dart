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
    String imageUrl = '',
    String mediaType = 'text',
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
        "imageUrl": imageUrl,
        "mediaType": mediaType,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Send failed (${response.statusCode}): ${response.body}');
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

  /// Search messages by text content for an org. Returns newest matches first.
  static Future<List<Map<String, dynamic>>> searchMessages({
    required String uniqueId,
    required String query,
  }) async {
    final uri = Uri.parse(
      '${BaseUrl.baseUrl}/api/chat/search/$uniqueId?q=${Uri.encodeQueryComponent(query)}',
    );
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(body['messages'] as List);
    }
    throw Exception('Search failed: ${response.statusCode}');
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
