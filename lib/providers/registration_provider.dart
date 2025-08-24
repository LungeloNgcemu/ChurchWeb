import 'package:flutter/material.dart';
import 'package:master/Model/registration_model.dart';

class RegistrationProvider extends ChangeNotifier {
  RegistrationModel registrationModel = RegistrationModel();

  void updateRegistration({
    String? phoneNumber,
    String? userName,
    String? role,
    String? gender,
    String? uniqueChurchId,
    String? password,
  }) {
    registrationModel = registrationModel.copyWith(
      phoneNumber: phoneNumber,
      userName: userName,
      role: role,
      gender: gender,
      uniqueChurchId: uniqueChurchId,
      password: password,
    );
    notifyListeners();
  }

  void setRegistrationModel(RegistrationModel model) {
    registrationModel = model;
    notifyListeners();
  }
}
