import 'package:master/classes/sql_database.dart';
import 'package:master/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static Future<bool> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/api/auth/liveSendUnixOtp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phone}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> verifyOtp(
      String phoneNumber,
      String secret,
      String userName,
      String gender,
      String selectedChurch,
      String role,
      String uniqueChurchId) async {
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/api/auth/liveVerifyUnixOtp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'secret': secret,
        'userName': userName,
        'gender': gender,
        'selectedChurch': selectedChurch,
        'role': role,
        'uniqueChurchId': uniqueChurchId
      }),
    );
    if (response.statusCode == 200) {
      print(response.body);
      String token = json.decode(response.body)['token'];

      SqlDatabase.insertToken(token: token);
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkPassword(
      String password, String uniqueChurchId) async {
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/api/auth/checkPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password, 'uniqueId': uniqueChurchId}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> registerUser(
      {required String name,
      required String phone,
      required String uniqueChurchId,
      required String role}) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/auth/registerUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'uniqueChurchId': uniqueChurchId,
          'role': role
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }



  static Future<Map<String, dynamic>?> generateInvitationToken({
    required String uniqueChurchId,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/auth/invitationToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uniqueChurchId': uniqueChurchId,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'token': responseData['token'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to generate invitation token',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
