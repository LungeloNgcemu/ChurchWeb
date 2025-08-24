import 'package:master/Model/token_user.dart';
import 'package:master/Model/user_details_model.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/services/api/user_service.dart';

class UserDetailsService {
  static Future<UserDetails?> getUserDetailsData() async {
    try {
      TokenUser? tokenUser = await TokenService.tokenUser();

      if (tokenUser == null) {
        throw Exception('User not authenticated');
      }

      UserDetails? userDetails = await UserService.getUserData(
          tokenUser.phoneNumber!, tokenUser.uniqueChurchId!);

      if (userDetails == null) {
        throw Exception('User details not found');
      }

      return userDetails;
    } catch (e) {
      return null;
    }
  }
}
