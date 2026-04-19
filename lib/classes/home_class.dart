//import 'dart:html';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../componants/global_booking.dart';
import '../screens/home/widgets/gallery.dart';
import '../widgets/common/connect_loader.dart';
import '../providers/url_provider.dart';
import 'dart:io';
import 'package:full_screen_image/full_screen_image.dart';

class HomeClass {
  Stream? gallery;
  Stream? minister;
  List? _galleryCache;
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

  void galleryInit(Function(void Function()) setState, BuildContext context) {
    final churchName = Provider.of<christProvider>(context, listen: false)
        .myMap['Project']?['ChurchName'];
    setState(() {
      gallery = supabase
          .from('Gallery')
          .stream(primaryKey: ['id']).eq('Church', churchName);
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

  StreamBuilder buildGallery(BuildContext context,
      {bool canDelete = false,
      Function(void Function())? setState}) {
    return StreamBuilder(
      stream: gallery,
      builder: (context, snapshot) {
        if (snapshot.hasData) _galleryCache = snapshot.data as List;
        final items = _galleryCache;
        final isRefreshing =
            snapshot.connectionState == ConnectionState.waiting;

        if (items == null) {
          return isRefreshing
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: ConnectLoader()),
                )
              : const SizedBox();
        }

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Gallery(
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
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Tile(image: items[index]['Picture']),
                            if (canDelete)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => alertDelete(
                                    context,
                                    'Remove this image from the gallery?',
                                    () async {
                                      await delete(
                                        context,
                                        'Gallery',
                                        items[index]['id'],
                                        items[index]['Picture'],
                                      );
                                      if (context.mounted && setState != null) {
                                        galleryInit(setState, context);
                                      }
                                    },
                                  ),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.60),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
              ),
            ),
            if (isRefreshing)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.55),
                  child: const Center(child: ConnectLoader()),
                ),
              ),
          ],
        );
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

  Future<void> delete(
      BuildContext context, String what, id, String imageUrl) async {
    await supabase.from(what).delete().match({'id': id});

    if (imageUrl.isNotEmpty) {
      final provider = Provider.of<christProvider>(context, listen: false);
      final bucket = provider.myMap['Project']?['Bucket'] ?? "";

      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;

      if (segments.isNotEmpty) {
        final startIndex = segments.indexOf(bucket) + 1;
        final filePath = segments.sublist(startIndex).join('/');

        await supabase.storage.from(bucket).remove([filePath]);
        print('Deleted image from storage: $filePath');
      }
    }
  }

  void galleryInsert(
      BuildContext context, Function(void Function()) setState) async {
    // Cache provider values before any async gap
    final provider = Provider.of<christProvider>(context, listen: false);
    final churchName = provider.myMap['Project']?['ChurchName'] ?? '';
    final bucket = provider.myMap['Project']?['Bucket'] ?? '';

    setState(() => isLoading = true);
    try {
      final existing = await supabase
          .from('Gallery')
          .select('id')
          .eq('Church', churchName);
      if ((existing as List).length >= 10) {
        setState(() => isLoading = false);
        if (context.mounted) {
          alertReturn(context, 'Gallery limit reached. Maximum 10 images allowed.');
        }
        return;
      }

      await _pickImage();
      if (_image == null) {
        setState(() => isLoading = false);
        return;
      }

      final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from(bucket).uploadBinary(
            fileName,
            _image!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      await supabase.from('Gallery').insert({
        'Picture': publicUrl,
        'Church': churchName,
      });

      if (context.mounted) galleryInit(setState, context);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }
}
