import 'package:flutter/material.dart';
import 'package:master/screens/profile_screen.dart';
import 'package:master/screens/users.dart';
import 'package:readmore/readmore.dart';
import 'package:master/databases/database.dart';
import 'package:master/screens/post_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:master/componants/global_booking.dart';
import '../about_us.dart';
import '../gallery.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'product_service_screen.dart';
import '../componants/chips.dart' as MyChips;
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'booking_screen.dart';
import 'info_book_screen.dart';
import 'users.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:master/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:master/url_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:backdrop/backdrop.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:master/databases/database.dart';
import 'package:appwrite/appwrite.dart' as ap;
import 'package:master/screens/chat_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:master/map.dart' as location;
import 'package:badges/badges.dart' as b;
import 'package:supabase/supabase.dart';
import 'package:master/componants/display_image.dart';
import 'package:master/componants/global_booking.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

String selectedOption = 'About Us';

class SalonScreen extends StatefulWidget {
  const SalonScreen({super.key});

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  final wsUrl = Uri.parse(
      'ws://cloud.appwrite.io/v1/realtime?project=65bc947456c1c0100060&channels%5B%5D=databases.65c375bf12fca26c65db.collections.65ecde2786c77bcd4597.documents');
  late final channel = WebSocketChannel.connect(wsUrl);

  Future stream() async {
    return await channel.stream.single;
  }

  String count = '0';

  AppWriteDataBase connect = AppWriteDataBase();

  Future<void> getCount() async {
    try {
      // userChat rooms
      final user = await connect.account.get();
      //final id = user.$id;

      // print("ID ID !!!!!!!!!!!!!!!!!!!!!! $id");

      final result = await connect.databases.listDocuments(
        databaseId: '65c375bf12fca26c65db',
        collectionId: '65d1e705ceb53916f35a',
        queries: [
          ap.Query.equal("ManangerId", [user.$id])
        ],
      );

      final doc = result.documents.first.data['ManagerSingleChatId'];
      List<String> idList = [];
      for (var item in doc) {
        idList.add(item);
      }
      // if list is not empty

      if (idList.isNotEmpty) {
        final result2 = await connect.databases.listDocuments(
          databaseId: '65c375bf12fca26c65db',
          collectionId: '65d0612a901236115ecc',
          queries: [
            ap.Query.limit(10000),
            ap.Query.equal("ChatRoomId", idList),
            ap.Query.equal("Status", ["Unread"]),
            ap.Query.notEqual("SenderId", [user.$id])
          ],
        );
        final documents = result2.documents.length;

        setState(() {
          count = documents.toString();
          print("THE COUNT!!!!!!!!!!!!!!!!!!!!! $count");
        });
      } else {
        print('LIST IS EMPTY');
      }
    } catch (error) {
      print('COUNR ERROR : $error');
    }
  }

  final supabase = Supabase.instance.client;

  void superbaseCount() async {
    try {
      final user = await connect.account.get();

      final result = await connect.databases.listDocuments(
        databaseId: '65c375bf12fca26c65db',
        collectionId: '65d1e705ceb53916f35a',
        queries: [
          ap.Query.equal("ManangerId", [user.$id])
        ],
      );

      final doc = result.documents.first.data['ManagerSingleChatId'];
      List<String> idList = [];
      for (var item in doc) {
        idList.add(item);
      }
      if (idList.isNotEmpty) {
        final documents = await supabase
            .from('Message')
            .select()
            .inFilter('ChatRoomId', idList)
            .eq('Status', "Unread")
            .neq('SenderId', user.$id);

        final countx = documents.length;

        setState(() {
          count = countx.toString();
        });
        print(count);
      }
    } catch (error) {
      print(error);
    }
  }

  final PageController controller = PageController();
  int visit = 0;
  bool isVisble = false;
  List<TabItem> items = const [
    TabItem(
      icon: Icons.home_filled,
      title: 'Home',
    ),
    TabItem(
      icon: Icons.post_add,
      title: 'Social',
    ),
    TabItem(
      icon: Icons.shopping_cart_outlined,
      title: 'Products',
    ),
    TabItem(
      icon: Icons.watch_later_outlined,
      title: 'Time',
    ),
    TabItem(
      icon: Icons.book,
      title: 'Bookings',
    ),
    TabItem(
      icon: Icons.people_alt_outlined,
      title: 'Contact',
    ),
    TabItem(
      icon: Icons.account_circle_outlined,
      title: 'Account',
    ),
    // TabItem(
    //   icon: Icons.people_alt_outlined,
    //   title: 'Users',
    // ),
  ];

