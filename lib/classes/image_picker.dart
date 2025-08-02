import "dart:developer";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:master/util/image_picker_custom.dart";
import "package:path/path.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:master/componants/global_booking.dart';
import 'dart:io' as file;
import "church_init.dart";

class ImagePicked {
  final ImagePickerCustom _picked = ImagePickerCustom();
  ChurchInit churchStart = ChurchInit();

  Uint8List? _image;

  Future<void> _pickImage() async {
    _image = await _picked.pickImageToByte();
  }

  Future _uploadImageToSuperbase() async {
    try {
      await _pickImage();

      if (_image != null) {
        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String path = await supabase.storage
            .from(churchStart.projects['Project']?['Bucket'])
            .uploadBinary(
              'public/frontImage.png',
              _image!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        final String publicUrl = supabase.storage
            .from(churchStart.projects['Project']?['Bucket'])
            .getPublicUrl('frontImage.png');

        await supabase.from('DisplayImages').insert({'FrontImage': publicUrl});
      } else {
        return "";
      }
    } catch (e) {
      log("Error uploading image to Supabase: $e");
      return "";
    }
  }
}
