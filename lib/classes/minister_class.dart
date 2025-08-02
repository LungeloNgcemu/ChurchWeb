import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../componants/global_booking.dart';
import '../providers/url_provider.dart';

class MinisterClass {
  Uint8List? xImage;
  String image = '';
  bool isLoading = false;
  final ImagePickerCustom _picker = ImagePickerCustom();

  Future<void> _pickImage(Function(void Function()) setState) async {
    final pickedImage = await _picker.pickImageToByte();

    if (pickedImage != null) {
      setState(() {
        xImage = pickedImage;
      });
    }
  }

  Future<void> uploadImageToSuperbase(
      BuildContext context, Function(void Function()) setState) async {
    setState(() {
      isLoading = true;
    });
    try {
      await _pickImage(setState);

      if (xImage != null) {
        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .uploadBinary(fileName, xImage!,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));

        final publicUrl = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .getPublicUrl(fileName);

        setState(() {
          image = publicUrl;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log("Error uploading image to Supabase: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> uploadMinister(
      String name, String work, String image, context) async {
    await supabase.from('Minister').insert({
      'Name': name,
      'Work': work,
      'Image': image,
      'Church': Provider.of<christProvider>(context, listen: false)
              .myMap['Project']?['ChurchName'] ??
          ""
    });
  }
}
