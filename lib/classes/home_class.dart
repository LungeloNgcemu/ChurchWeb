//import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master/classes/sql_database.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
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
  XFile? _image; // Change PickedFile to XFile
  String? imageUrl;
  bool isLoading = false;
  List<Asset> images = <Asset>[];
  String _error = 'No Error Dectected';

  final ImagePicker _picker = ImagePicker();

  SqlDatabase sql = SqlDatabase();

  Future<void> _pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery) as XFile?;
    // Handle the picked image as needed
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


    return supabase
        .from('Minister')
        .stream(primaryKey: ['id']).eq("Church", Provider.of<christProvider>(context, listen: false).myMap['Project']
                    ?['ChurchName'] );
  }

//   Future<void> _loadAssetsLoop(BuildContext context) async {
//     print("Pressed");
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;
//
//     List<Asset> resultList = <Asset>[];
//     String error = 'No Error Dectected';
//     try {
//       resultList = await MultiImagePicker.pickImages(
//         selectedAssets: images,
//         cupertinoOptions: CupertinoOptions(
//           doneButton:
//           UIBarButtonItem(title: 'Confirm', tintColor: colorScheme.primary),
//           cancelButton:
//           UIBarButtonItem(title: 'Cancel', tintColor: colorScheme.primary),
//           albumButtonColor: Theme.of(context).colorScheme.primary,
//         ),
//         materialOptions: const MaterialOptions(
//           maxImages: 10,
//           enableCamera: true,
//           actionBarColor: Colors.blue,
//           actionBarTitle: "Example App",
//           allViewTitle: "All Photos",
//           useDetailsView: false,
//           selectCircleStrokeColor: Colors.grey,
//         ),
//       );
//     } on Exception catch (e) {
//       error = e.toString();
//     }
//
//     List<String> urls = [];
//     for (var item in resultList) {
//       final url = await upLoadImage(item);
//       await uploadToGallaryCollection(url);
//     }
//     //TODO push ur umages to an online collection
//
//     if (!mounted) return;
// //TODO dont use set state
//     print("Done");
//   }
//

  // Future<void> _loadAssets(BuildContext context) async {
  //
  //   final ColorScheme colorScheme = Theme.of(context).colorScheme;
  //
  //   List<Asset> resultList = <Asset>[];
  //   String error = 'No Error Dectected';
  //
  //   const AlbumSetting albumSetting = AlbumSetting(
  //     fetchResults: {
  //       PHFetchResult(
  //         type: PHAssetCollectionType.smartAlbum,
  //         subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
  //       ),
  //       PHFetchResult(
  //         type: PHAssetCollectionType.smartAlbum,
  //         subtype: PHAssetCollectionSubtype.smartAlbumFavorites,
  //       ),
  //       PHFetchResult(
  //         type: PHAssetCollectionType.album,
  //         subtype: PHAssetCollectionSubtype.albumRegular,
  //       ),
  //       PHFetchResult(
  //         type: PHAssetCollectionType.smartAlbum,
  //         subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits,
  //       ),
  //       PHFetchResult(
  //         type: PHAssetCollectionType.smartAlbum,
  //         subtype: PHAssetCollectionSubtype.smartAlbumPanoramas,
  //       ),
  //       PHFetchResult(
  //         type: PHAssetCollectionType.smartAlbum,
  //         subtype: PHAssetCollectionSubtype.smartAlbumVideos,
  //       ),
  //     },
  //   );
  //   const SelectionSetting selectionSetting = SelectionSetting(
  //     min: 0,
  //     max: 3,
  //     unselectOnReachingMax: true,
  //   );
  //   const DismissSetting dismissSetting = DismissSetting(
  //     enabled: true,
  //     allowSwipe: true,
  //   );
  //   final ThemeSetting themeSetting = ThemeSetting(
  //     backgroundColor: colorScheme.background,
  //     selectionFillColor: colorScheme.primary,
  //     selectionStrokeColor: colorScheme.onPrimary,
  //     previewSubtitleAttributes: const TitleAttribute(fontSize: 12.0),
  //     previewTitleAttributes: TitleAttribute(
  //       foregroundColor: colorScheme.primary,
  //     ),
  //     albumTitleAttributes: TitleAttribute(
  //       foregroundColor: colorScheme.primary,
  //     ),
  //   );
  //   const ListSetting listSetting = ListSetting(
  //     spacing: 5.0,
  //     cellsPerRow: 4,
  //   );
  //   final CupertinoSettings iosSettings = CupertinoSettings(
  //     fetch: const FetchSetting(album: albumSetting),
  //     theme: themeSetting,
  //     selection: selectionSetting,
  //     dismiss: dismissSetting,
  //     list: listSetting,
  //   );
  //
  //   try {
  //     resultList = await MultiImagePicker.pickImages(
  //       selectedAssets: images,
  //       materialOptions: MaterialOptions(
  //           maxImages: 10,
  //           enableCamera: true,
  //           actionBarColor: colorScheme.surface,
  //           actionBarTitleColor: colorScheme.onSurface,
  //           statusBarColor: colorScheme.surface,
  //           actionBarTitle: "Select Photo",
  //           allViewTitle: "All Photos",
  //           useDetailsView: false,
  //           selectCircleStrokeColor: colorScheme.primary,
  //           backButtonDrawable: 'Back',
  //           okButtonDrawable: "Done"),
  //     );
  //   } on Exception catch (e) {
  //     error = e.toString();
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //   print("PRESSED");
  //   setState(() {
  //     images = resultList;
  //     _error = error;
  //   });
  // }
  //

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
      print('Image picked');
      if (_image != null) {
        final imageFile = File(_image!.path);
        final fileName = path.basename(imageFile.path);
        print('File picked: $fileName');

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .upload('$fileName', imageFile,
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
            // Handle errors
            print("Error: ${snapshot.error}");
            return Text("Error: ${snapshot.error}");
          }

          final imageUrl = snapshot.data[0]?['$path'];
          print('URL HERE>>> $imageUrl');
          https: //subejxnzdnqyovwhinle.supabase.co/storage/v1/object/public/projects['Project']?['Bucket']/public/IMG_20240322_135240.jpg

          return Container(
            height: h * 0.3,
            child: CachedNetworkImage(
              imageUrl: imageUrl ?? 'https://picsum.photos/seed/picsum/200/300',
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  height: 40.0,
                  width: 40.0,
                  child: CircularProgressIndicator(
                    value: 1.0,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.fill,
              height: 250,
              width: double.maxFinite,
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

  // final ImagePicker _pickerx = ImagePicker();
  //
  //
  //
  // Future<void> _pickImagex() async {
  //   final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedImage != null) {
  //     setState(() {
  //       _image = pickedImage;
  //     });
  //   }
  // }

  void galleryInsert(
      BuildContext context, Function(void Function()) setState) async {
    setState(() {
      isLoading = true;
    });
    try {
      await _pickImage();
      print('Image picked');
      if (_image != null) {
        final imageFile = File(_image!.path);
        final fileName = path.basename(imageFile.path);
        print('File picked: $fileName');

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .upload('$fileName', imageFile,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));
        print('Uploaded image path: $pathv');

        final publicUrl = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .getPublicUrl(fileName);
        print('Public URL: $publicUrl');

        await supabase.from('Gallery').insert({
          'Picture': publicUrl,
          'Church': Provider.of<christProvider>(context, listen: false)
              .myMap['Project']?['ChurchName']
        });
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
}
