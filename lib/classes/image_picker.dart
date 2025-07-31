import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:path/path.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:master/componants/global_booking.dart';
import 'dart:io' as file;
import "church_init.dart";

class ImagePicked {
  final ImagePicker _picked = ImagePicker();
  ChurchInit churchStart = ChurchInit();

  XFile? _image;

  Future<void> _pickImage() async {
    _image = await _picked.pickImage(source: ImageSource.gallery) as XFile?;
    // Handle the picked image as needed
  }

  Future _uploadImageToSuperbase() async {
    try {
      await _pickImage();

      if (_image != null) {
        final imageFile = file.File(_image!.path);
        String fileName = basename(imageFile.path);

        final String path = await supabase.storage
            .from(churchStart.projects['Project']?['Bucket'])
            .upload(
              'public/frontImage.png',
              imageFile,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

//get Url
        final String publicUrl = supabase.storage
            .from(churchStart.projects['Project']?['Bucket'])
            .getPublicUrl('frontImage.png');

        //Upload to the Image table
        await supabase.from('DisplayImages').insert({'FrontImage': publicUrl});
      } else {
        print("No image selected");
        return "";
      }
    } catch (e) {
      print("Error uploading image to Supabase: $e");
      return "";
    }
  }
}
