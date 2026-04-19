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

  static Future<bool> sendVoiceOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/auth/sendVoiceOtp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone}),
      );
      return response.statusCode == 200;
    } catch (_) {
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

  /// Switches the active organisation for the authenticated user.
  ///
  /// [bearerToken] is the current JWT stored in SharedPreferences.
  /// Returns the full response body (including a new `token`) on success,
  /// or a map with `success: false` on failure.
  static Future<Map<String, dynamic>?> switchOrg({
    required String uniqueChurchId,
    required String bearerToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/auth/switchOrg'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode({'uniqueChurchId': uniqueChurchId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        'success': false,
        'error': 'Server returned ${response.statusCode}',
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
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

  static Future<bool> registerOrginisationAndUser(
    String name,
    String email,
    String phoneNumber,
    String churchName,
    String address,
    String vision,
    String mission,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/auth/registerChurch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phoneNumber": phoneNumber,
          "churchName": churchName,
          "address": address,
          "vision": vision,
          "mission": mission,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
