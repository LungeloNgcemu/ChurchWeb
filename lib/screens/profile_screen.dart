//import 'dart:html';

import 'dart:io' as f;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/databases/database.dart';
import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppWriteDataBase connect = AppWriteDataBase();

  @override
  void initState() {
    xgetUser();
    // TODO: implement initState
    super.initState();
  }
bool isLoading = false;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPhone = TextEditingController();
  String image = '';

  Map<String, dynamic> currentUser = {};
  String docId = "";
  String number = "";

  void xgetUser() async {

    setState(() {
      isLoading = true;
    });
    try {
      final user = await connect.account.get();
      setState(() {
        number = user.phone;
      });

      final item = await supabase
          .from('Manager')
          .select('ProfileImage, ManagerName')
          .eq('PhoneNumber', number)
          .single();

      currentUser = {
        "UserName": item["ManagerName"],
        "ProfileImage": item["ProfileImage"],
      };

      setState(() {
        controllerName.text = currentUser["UserName"];
        image = currentUser["ProfileImage"];
      });
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
    }
  }

//   void getUser() async {
//     try {
//       final user = await connect.account.get();
//       final id = user.$id;
//
// //get user infor from list
//       final response = await connect.databases.listDocuments(
//           databaseId: '65c375bf12fca26c65db',
//           collectionId: '65d1e705ceb53916f35a',
//           queries: [
//             Query.equal("ManangerId", [id]),
//           ]);
//
//       final doc = response.documents.first;
//       // doc ID for Update
//       docId = doc.$id;
//
//       currentUser = {
//         "UserName": doc.data["ManagerName"],
//         "ProfileImage": doc.data["PofileImage"],
//         "Email": doc.data["ManagerEmail"],
//         "ManangerId":doc.data["ManangerId"],
//         "ManagerSingleChatId":doc.data["ManagerSingleChatId"],
//       };
//
//       setState(() {
//         controllerName.text = currentUser["UserName"];
//         image = currentUser["ProfileImage"];
//       });
//     } catch (error) {
//       print(error);
//     }
//   }
//managerId
  //mananger singel chat
  // void update(id) async {
  //   final response = await connect.databases.updateDocument(
  //       databaseId: '65c375bf12fca26c65db',
  //       collectionId: '65d1e705ceb53916f35a',
  //       documentId: id,
  //       data: {
  //         "ManagerName": controllerName.text,
  //         "PofileImage": image,
  //         "ManagerEmail": currentUser["ManagerEmail"],
  //         "ManangerId":currentUser["ManangerId"],
  //         "ManagerSingleChatId":currentUser["ManagerSingleChatId"],
  //       });
  // }

  Future<void> update() async {
    setState(() {
      isLoading = true;
    });
    await supabase.from('Manager').update({
      'ProfileImage': image,
      'ManagerName': controllerName.text
    }).match({'PhoneNumber': number});

    setState(() {
      isLoading = false;
    });
  }

  List<Asset> images = <Asset>[];
  String _error = 'No Error Dectected';

  // Future<void> _loadAssets() async {
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
  //
  //   try {
  //     resultList = await MultiImagePicker.pickImages(
  //       selectedAssets: images,
  //       materialOptions: const MaterialOptions(
  //         maxImages: 1,
  //         // hasCameraInPickerPage: true,
  //         actionBarColor: Colors.grey,
  //         // actionBarTitle: "Profile Image",
  //         // allViewTitle: "All Photos",
  //         // backButtonDrawable: "Back",
  //         // //okButtonDrawable: "Done",
  //         // useDetailsView: false,
  //       ),
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

  // Future<String> convertImage(Asset imagex) async {
  //   try {
  //     AppWriteDataBase connect = AppWriteDataBase();
  //     var uuid = Uuid();
  //     var genId = uuid.v6();
  //     var forName = uuid.v4();
  //
  //     final storage = connect.storage;
  //
  //     ByteData byteData = await imagex.getByteData(quality: 15);
  //     List<int> imageData = byteData.buffer.asUint8List();
  //
  //     // Replace 'file' with the file you want to upload
  //     final response = await storage.createFile(
  //       bucketId: '65c36455aabc9ae9dca0',
  //       fileId: genId,
  //       file: InputFile.fromBytes(
  //           bytes: imageData, filename: 'image$forName.jpg'),
  //       //permissions: ['any'],
  //     );
  //
  //     // Check if the upload was successful
  //     if (response != null) {
  //       String imageId = response.$id;
  //       //final result = await storage.getFilePreview(bucketId:'65c36455aabc9ae9dca0',fileId: imageId);
  //
  //       final img =
  //           'https://cloud.appwrite.io/v1/storage/buckets/65c36455aabc9ae9dca0/files/$imageId/view?project=65bc947456c1c0100060&mode=admin';
  //       // print(response.)
  //       print('THIS IS THE IMADE URL : $img');
  //       setState(() {
  //         image = img;
  //       });
  //       return '';
  //     } else {
  //       print('Failed to upload image: ${response.name}');
  //       return '';
  //     }
  //   } catch (error) {
  //     print('Error uploading image: $error');
  //     return '';
  //   }
  // }

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  void _uploadImageToSuperbase() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _pickImage();
      print('Image picked');
      if (_image != null) {
        final imageFile = f.File(_image!.path);
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

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: isLoading == true ? Center(child: CircularProgressIndicator()) : Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            margin: EdgeInsets.all(20.0),
            // color: Colors.grey,
            height: h * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleProfile(
                  profileImage: image,
                  onPressed: () {
                    _uploadImageToSuperbase();
                    //_loadAssets();
                  },
                ),
                InputAppwrite(
                  controller: controllerName,
                  text: 'Enter your Name',
                  label: "Name",
                  message: "Name",
                ),
                // InputAppwrite(
                //   controller: controllerPhone,
                //   text: 'Enter your Phone Number',
                //   label: "Phone Number",
                //   message: "Phone Number",
                // ),
                ExtraButton(
                  writing2: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  skip: () async {


                    // if (image.isNotEmpty) {
                    //   await convertImage(images[0]);
                    //   update();
                    // } else {
              await update();
                    // }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircleProfile extends StatelessWidget {
  CircleProfile({
    this.profileImage,
    this.onPressed,
    super.key,
  });

  String? profileImage;
  void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 140.0,
          width: 140.0,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(80.0),
            child: CachedNetworkImage(
              imageUrl: profileImage ?? "",
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
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextButton(
              onPressed: onPressed ?? () {},
              child: Text(
                "Press to Update Image",
                style: TextStyle(fontSize: 15),
              )),
        )
      ],
    );
  }
}

class InputAppwrite extends StatelessWidget {
  InputAppwrite(
      {this.controller,
      this.onChanged,
      this.text,
      this.label,
      this.message,
      super.key});

  TextEditingController? controller;
  Function(String)? onChanged;
  String? label;
  String? text;
  String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            message ?? '',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        ForTextInput(
          controller: controller,
          onChanged: onChanged ?? (String) {},
          label: label,
          text: text,
        ),
      ],
    );
  }
}
