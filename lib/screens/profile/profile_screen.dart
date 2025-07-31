//import 'dart:html';

import 'dart:io' as f;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master/componants/adaptable_button.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/constants/constants.dart';
import 'package:master/databases/database.dart';
import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:master/util/alerts.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

import '../../classes/church_init.dart';
import '../../componants/overview.dart';
import '../../providers/url_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppWriteDataBase connect = AppWriteDataBase();
  ChurchInit churchStart = ChurchInit();

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
          .from('User')
          .select('ProfileImage, UserName')
          .eq('PhoneNumber', number)
          .single();

      currentUser = {
        "UserName": item["UserName"],
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

  Future<void> update() async {
    setState(() {
      isLoading = true;
    });
    await supabase
        .from('User')
        .update({'ProfileImage': image, 'UserName': controllerName.text}).match(
            {'PhoneNumber': number});

    setState(() {
      isLoading = false;
    });
  }

  List<Asset> images = <Asset>[];
  String _error = 'No Error Dectected';

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

  Future<void> _uploadImageToSuperbase() async {
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

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['Bucket'] ??
                "")
            .upload('$fileName', imageFile,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));
        print('Uploaded image path: $pathv');

        final publicUrl = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['Bucket'] ??
                "")
            .getPublicUrl(fileName);
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
        child: isLoading == true
            ? Center(child: CircularProgressIndicator())
            : Padding(
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
                        onPressed: () async {
                          await _uploadImageToSuperbase();
                          //_loadAssets();
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[100]),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: InputAppwrite(
                            keyboard: TextInputType.text,
                            controller: controllerName,
                            text: 'Enter your Name',
                            label: "Name",
                            message: "Name",
                          ),
                        ),
                      ),
                      // InputAppwrite(
                      //   controller: controllerPhone,
                      //   text: 'Enter your Phone Number',
                      //   label: "Phone Number",
                      //   message: "Phone Number",
                      // ),
                      Column(
                        children: [
                          ExtraButton(
                            writing2: const Text(
                              'Update',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            skip: () async {
                              // if (image.isNotEmpty) {
                              //   await convertImage(images[0]);
                              //   update();
                              // } else {
                              await update();
                              // }
                            },
                          ),
                          AdaptableButton(
                            color: Colors.red,
                            writing2: const Text(
                              'Logout',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            skip: () async {
                              setState(() {
                                isLoading = true;
                              });


                              alertLogout(context, 'Logout?');

                              setState(() {
                                isLoading = false;
                              });

                            },
                          ),
                        ],
                      ),
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
            color: Colors.grey[100],
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
      this.keyboard,
      super.key});

  TextEditingController? controller;
  Function(String)? onChanged;
  String? label;
  String? text;
  String? message;
  TextInputType? keyboard;

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
          keyboard: keyboard,
        ),
      ],
    );
  }
}
