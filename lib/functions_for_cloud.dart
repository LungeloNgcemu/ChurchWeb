import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'poster.dart';
import 'dart:io';
import 'url_provider.dart';
import 'comment_model.dart';
import 'model.dart';






Future<String> uploadImageToFirebaseStorage(File imageFile) async {
  try {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("images")
        .child("${DateTime.now().millisecondsSinceEpoch}");

    var metadata = firebase_storage.SettableMetadata(
      contentType: 'image/jpeg',
    );

    await ref.putFile(imageFile, metadata);
    return await ref.getDownloadURL();
  } catch (e) {
    print('Error uploading image to Firebase Storage: $e');
    return ''; // Return an empty string or handle the error accordingly
  }
}