  final List<Widget> _pages = const [
    SalonBody(),
    PostScreen(),
    ProductandServiveBody(),
    BookingScreen(),
    InfoBook(),
    ChatScreen(),
    ProfileScreen()
    // UsersBody(),
  ];

  void sheeting2() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Modal BottomSheet'),
                ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void sheeting() {
    Widget _buildBottomSheet(
      BuildContext context,
      ScrollController scrollController,
      double bottomSheetOffset,
    ) {
      return Material(
        child: Container(
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
          ),
        ),
      );
    }

    showFlexibleBottomSheet(
      minHeight: 0,
      initHeight: 0.8,
      maxHeight: 0.8,
      context: context,
      builder: _buildBottomSheet,
      isExpand: false,
    );
  }

  Stream<dynamic> listining2() {
    return supabase.from('Message').stream(primaryKey: ['id']);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: w * 0.73),
        child: SizedBox(
          child: b.Badge(
            position: b.BadgePosition.topEnd(top: 30, end: 106),
            badgeContent: Text(count ?? '', style: TextStyle(fontSize: 30.0)),
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: listining2(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const SizedBox.shrink();
                case ConnectionState.waiting:
                  return const SizedBox.shrink();
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    //TODO uncoment
                    superbaseCount();
                    //getCount();

                    // Future.delayed(Duration.zero, () async {
                    //   setState(() {
                    //
                    //   });
                    // });

                    break;
                  }
                case ConnectionState.done:
                  return const SizedBox.shrink();
                default:
                  return const SizedBox.shrink();
              }
              return Container();
            },
          ),
          PageView(
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              setState(() {
                visit = index;
                (context as Element).markNeedsBuild();
              });
            },
            controller: controller,
            children: _pages,
          ),
        ],
      ),
      bottomNavigationBar: BottomBarFloating(
        items: items,
        backgroundColor: Colors.white,
        color: Colors.black,
        colorSelected: Colors.red,
        indexSelected: visit,
        paddingVertical: 8,
        onTap: (int index) => setState(() {
          visit = index;
          controller.animateToPage(index,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        }),
      ),
    );
  }
}

class SalonBody extends StatefulWidget {
  const SalonBody({super.key});

  @override
  State<SalonBody> createState() => _SalonBodyState();
}

class _SalonBodyState extends State<SalonBody> {
  AppWriteDataBase connect = AppWriteDataBase();

