//import 'dart:html';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../componants/global_booking.dart';
import '../screens/home/widgets/gallery.dart';
import '../providers/url_provider.dart';
import 'dart:io';

class HomeClass {
  Stream? gallery;
  Stream? minister;
  Uint8List? _image; // Change PickedFile to XFile
  String? imageUrl;
  bool isLoading = false;
  // List<Asset> images = <Asset>[];
  String _error = 'No Error Dectected';

  final ImagePickerCustom _picker = ImagePickerCustom();

  SqlDatabase sql = SqlDatabase();

  Future<void> _pickImage() async {
    _image = await _picker.pickImageToByte();
  }

  Future<String> getName() async {
    var name = sql.getChurchName();

    return name;
  }

  void ministerInit(Function(void Function()) setState, context) async {
    final s = await specail(context);
    setState(() {
      minister = s;
    });
  }

  specail(context) {
    return supabase.from('Minister').stream(primaryKey: ['id']).eq(
        "Church",
        Provider.of<christProvider>(context, listen: false).myMap['Project']
            ?['ChurchName']);
  }

  Stream getImage() {
    return supabase.from('Gallery').stream(primaryKey: ['id']);
  }

  StreamBuilder buildGallery(BuildContext context) {
    return StreamBuilder(
      stream: supabase.from('Gallery').stream(primaryKey: ['id']).eq(
          'Church',
          Provider.of<christProvider>(context, listen: false).myMap['Project']
              ?['ChurchName']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasError) {
          } else if (!snapshot.hasData) {
          } else if (snapshot.hasData) {
            final items = snapshot.data;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Gallery(
                // images: images,
                grid: SizedBox(
                  height: 500.0,
                  child: GridView.custom(
                    gridDelegate: SliverQuiltedGridDelegate(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      repeatPattern: QuiltedGridRepeatPattern.inverted,
                      pattern: const [
                        QuiltedGridTile(2, 2),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 2),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return GestureDetector(
                            onDoubleTap: () {
                              delete('Gallery', items[index]['id']);
                            },
                            child: Tile(image: items[index]['Picture']));
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
              ),
            ); // Display Gallery widget wh
          }
        }
        return SizedBox();
      },
    );
  }

  void uploadImageToSuperbase(String where, BuildContext context) async {
    try {
      await _pickImage();

      if (_image != null) {

              final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .updateBinary(fileName, _image!,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));
        print('Uploaded image path: $pathv');

        final publicUrl = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .getPublicUrl(fileName);
        print('Public URL: $publicUrl');

        //Upload to the Image table
        await supabase.from('DisplayImages').upsert({
          'Church': Provider.of<christProvider>(context, listen: false)
              .myMap['Project']?['ChurchName'],
          '$where': publicUrl
        });
        print('Image inserted into DisplayImages table');
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error uploading image to Supabase: $e");
    }
  }

  StreamBuilder xbuildStreamBuilder(context, String path) {
    double h = MediaQuery.of(context).size.height;

    return StreamBuilder(
      stream: supabase.from('DisplayImages').stream(primaryKey: ['id']).eq(
          'Church',
          Provider.of<christProvider>(context, listen: false).myMap['Project']
                  ?['ChurchName'] ??
              ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          final imageUrl = snapshot.data[0]?['$path'];
        
          return Container(
            height: h * 0.3,
            child: Image.network(
              imageUrl,
              height: 40.0,
              width: 40.0,
              fit: BoxFit.fill,
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Future<void> delete(String what, id) async {
    await supabase.from(what).delete().match({'id': id});
  }

  void galleryInsert(
      BuildContext context, Function(void Function()) setState) async {
    setState(() {
      isLoading = true;
    });
    try {
      await _pickImage();

      if (_image != null) {


        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .uploadBinary('$fileName', _image!,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));
  
        final publicUrl = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .getPublicUrl(fileName);

        await supabase.from('Gallery').insert({
          'Picture': publicUrl,
          'Church': Provider.of<christProvider>(context, listen: false)
              .myMap['Project']?['ChurchName']
        });
      } else {
        setState(() {
          isLoading = false;
        });

      }
    } catch (e) {
      print("Error uploading image to Supabase: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
}
