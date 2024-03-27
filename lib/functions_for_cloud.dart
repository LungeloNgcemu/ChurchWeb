import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';






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