  @override
  void initState() {
    specInit();
    //imageInit();
    super.initState();
    Provider.of<ImageUrlProvider>(context, listen: false).loadImageUrlLocally();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _image; // Change PickedFile to XFile
  String? imageUrl;

  Future<void> _pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery) as XFile?;
    // Handle the picked image as needed
  }

  Future<String> _uploadImageToFirebase() async {
    try {
      await _pickImage();

      if (_image != null) {
        File imageFile = File(_image!.path);
        String fileName = path.basename(imageFile.path);

        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child("images")
            .child(fileName);

        var metadata = firebase_storage.SettableMetadata(
          contentType:
              'image/jpeg', // Set the correct content type based on your image type
        );

        await ref.putFile(imageFile, metadata);

        imageUrl = await ref.getDownloadURL(); // Update state variable
        // Provider.of<ImageUrlProvider>(context, listen: false).imageUrl =
        //     imageUrl;

        print("Image uploaded to Firebase: $imageUrl");

        return imageUrl!;
      } else {
        print("No image selected");
        return "";
      }
    } catch (e) {
      print("Error uploading image to Firebase: $e");
      return "";
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSpecialist() {
    return FirebaseFirestore.instance.collection("Specialist").snapshots();
  }

  Stream? specialists;

  void specInit() async {
    final s = await specail();
    setState(() {
      specialists = s;
    });
  }

  specail() {
    return supabase.from('Specialist').stream(primaryKey: ['id']);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<String> upLoadImage(Asset image) async {
    try {
      AppWriteDataBase connect = AppWriteDataBase();
      var uuid = Uuid();
      var genId = uuid.v6();
      var forName = uuid.v4();

      final storage = connect.storage;

      ByteData byteData = await image.getByteData(quality: 15);
      List<int> imageData = byteData.buffer.asUint8List();

      // Replace 'file' with the file you want to upload
      final response = await storage.createFile(
        bucketId: '65c36455aabc9ae9dca0',
        fileId: genId,
        file: ap.InputFile.fromBytes(
            bytes: imageData, filename: 'image$forName.jpg'),
        //permissions: ['any'],
      );

      // Check if the upload was successful
      if (response != null) {
        String imageId = response.$id;
        //final result = await storage.getFilePreview(bucketId:'65c36455aabc9ae9dca0',fileId: imageId);

        final img =
            'https://cloud.appwrite.io/v1/storage/buckets/65c36455aabc9ae9dca0/files/$imageId/view?project=65bc947456c1c0100060&mode=admin';
        // print(response.)
        print('THIS IS THE IMADE URL : $img');
        return img;
      } else {
        print('Failed to upload image: ${response.name}');
        return '';
      }
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  //////////////////////////////////////////////////////////////////////////////////

  Future<void> _loadAssetsLoop() async {
    print("Pressed");
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<Asset> resultList = <Asset>[];
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
          doneButton:
              UIBarButtonItem(title: 'Confirm', tintColor: colorScheme.primary),
          cancelButton:
              UIBarButtonItem(title: 'Cancel', tintColor: colorScheme.primary),
          albumButtonColor: Theme.of(context).colorScheme.primary,
        ),
        materialOptions: const MaterialOptions(
          maxImages: 10,
          enableCamera: true,
          actionBarColor: Colors.blue,
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: Colors.grey,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    List<String> urls = [];
    for (var item in resultList) {
      final url = await upLoadImage(item);
      await uploadToGallaryCollection(url);
    }
    //TODO push ur umages to an online collection

    if (!mounted) return;
//TODO dont use set state
    print("Done");
  }

  Future<void> uploadToGallaryCollection(image) async {
    var tt = Uuid();
    var nn = tt.v6();

    final created = await connect.databases.createDocument(
      databaseId: '65c375bf12fca26c65db',
      collectionId: '65d9aee75827739aee86',
      documentId: nn,
      data: {
        'Image': image,
      },
    );

    print('IMAGE SENT TO ITS COLLECTION');
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  List<Asset> images = <Asset>[];
  String _error = 'No Error Dectected';

  Future<void> _loadAssets() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<Asset> resultList = <Asset>[];
    String error = 'No Error Dectected';

    const AlbumSetting albumSetting = AlbumSetting(
      fetchResults: {
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumFavorites,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.album,
          subtype: PHAssetCollectionSubtype.albumRegular,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumPanoramas,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumVideos,
        ),
      },
    );
    const SelectionSetting selectionSetting = SelectionSetting(
      min: 0,
      max: 3,
      unselectOnReachingMax: true,
    );
    const DismissSetting dismissSetting = DismissSetting(
      enabled: true,
      allowSwipe: true,
    );
    final ThemeSetting themeSetting = ThemeSetting(
      backgroundColor: colorScheme.background,
      selectionFillColor: colorScheme.primary,
      selectionStrokeColor: colorScheme.onPrimary,
      previewSubtitleAttributes: const TitleAttribute(fontSize: 12.0),
      previewTitleAttributes: TitleAttribute(
        foregroundColor: colorScheme.primary,
      ),
      albumTitleAttributes: TitleAttribute(
        foregroundColor: colorScheme.primary,
      ),
    );
    const ListSetting listSetting = ListSetting(
      spacing: 5.0,
      cellsPerRow: 4,
    );
    final CupertinoSettings iosSettings = CupertinoSettings(
      fetch: const FetchSetting(album: albumSetting),
      theme: themeSetting,
      selection: selectionSetting,
      dismiss: dismissSetting,
      list: listSetting,
    );

    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: images,
        materialOptions: MaterialOptions(
            maxImages: 10,
            enableCamera: true,
            actionBarColor: colorScheme.surface,
            actionBarTitleColor: colorScheme.onSurface,
            statusBarColor: colorScheme.surface,
            actionBarTitle: "Select Photo",
            allViewTitle: "All Photos",
            useDetailsView: false,
            selectCircleStrokeColor: colorScheme.primary,
            backButtonDrawable: 'Back',
            okButtonDrawable: "Done"),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    print("PRESSED");
    setState(() {
      images = resultList;
      _error = error;
    });
  }

  Future<List<String>> getGallery() async {
    final response = await connect.databases.listDocuments(
      databaseId: '65c375bf12fca26c65db',
      collectionId: '65d9aee75827739aee86',
    );

    final doc = response.documents;
    final List<String> images = doc.map((item) {
      final img = item.data['Image'].toString();
      return img;
    }).toList();
    print("from .map : $images");
    return images;
  }

  Stream? gallery;

  // Future<void> imageInit() async {
  //   final insert = await getImage;
  //   setState(() {
  //     gallery = insert ;
  //   });


  // }

  Stream getImage() {
    return supabase.from('Gallery').stream(primaryKey: ['id']);
  }

  StreamBuilder buildGallery() {
    return StreamBuilder(
      stream: supabase.from('Gallery').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
         if(snapshot.hasError){
         }else if(!snapshot.hasData){
         }else if(snapshot.hasData){
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
                           onDoubleTap: (){
                             delete('Gallery',items[index]['id']);
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

  void _uploadImageToSuperbase(String where) async {
    try {
      await _pickImage();
      print('Image picked');
      if (_image != null) {
        final imageFile = File(_image!.path);
        final fileName = path.basename(imageFile.path);
        print('File picked: $fileName');

        final String pathv = await supabase.storage.from('SalonStorage').upload(
            '$fileName', imageFile,
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: false));
        print('Uploaded image path: $pathv');

        final publicUrl =
            await supabase.storage.from('SalonStorage').getPublicUrl(fileName);
        print('Public URL: $publicUrl');

        https: //subejxnzdnqyovwhinle.supabase.co/storage/v1/object/public/SalonStorage/public/IMG_20240322_135240.jpg

        //Upload to the Image table
        await supabase
            .from('DisplayImages')
            .upsert({'id': 1, '$where': publicUrl});
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
      stream: supabase.from('DisplayImages').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasError) {
            // Handle errors
            print("Error: ${snapshot.error}");
            return Text("Error: ${snapshot.error}");
          }

          final imageUrl = snapshot.data[0]?['$path'];
          print('URL HERE>>> $imageUrl');
          https: //subejxnzdnqyovwhinle.supabase.co/storage/v1/object/public/SalonStorage/public/IMG_20240322_135240.jpg

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
              fit: BoxFit.cover,
              height: 250,
              width: double.maxFinite,
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Future<void> delete(String what ,id) async {
    await supabase.from(what).delete().match({'id': id});
  }


  final ImagePicker _pickerx = ImagePicker();



  Future<void> _pickImagex() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  void _galleryInsert() async {
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

        final String pathv = await supabase.storage.from('SalonStorage').upload(
            '$fileName', imageFile,
            fileOptions:
            const FileOptions(cacheControl: '3600', upsert: false));
        print('Uploaded image path: $pathv');

        final publicUrl =
        await supabase.storage.from('SalonStorage').getPublicUrl(fileName);
        print('Public URL: $publicUrl');


        await supabase.from('Gallery').insert({ 'Picture': publicUrl });
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



  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBe,
      children: [
        Stack(
          children: <Widget>[
            // buildStreamBuilder(context, "FrontImage"),
            SizedBox(
                height: 250,
                width: double.maxFinite,
                child: xbuildStreamBuilder(context, 'FrontImage')),
            Positioned(
              top: 210.0,
              left: 375.0,
              child: GestureDetector(
                onTap: () async {
                  _uploadImageToSuperbase('FrontImage');
                  // final imagex = await _uploadImageToFirebase();
                  // uploadForSalon("FrontImage", imagex);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.orange,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 8.0,
          ),
          child: Container(
            // color: Colors.red,
            height: h * 0.625,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Salon',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: 8.0,
                          top: 8.0,
                        ),
                        child: Icon(Icons.add_location),
                      ),
                      Text(
                        '43 Andron Street Cresend',
                      )
                    ],
                  ),
                  //this is the row with icons
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconText(
                        iconimage: Icon(Icons.web),
                        icontext: Text('Website'),
                      ),
                      IconText(
                        iconimage: Icon(Icons.message),
                        icontext: Text('Message'),
                      ),
                      IconText(
                        iconimage: Icon(Icons.phone_rounded),
                        icontext: Text('Call'),
                      ),
                      IconText(
                        iconimage: Icon(Icons.location_on_rounded),
                        icontext: Text('Direction'),
                      ),
                      IconText(
                        iconimage: Icon(Icons.share_outlined),
                        icontext: Text('Share'),
                      ),
                    ],
                  ),

                  // We continue to next section
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Specialist',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/edit');
                          },
                          child: const Text('Create Specialist'),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      StreamBuilder(
                          stream: specialists,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return SizedBox();
                              case ConnectionState.waiting:
                                return SizedBox();
                              case ConnectionState.active:
                                if (snapshot.hasError) {
                                  print('Has Error');
                                } else if (!snapshot.hasData) {
                                  print('NO data here');
                                } else if (snapshot.hasData) {
                                  // List<dynamic> specs = [];

                                  final specs = snapshot.data;
                                  print('THIS IS SPEC $specs');
                                  // print(documents);
                                  //
                                  // for (QueryDocumentSnapshot doc
                                  //     in documents!) {
                                  //   Map<String, dynamic> display =
                                  //       doc.data()! as Map<String, dynamic>;
                                  //
                                  //   print(display);
                                  //   Map<String, dynamic> item = {
                                  //     'name': display['Name'],
                                  //     'work': display['Work'],
                                  //     'image': display['Image']
                                  //   };
                                  //   specs.add(item);
                                  // }

                                  return SizedBox(
                                    height: 150.0,
                                    width: w * 0.9611,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: specs.length,
                                        itemBuilder: (context, index) {
                                          return Specialist(
                                              tap: () {
                                                delete('Specialist',specs[index]['id']);
                                              },
                                              name: specs[index]['Name'],
                                              work: specs[index]['Work'],
                                              image: specs[index]['Image']);
                                        }),
                                  );
                                }
                              case ConnectionState.done:
                                return SizedBox();
                            }
                            return SizedBox();
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            _galleryInsert();
                          },
                          child: Text('Upload Images'))
                    ],
                  ),
                  SizedBox(
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MyChips.Chips(
                          inchip: 'About Us',
                          isSelected: selectedOption == 'About Us',
                          onSelected: () {
                            setState(() {
                              selectedOption = 'About Us';
                            });
                          },
                        ),
                        MyChips.Chips(
                          inchip: 'Gallery',
                          isSelected: selectedOption == 'Gallery',
                          onSelected: () {
                            setState(() {
                              selectedOption = 'Gallery';
                            });
                          },
                        ),
                        MyChips.Chips(
                          inchip: 'Map',
                          isSelected: selectedOption == 'Map',
                          onSelected: () {
                            setState(() {
                              selectedOption = 'Map';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  selectedOption == 'About Us' ? const AboutUs() : Container(),

                  selectedOption == 'Gallery' ? buildGallery() : Container(),

                  selectedOption == 'Map' ? location.Map() : Container(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StartLeftText extends StatelessWidget {
  const StartLeftText({
    this.wait,
    this.call,
    super.key,
  });

  final FontWeight? wait;
  final String? call;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$call',
          style: TextStyle(
            fontWeight: wait ?? FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class Specialist extends StatelessWidget {
  Specialist({
    this.name,
    this.work,
    this.image,
    this.tap,
    super.key,
  });

  String? name;
  String? work;
  String? image;
  void Function()? tap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 10.0, right: 10.0, bottom: 10.0, top: 10.0),
      child: GestureDetector(
        onDoubleTap: tap,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 0.1,
                  blurRadius: 10.0,
                )
              ]),
          height: 129.0,
          width: 97.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  height: 70.0,
                  width: 70.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: image ?? "",
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
                      fit: BoxFit.cover,
                      //height: 250,
                      //width: double.maxFinite,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                child: Text(
                  name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(work ?? ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({super.key, this.iconimage, this.icontext});

  final Icon? iconimage;
  final Text? icontext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 15.0),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(onPressed: () {}, icon: iconimage!),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: icontext!,
          )
        ],
      ),
    );
  }
}
