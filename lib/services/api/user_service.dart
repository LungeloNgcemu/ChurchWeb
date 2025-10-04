import 'dart:convert';
import 'package:master/Model/existing_user_model.dart';
import 'package:master/Model/user_details_model.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/constants/constants.dart';
import 'package:http/http.dart' as http;

class UserService {
  static Future<ExistingUser?> userExist(
      String phoneNumber, String uniqueChurchId) async {
    print("User Exist $phoneNumber $uniqueChurchId");

    try {
      final response = await http.post(
          Uri.parse('${BaseUrl.baseUrl}/api/user/getExistingUser'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
              {'phoneNumber': phoneNumber, 'uniqueChurchId': uniqueChurchId}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['user'] == null) return null;

        return ExistingUser.fromJson(data['user']);
      } else {
        print("User not found");
        return null;
      }
    } catch (error) {
      print("User not found $error");
      return null;
    }
  }

  static Future<int?> countChurchUsers(String uniqueChurchId) async {
    try {
      final response = await http
          .get(Uri.parse('${BaseUrl.baseUrl}/api/user/getAllUsersCount'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['count'];
      }

      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<UserDetails?> getUserData(
      String phoneNumber, String uniqueChurchId) async {
    try {
      final response = await http.post(
          Uri.parse('${BaseUrl.baseUrl}/api/user/getUserDetails'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'phoneNumber': phoneNumber, 'uniqueChurchId': uniqueChurchId}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return UserDetails.fromJson(data);
      }

      return null;
    } catch (error) {
      return null;
    }
  }
}
