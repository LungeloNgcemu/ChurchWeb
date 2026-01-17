import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/services/api/general_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SqlDatabase {
  static const String _churchKey = "churchName";
  static const String _tokenKey = "token";

  bool _isInitialized = false;
  SharedPreferences? _prefs;

  static Future<void> insertToken({required String token}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      await prefs?.setString(_tokenKey, token);
    } catch (error) {
      print("Token not inserted: $error");
    }
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString(_tokenKey) ?? "";
      return token;
    } catch (error) {
      return "";
    }
  }

  static Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove(_tokenKey);
    } catch (error) {
      print("Token not cleared: $error");
    }
  }


  void insertChurchName({required String churchName}) async {
    _prefs = await SharedPreferences.getInstance();

    try {
      await _prefs?.setString(_churchKey, churchName);
    } catch (error) {
      print("Church not inserted: $error");
    }
  }

  static Future<void> insertChurcItem({
    required ChurchItemModel churchItem,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert Map -> String
    final String item = jsonEncode(churchItem.toJson());

    try {
      await prefs.setString(_churchKey, item);
    } catch (error) {
      print("Church not inserted: $error");
    }
  }

  // Simulate database query
  Future<String> getChurchName() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      final name = _prefs?.getString(_churchKey) ?? "";
      return name;
    } catch (error) {
      return "";
    }
  }

  static Future<ChurchItemModel?> getChurchItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final name = prefs.getString(_churchKey) ?? "";

      final Map<String, dynamic> item = json.decode(name);

      return ChurchItemModel.fromJson(item);
    } catch (error) {
      return null;
    }
  }

  static Future<void> updateChurchItem({required String uniqueId}) async {
    final churchData = await GeneralDataService.getChurchData(uniqueId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String item = jsonEncode(churchData!.toJson());
    try {
      await prefs.setString(_churchKey, item);
    } catch (error) {
      print("Church not updated: $error");
    }
  }

  Future<void> deleteAllChurches() async {
    _prefs = await SharedPreferences.getInstance();

    try {
      await _prefs?.remove(_churchKey);
      print('Deleted church name');
    } catch (error) {
      print("Error deleting church name: $error");
    }
  }

  Future<void> deleteBase() async {
    _prefs = await SharedPreferences.getInstance();

    try {
      await _prefs?.clear();
      print('All preferences deleted successfully');
    } catch (error) {
      print("Error clearing shared preferences: $error");
    }
  }
}
