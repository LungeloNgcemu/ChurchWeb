import 'dart:convert';

import 'package:master/Model/churchItemModel.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/classes/sql_database.dart';

class TokenService {

  TokenService() {
    ();
  }

  static Future<Map<String, dynamic>?> decodeToken(String token) async {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        throw FormatException('Invalid token format');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  static Future<TokenUser?> tokenUser() async {
    final token = await SqlDatabase.getToken();
    final tokenData = await decodeToken(token);
    if (tokenData != null) {
      return TokenUser.fromJson(tokenData);
    }

    return null;
  }
}
