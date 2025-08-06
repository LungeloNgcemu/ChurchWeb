import 'package:flutter/services.dart';
import 'package:master/Model/church_data_model.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

abstract class ImageUrlBaseProvider extends ChangeNotifier {
  String? _imageUrl;

  String? get imageUrl => _imageUrl;

  set imageUrl(String? value) {
    _imageUrl = value;
    notifyListeners();
    saveImageUrlLocally(value);
  }

  Future<void> saveImageToFile(File imageFile) async {
    String imagePath = await _saveImageToLocalDirectory(imageFile);
    imageUrl = imagePath;
  }

  Future<String> _saveImageToLocalDirectory(File imageFile) async {
    Directory appDirectory = await pp.getApplicationDocumentsDirectory();
    String imagePath =
        '${appDirectory.path}/images/${path.basename(imageFile.path)}';
    await imageFile.copy(imagePath);
    return imagePath;
  }

  Future<void> saveImageUrlLocally(String? imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(getImageUrlKey(), imageUrl ?? '');
  }

  Future<void> loadImageUrlLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    imageUrl = prefs.getString(getImageUrlKey()) ?? null;
    notifyListeners();
  }

  String getImageUrlKey();
}

class ImageUrlProvider extends ImageUrlBaseProvider {
  @override
  String getImageUrlKey() => 'image_url';
}

class BackImageUrlProvider extends ImageUrlBaseProvider {
  @override
  String getImageUrlKey() => 'backImageUrl';
}

class ProfileImageUrlProvider extends ImageUrlBaseProvider {
  @override
  String getImageUrlKey() => 'profileImageUrl';
}

class PostImageUrlProvider extends ImageUrlBaseProvider {
  @override
  String getImageUrlKey() => 'postImageUrl';
}

class PostIdProvider extends ChangeNotifier {
  String _postId = '';

  String get postId => _postId;

  void updatePostId(String newPostId) {
    _postId = newPostId;
    notifyListeners();
  }
}

class SelectedOptionProvider extends ChangeNotifier {
  String _selectedOption = "Other";
  Color _color = Colors.black;

  String get selectedOption => _selectedOption;
  Color get color => _color;

  Color updateSelectedOption(String newOption, Color newColor) {
    _selectedOption = newOption;
    _color = newColor;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    return _color;
  }
}

class CurrentRoomIdProvider extends ChangeNotifier {
  String currentRoomId;

  CurrentRoomIdProvider({this.currentRoomId = ''});

  void updatecCurrentRoomId({required String newValue}) async {
    currentRoomId = newValue;
    notifyListeners();
  }
}

class CurrentUserImageProvider extends ChangeNotifier {
  String currentUserImage;

  CurrentUserImageProvider({this.currentUserImage = ''});

  void updatecCurrentRoomId({required String newValue}) async {
    currentUserImage = newValue;
    notifyListeners();
  }
}

/////////////////////
class ClientImageProvider extends ChangeNotifier {
  String clientImage;

  ClientImageProvider({this.clientImage = ''});

  void updateClientImage({required String newValue}) async {
    clientImage = newValue;
    notifyListeners();
  }
}

class ClientNameProvider extends ChangeNotifier {
  String clientName;

  ClientNameProvider({this.clientName = ''});

  void updateClientName({required String newValue}) async {
    clientName = newValue;
    notifyListeners();
  }
}

class ClientNumberProvider extends ChangeNotifier {
  String clientNumber;

  ClientNumberProvider({this.clientNumber = ''});

  void updateClientNumber({required String newValue}) async {
    clientNumber = newValue;
    notifyListeners();
  }
}

class ItemProvider extends ChangeNotifier {
  Map<String, dynamic> item;

  ItemProvider({this.item = const {}});

  void updateItem({required Map<String, dynamic> newValue}) async {
    item = newValue;
    notifyListeners();
  }
}

class tockenProvider extends ChangeNotifier {
  String tocken;

  tockenProvider({this.tocken = ''});

  void updateTocken({required String newValue}) async {
    tocken = newValue;
    notifyListeners();
  }
}

class christProvider extends ChangeNotifier {
  Map<String, dynamic> myMap = {};
  ChurchDataModel? churchData;

  christProvider({this.myMap = const {}});

  void updatemyMap({required Map<String, dynamic> newValue}) async {
    myMap = newValue;
    churchData = ChurchDataModel.fromJson(newValue);
    notifyListeners();
  }
}

class churchProvider extends ChangeNotifier {
  String churchName = "";
  String logoAddress = "";
  String address = "";
  String read = "";
  String gpsLat = "";
  String gpsLong = "";
  String about = "";
  String timeOpen = "";
  int color = 0;
  String bucket = "";
  String contactNumber = "";

  churchProvider();

  void updateChurchName({required String newValue}) {
    churchName = newValue;
    notifyListeners();
  }

  void updateLogoAddress({required String newValue}) {
    logoAddress = newValue;
    notifyListeners();
  }

  void updateAddress({required String newValue}) {
    address = newValue;
    notifyListeners();
  }

  void updateRead({required String newValue}) {
    read = newValue;
    notifyListeners();
  }

  void updateGpsLat({required String newValue}) {
    gpsLat = newValue;
    notifyListeners();
  }

  void updateGpsLong({required String newValue}) {
    gpsLong = newValue;
    notifyListeners();
  }

  void updateAbout({required String newValue}) {
    about = newValue;
    notifyListeners();
  }

  void updateTimeOpen({required String newValue}) {
    timeOpen = newValue;
    notifyListeners();
  }

  void updateColor({required int newValue}) {
    color = newValue;
    notifyListeners();
  }

  void updateBucket({required String newValue}) {
    bucket = newValue;
    notifyListeners();
  }

  void updateContactNumber({required String newValue}) {
    contactNumber = newValue;
    notifyListeners();
  }
}

class VisibilityProvider extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void visibilityToggle(bool newValue) {
    _isVisible = newValue;
    notifyListeners();
  }
}

class IdProvider extends ChangeNotifier {
  String? id;

  void changeID(String newValue) {
    id = newValue;
    notifyListeners();
  }
}

class RoleProvider extends ChangeNotifier {
  String userRole = "";

  void changeRole({required String newValue}) {
    userRole = newValue;
    notifyListeners();
  }
}

class SelectedDateProvider extends ChangeNotifier {
  String year = "";
  String month = "";
  String day = "";

  Map<String, dynamic> selectedDate = {};

  void updatemyMap(
      {required String year, required String month, required String day}) {
    selectedDate["Year"] = year;
    selectedDate["Month"] = month;
    selectedDate["Day"] = day;

    print(selectedDate);
    notifyListeners();
  }
}

class SelectedChurchProvider extends ChangeNotifier {
  String selectedChurch = "";

  void updateSelectedChurch({required String newValue}) {
    selectedChurch = newValue;
    notifyListeners();
  }
}

class SelectedGenderProvider extends ChangeNotifier {
  String selectedGender = "";

  void updateGender({required String newValue}) {
    selectedGender = newValue;
    notifyListeners();
  }
}
