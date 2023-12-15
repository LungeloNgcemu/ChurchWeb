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





