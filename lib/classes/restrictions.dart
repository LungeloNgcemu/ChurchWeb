import 'package:flutter/material.dart';
import 'package:master/componants/global_booking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Restrictions {
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

  Future<String> getExpiryDate(String churchName) async {
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

  bool isExpired(String expiryDate) {
    //expiryDate is in the 2024-08-01 format

    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    DateTime expiry = DateTime.parse(expiryDate);

//return true or false;
    return expiry.isBefore(date);
  }

  int switchToUserNumber(String plan) {
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
    }

    return number;
  }

  bool canAddUser(int planLimit, int userNumber) {
    //getChurchUserNumber
    //switchToUserNumber
    if (userNumber < planLimit) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> getChurchUserNumber(String churchName) async {
    // 1. get list and count list number
    try {
      final userList =
          await supabase.from("User").select().eq("Church", churchName);

      final int number = userList.length;

      return number;
    } catch (error) {
      print("Error getting user list number : $error");
      return 0;
    }
  }

  Future<bool> userExist(String number) async {
    var isFound = false;

    try {
      final userList =
          await supabase.from("User").select().eq("PhoneNumber", number);
      if (userList.isNotEmpty) {
        isFound = true;
      }

      return isFound;
    } catch (error) {
      return isFound;
    }
  }

  Future<bool> restrictonAlgorithm({
    num,
    selectedChurch,
  }) async {
    var canAdd = false;
    try {
      print("Number : $num");
      final answer = await userExist(num);
      print("user exist or not? : $answer");

      print("restrict 1");

      if (answer == false) {
        final plan = await getPlan(selectedChurch);
        print("plan $plan");
        print("restrict 2");
        final maxLimit = switchToUserNumber(plan);

        final userNumber = await getChurchUserNumber(selectedChurch);
        print("restrict 3");

        //if the user can be added?
        final canAdd = canAddUser(maxLimit, userNumber);

        return canAdd;
      } else {
        canAdd = true;
        return canAdd;
      }
    } catch (error) {
      //Todo dont know yet!!!!!!!!!
      print("restriction error : $error");
      return canAdd;
    }
    //
  }
}
