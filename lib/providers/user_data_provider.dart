import 'package:flutter/cupertino.dart';

class UserDataProvider extends ChangeNotifier {
  String? _phoneNumber;

  get phoneNumber => _phoneNumber;

  void updatePhoneNUmber(String number) {
    _phoneNumber = number;
    notifyListeners();
  }
}
