import 'package:flutter/material.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/services/api/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Restrictions {
  static final supabase = Supabase.instance.client;
  Future<String> getPlan(String churchName) async {
    try {
      final planMap = await supabase
          .from("Church")
          .select("Plan")
          .eq("ChurchName", churchName)
          .single();

      final plan = planMap["Plan"];

      //supabase
      return plan;
    } catch (error) {
      print("get plan error : $error");

      return "";
    }
  }

  static Future<String> getExpiryDate(String churchName) async {
    try {
      final expireMap = await supabase
          .from("Church")
          .select("Expire")
          .eq("ChurchName", churchName)
          .single();

      final expire = expireMap["Expire"];
      return expire;
    } catch (error) {
      print("get expiry error : $error");
      return "";
    }
  }

  static bool isExpired(String expiryDate) {
    //expiryDate is in the 2024-08-01 format

    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    DateTime expiry = DateTime.parse(expiryDate);

//return true or false;
    return expiry.isBefore(date);
  }

  static int switchToUserNumber(String plan) {
    int number = 0;

    switch (plan) {
      case "Basic":
        number = 10;
        break;
      case "Advanced":
        number = 60;
        break;
      case "Premium":
        number = 200;
        break;
      case "Gold":
        number = 500;
        break;
      case "Special":
        number = 150;
        break;
      default:
        print("Plan not found");
        number = 0;
    }

    return number;
  }

  static bool canAddUser(int planLimit, int userNumber) {
    if (userNumber < planLimit) {
      return true;
    } else {
      return false;
    }
  }

  static Future<int> countChurchUsers(String uniqueChurchId) async {
    try {

      final int? userNumber = await UserService.countChurchUsers(uniqueChurchId);

      return userNumber!;
    } catch (error) {
      return 0;
    }
  }

  static Future<bool> userExistInChurch(String number, String uniqueChurchId) async {
    try {
      final answer = await UserService.userExist(number, uniqueChurchId);

      if (answer != null) {
        return true;
      }

      return false;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> restrictionAlgorithm({
    required String number,
    required ChurchItemModel selectedChurch,
  }) async {
    print('restrictionAlgorithm $number  and For ${selectedChurch.plan}');
    var canAdd = false;

    try {
      final answer = await userExistInChurch(number, selectedChurch.uniqueId!);
print(answer);
      if (answer == false) {

        final maxLimit = switchToUserNumber(selectedChurch.plan!);
print(maxLimit);
        final userNumber = await countChurchUsers(selectedChurch.uniqueId!);
print(userNumber);
        final canAdd = canAddUser(maxLimit, userNumber);
print(canAdd);
        return canAdd;
      } else {
        canAdd = true;
print(canAdd);
        return canAdd;
      }
    } catch (error) {
      return canAdd;
    }
  }
}
