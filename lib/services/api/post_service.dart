import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PostService {
  static String get _base => dotenv.env['BASEURL'] ?? '';

  static Future<bool> createPost({
    required String description,
    required String church,
    required String uniqueChurchId,
    required String userName,
    required String createdBy,
    String imageUrl = '',
    String type = 'Announcement',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': description,
          'imageUrl': imageUrl,
          'church': church,
          'type': type,
          'userName': userName,
          'uniqueChurchId': uniqueChurchId,
          'createdBy': createdBy,
        }),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
