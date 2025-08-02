import 'dart:typed_data';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:master/componants/global_booking.dart';
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
        final String path =
            await supabase.storage.from('SalonStorage').uploadBinary(
                  'public/${imagePath}.png',
                  _image!,
                  fileOptions:
                      const FileOptions(cacheControl: '3600', upsert: false),
                );

        return supabase.storage
            .from('SalonStorage')
            .getPublicUrl('${imagePath}.png');
      } else {
        return "";
      }
    } catch (e) {
      print("Error uploading image to Superbase: $e");
      return "";
    }
  }
  
}
