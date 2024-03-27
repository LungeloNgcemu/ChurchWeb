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
    String imagePath = '${appDirectory.path}/images/${path.basename(imageFile.path)}';
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
    notifyListeners();
    return _color;
  }
}

class CurrentRoomIdProvider extends ChangeNotifier {
  String currentRoomId ;

  CurrentRoomIdProvider({this.currentRoomId = ''});

 void updatecCurrentRoomId ({required String newValue}) async {
   currentRoomId = newValue;
    notifyListeners();
  }
}

class CurrentUserImageProvider extends ChangeNotifier {
  String currentUserImage ;

  CurrentUserImageProvider({this.currentUserImage = ''});

  void updatecCurrentRoomId ({required String newValue}) async {
    currentUserImage = newValue;
    notifyListeners();
  }
}
/////////////////////
class ClientImageProvider extends ChangeNotifier {
  String clientImage ;

  ClientImageProvider({this.clientImage = ''});

  void updateClientImage ({required String newValue}) async {
    clientImage = newValue;
    notifyListeners();
  }
}

class ClientNameProvider extends ChangeNotifier {
  String clientName ;

  ClientNameProvider({this.clientName = ''});

  void updateClientName ({required String newValue}) async {
    clientName = newValue;
    notifyListeners();
  }
}

class ClientNumberProvider extends ChangeNotifier {
  String clientNumber ;

  ClientNumberProvider({this.clientNumber = ''});

  void updateClientNumber ({required String newValue}) async {
    clientNumber = newValue;
    notifyListeners();
  }
}







////////////////////////////////////////////////

class ItemProvider extends ChangeNotifier {
  Map<String,dynamic> item ;

  ItemProvider({this.item = const {} });

  void updateItem ({required Map<String,dynamic> newValue}) async {
    item = newValue;
    notifyListeners();
  }
}
class tockenProvider extends ChangeNotifier {
  String tocken ;

 tockenProvider({this.tocken = ''});

  void updateTocken ({required String newValue}) async {
    tocken = newValue;
    notifyListeners();
  }
}