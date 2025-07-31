import 'package:flutter/cupertino.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/restrictions.dart';
import 'package:master/classes/sql_database.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../componants/global_booking.dart';
import '../databases/database.dart';
import '../providers/url_provider.dart';
import 'message_class.dart';

class ChurchInit {
  String? ChurchName = "";
  String? LogoAddress = "";
  String? Address = "";
  String? Read = "";
  String? GpsLat = "";
  String? GpsLong = "";
  String? About = "";
  String? TimeOpen = "";
  int? Color = 0;
  String? Bucket = "";
  String? ContactNumber = "";
  String? role = "";

  SqlDatabase sql = SqlDatabase();
  Restrictions restrict = Restrictions();

  bool invert(bool value) {
    return !value;
  }

  Future<bool> expiryExpire(churchName) async {
    try {
      final exp = await restrict.getExpiryDate(churchName);
      if (exp == 'none') {
        return true;
      }
      final answer = restrict.isExpired(exp);
      return invert(answer);
    } catch (error) {
      print("Expire Expire ERROR");
      return false;
    }
  }

  bool visibilityToggle(BuildContext context) {
    final status = Provider.of<christProvider>(context, listen: false)
        .myMap['Project']?['Role'];

    bool isAdmin = status == "Admin";

    return isAdmin;
  }

  Future<Map<String, dynamic>> getCurrentUser(BuildContext context) async {
    AppWriteDataBase connect = AppWriteDataBase();
    try {
      final user = await connect.account.get();
      final nameMap = await supabase
          .from("User")
          .select()
          .eq('PhoneNumber', user.phone)
          .single();

      Map<String, dynamic> userData = {
        "UserName": nameMap['UserName'],
        "UserId": user.$id,
        "PhoneNumber": user.phone,
      };

      return userData;
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<void> getRole(BuildContext context) async {
    try {
      final user = await getCurrentUser(context);

      final number = user['PhoneNumber'];
      final data = await supabase
          .from('User')
          .select()
          .eq('PhoneNumber', number)
          .single();

      role = data["Role"];

      Provider.of<RoleProvider>(context, listen: false)
          .changeRole(newValue: role!);
    } catch (error) {
      print('Cant establish User Role');
    }
  }

  Map<String, Map<String, dynamic>> projects = {};

  Future<Map<String, dynamic>> getChurch(church) async {
    try {
      final data = await supabase
          .from('Church')
          .select()
          .eq('ChurchName', church)
          .single();
      return data;
    } catch (error) {
      print('Error fetching church data: $error');
      return {};
    }
  }

  Future<void> updateProjects(BuildContext context, projects) async {
    context.read<christProvider>().updatemyMap(newValue: projects);
  }

  Future<void> init(BuildContext context) async {
    final selectedChurch =
        Provider.of<SelectedChurchProvider>(context, listen: false)
            .selectedChurch;
    final name = await sql.getChurchName();
    final expire = await expiryExpire(name);
    final churchData = await getChurch(name);

    await getRole(context);

    if (churchData.isEmpty) {
      print('No church data found');
      return;
    }

    ChurchName = churchData['ChurchName'] ?? "";
    LogoAddress = churchData['LogoAddress'] ?? "";
    Address = churchData['Address'] ?? "";
    Read = churchData['Read'] ?? "";
    GpsLat = churchData['GpsLat'] ?? "";
    GpsLong = churchData['GpsLong'] ?? "";
    About = churchData['About'] ?? "";
    TimeOpen = churchData['TimeOpen'] ?? "";
    ContactNumber = churchData['ContactNumber'] ?? "";
    Color = int.tryParse(churchData['Color'] ?? '0') ?? 0;
    Bucket = churchData['Bucket'] ?? "";

    role = Provider.of<RoleProvider>(context, listen: false).userRole;

    projects = {
      'Project': {
        'ChurchName': ChurchName,
        'LogoAddress': LogoAddress,
        'Address': Address,
        'Read': Read,
        'GpsLat': GpsLat,
        'GpsLong': GpsLong,
        'About': About,
        'TimeOpen': TimeOpen,
        'ContactNumber': ContactNumber,
        'Color': Color,
        'URL': 'https://bmzconrnjgpbiapvqcfh.supabase.co',
        'API':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImljaG52dW1mem9iaWdza3lyb2VqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUzNjUyMDYsImV4cCI6MjAzMDk0MTIwNn0.UgA32sjsuwQav3QHB7q7fhcCTzQZ8qcihD9NLIvQpsI',
        'ProjectId': '663e70370012ecbb3ba5',
        'Bucket': Bucket,
        'Role': role,
        'Expire': expire,
      },
    };

    await updateProjects(context, projects);
    visibilityToggle(context);
  }

  Future<void> clearProject(BuildContext context) async {
    try {
      ChurchName = "";
      LogoAddress = "";
      Address = "";
      Read = "";
      GpsLat = "";
      GpsLong = "";
      About = "";
      TimeOpen = "";
      ContactNumber = "";
      Color = 0;
      Bucket = "";
      role = "";

      Map<String, dynamic> projects = {};

      await updateProjects(context, projects);
      sql.deleteAllChurches();
      print('Project cleared successfully');
    } catch (error) {
      print('Error clearing project: $error');
      throw error;
    }
  }
}
