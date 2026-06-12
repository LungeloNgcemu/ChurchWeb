import 'dart:typed_data';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/util/image_compress.dart';
import "package:supabase_flutter/supabase_flutter.dart";

class ImagePickerCustom {
  Future<Uint8List?> pickImageToByte() async {
    return await ImagePickerWeb.getImageAsBytes();
  }


  Future<String> uploadWebImage(String imagePath) async {
    try {
      ImagePickerCustom picker = ImagePickerCustom();

      Uint8List? _image = await picker.pickImageToByte();

      if (_image != null) {
        final compressed = await compressImageBytes(_image!);
        final String path =
            await supabase.storage.from('churchStorage').uploadBinary(
                  'public/${imagePath}.jpg',
                  compressed,
                  fileOptions:
                      const FileOptions(cacheControl: '3600', upsert: false),
                );

        return supabase.storage
            .from('churchStorage')
            .getPublicUrl('${imagePath}.jpg');
      } else {
        return "";
      }
    } catch (e) {
      print("Error uploading image to Superbase: $e");
      return "";
    }
  }
  
}
