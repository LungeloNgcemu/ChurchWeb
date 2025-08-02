import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SqlDatabase {
  static const String _churchKey = "churchName";

  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  // Future<void> initializeDatabase() async {
  //   _prefs = await SharedPreferences.getInstance();
  //   _isInitialized = true;
  // }

  // Simulate database insert
  void insertChurchName({required String churchName}) async {
    _prefs = await SharedPreferences.getInstance();

    try {
      await _prefs?.setString(_churchKey, churchName);
      print('Inserted church name: $churchName');
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
      print("Something went wrong getting church name");
      return "";
    }
  }

  // Simulate delete all churches
  Future<void> deleteAllChurches() async {
    _prefs = await SharedPreferences.getInstance();

    try {
      await _prefs?.remove(_churchKey);
      print('Deleted church name');
    } catch (error) {
      print("Error deleting church name: $error");
    }
  }

  // Simulate database deletion (clearing all data)
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
