import 'package:flutter/cupertino.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/Model/church_data_model.dart';
import 'package:master/Model/church_detail_model.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/restrictions.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/constants/constants.dart';
import 'package:master/services/api/general_data_service.dart';
import 'package:master/services/api/token_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../componants/global_booking.dart';
import '../databases/database.dart';
import '../providers/url_provider.dart';
import 'message_class.dart';

class ChurchInit {
  static String? churchName = "";
  static String? logo = "";
  static String? address = "";
  static String? read = "";
  static String? gpsLat = "";
  static String? gpsLong = "";
  static String? about = "";
  static String? timeOpen = "";
  static String? bucket = "";
  static String? contactNumber = "";
  static String? role = "";

  static Map<String, Map<String, dynamic>> projects = {};

  SqlDatabase sql = SqlDatabase();
  Restrictions restrict = Restrictions();

  static bool invert(bool value) {
    return !value;
  }

  static Future<bool> expiryExpire(String? uniqueId) async {
    try {
      final exp = await Restrictions.getExpiryDate(uniqueId);

      if (exp == 'none') {
        return true;
      }

      final answer = Restrictions.isExpired(exp);
      print('unique 4');

      return invert(answer);
    } catch (error) {
      print("Expire Expire ERROR");
      return false;
    }
  }

  static bool visibilityToggle(BuildContext context) {
    final status = Provider.of<christProvider>(context, listen: false)
        .myMap['Project']?['Role'];

    bool isAdmin = status == "Admin";

    return isAdmin;
  }

  Future<Map<String, dynamic>> getCurrentUser(BuildContext context) async {
    TokenUser? user = await TokenService.tokenUser();

    try {
      Map<String, dynamic> userData = {
        "UserName": user?.userName,
        "UserId": user?.userId,
        "PhoneNumber": user?.phoneNumber,
      };

      return userData;
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<ChurchDetailModel?> getChurch(String uniqueId) async {
    try {
      return await GeneralDataService.getChurchData(uniqueId);
    } catch (error) {
      print('Error fetching church data: $error');
      return null;
    }
  }

  static Future<void> updateProjects(BuildContext context, projects) async {
    context.read<christProvider>().updatemyMap(newValue: projects);
  }

  static Future<void> init(BuildContext context) async {
    TokenUser? tokenUser = await TokenService.tokenUser();

    if (tokenUser == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutePaths.church,
        (Route<dynamic> route) => false,
      );
      return;
    }

    try {
      ChurchItemModel? churchItemModel =
          await GeneralDataService.getChurchItemModelByUniqueId(
              tokenUser.uniqueChurchId!);

      if (churchItemModel != null) {
        await SqlDatabase.updateChurchItem(uniqueId: tokenUser.uniqueChurchId!);
      }
    } catch (error) {
      print(error);
    }

    ChurchItemModel? churchData = await SqlDatabase.getChurchItem();
    bool expire = await expiryExpire(churchData!.uniqueId);

    if (churchData == null) {
      return;
    }

    churchName = churchData.churchName ?? "";
    logo = churchData.logo ?? "";
    address = churchData.address ?? "";
    read = churchData.read ?? "";
    gpsLat = churchData.gpsLat ?? "";
    gpsLong = churchData.gpsLong ?? "";
    about = churchData.about ?? "";
    timeOpen = churchData.timeOpen ?? "";
    contactNumber = churchData.contactNumber ?? "";
    bucket = churchData.bucket ?? "";
    role = tokenUser.role;

    projects = {
      'Project': {
        'ChurchName': churchName,
        'LogoAddress': logo,
        'Address': address,
        'Read': read,
        'GpsLat': gpsLat,
        'GpsLong': gpsLong,
        'About': about,
        'TimeOpen': timeOpen,
        'ContactNumber': contactNumber,
        'Color': 0,
        'URL': 'https://bmzconrnjgpbiapvqcfh.supabase.co',
        'API':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImljaG52dW1mem9iaWdza3lyb2VqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUzNjUyMDYsImV4cCI6MjAzMDk0MTIwNn0.UgA32sjsuwQav3QHB7q7fhcCTzQZ8qcihD9NLIvQpsI',
        'ProjectId': '663e70370012ecbb3ba5',
        'Bucket': bucket,
        'Role': role,
        'Expire': expire,
      },
    };

    await updateProjects(context, projects);

    visibilityToggle(context);
  }

  Future<void> clearProject(BuildContext context) async {
    try {
      churchName = "";
      logo = "";
      address = "";
      read = "";
      gpsLat = "";
      gpsLong = "";
      about = "";
      timeOpen = "";
      contactNumber = "";
      bucket = "";
      role = "";

      Map<String, dynamic> projects = {};

      await updateProjects(context, projects);
      await sql.deleteAllChurches();
      await SqlDatabase.clearToken();
      
    } catch (error) {
      print('Error clearing project: $error');
      throw error;
    }
  }
}
