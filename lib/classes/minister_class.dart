import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../componants/global_booking.dart';
import '../providers/url_provider.dart';

class MinisterClass {


  XFile? xImage;
  String image = '';
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Function(void Function()) setState) async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        xImage = pickedImage;
      });
    }
  }



  Future<void> uploadImageToSuperbase(BuildContext context,  Function(void Function()) setState ) async {

    setState(() {
      isLoading = true;
    });
    try {
      await _pickImage(setState);

      print('Image picked');
      if (xImage != null) {
        final imageFile = File(xImage!.path);
        final fileName = path.basename(imageFile.path);
        print('File picked: $fileName');

        final String pathv = await supabase.storage.from(Provider.of<christProvider>(context, listen: false).myMap['Project']?['Bucket']).upload(
            '$fileName', imageFile,
            fileOptions:
            const FileOptions(cacheControl: '3600', upsert: false));
        print('Uploaded image path: $pathv');

        final publicUrl =
        await supabase.storage.from(Provider.of<christProvider>(context, listen: false).myMap['Project']?['Bucket']).getPublicUrl(fileName);
        print('Public URL: $publicUrl');

        setState(() {
          image = publicUrl;
          isLoading = false;
        });
        //Upload to the Image table
        // await supabase.from('Manager').update({ 'ProfileImage': publicUrl }).match({ 'PhoneNumber': number });
        print('Image Achieved');
      } else {

        setState(() {
          isLoading = false;
        });
        print("No image selected");
      }
    } catch (e) {
      print("Error uploading image to Supabase: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Future <void> uploadMinister(String name,String work,String image, context) async {
    await supabase .from('Minister')
        .insert({'Name': name, 'Work': work,'Image': image, 'Church' : Provider.of<christProvider>(context, listen: false).myMap['Project']
                        ?['ChurchName'] ??
                    ""});
  }


}