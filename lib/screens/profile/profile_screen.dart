import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/Model/user_details_model.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/componants/adaptable_button.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/databases/database.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/services/api/user_service.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../../classes/church_init.dart';
import '../../providers/url_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppWriteDataBase connect = AppWriteDataBase();
  ChurchInit churchStart = ChurchInit();
  PushNotifications push = PushNotifications();

  @override
  void initState() {
    xgetUser();
    getNotificationValue();
    super.initState();
  }

  bool isLoading = false;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPhone = TextEditingController();
  String image = '';

  Map<String, dynamic> currentUser = {};
  String docId = "";
  String number = "";
  bool notificationMessage = false;
  bool notificationPost = false;

  void xgetUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      TokenUser? user = await TokenService.tokenUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      setState(() {
        number = user.phoneNumber ?? '';
      });

      if (number.isEmpty) {
        throw Exception('User phone number not found');
      }

      UserDetails? userDetails = await UserService.getUserData(
          user.phoneNumber!, user.uniqueChurchId!);

      if (userDetails == null) {
        throw Exception('User details not found');
      }

      currentUser = {
        "UserName": userDetails?.userName,
        "ProfileImage": userDetails?.profileImage,
      };

      print(currentUser["ProfileImage"]);
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

  Future<bool> updateNotification(bool value) async {
    setState(() {
      isLoading = true;
    });

    TokenUser? user = await TokenService.tokenUser();

    String? churchName = user?.uniqueChurchId;

    if (churchName == null) {
      setState(() {
        isLoading = false;
      });
      return false;
    }

    try {
      if (value) {
        return PushNotifications.subscribeToChurchTopic(churchName!)
            .then((bool value) {
          setState(() {
            isLoading = false;
          });
          return value;
        });
      } else {
        return PushNotifications.unsubscribeFromChurchTopic(churchName!)
            .then((bool value) {
          setState(() {
            isLoading = false;
          });
          return value;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      return false;
    }
  }

  Future<void> getNotificationValue() async {
    String? name = await PushNotifications.getCurrentTopic();
    if (name != null) {
      notificationMessage = true;
      notificationPost = true;
    } else {
      notificationMessage = false;
      notificationPost = false;
    }
  }

  final ImagePickerCustom _picker = ImagePickerCustom();
  Uint8List? _image;

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImageToByte();
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

      if (_image != null) {
        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['Bucket'] ??
                "")
            .updateBinary(fileName, _image!,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));

        final publicUrl = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['Bucket'] ??
                "")
            .getPublicUrl(fileName);

        setState(() {
          image = publicUrl;
          isLoading = false;
        });

        log('Image Achieved');
      } else {
        setState(() {
          isLoading = false;
        });
        log("No image selected");
      }
    } catch (e) {
      log("Error uploading image to Supabase: $e");
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          NotificationSwitch(
                            value: notificationMessage,
                            title: 'Notifications',
                            onChanged: (bool e) async {
                              bool result = await updateNotification(e);
                              if (result) {
                                setState(() {
                                  notificationMessage = e;
                                  notificationPost = e;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      CircleProfile(
                        profileImage: image,
                        onPressed: () async {
                          await _uploadImageToSuperbase();
                          //_loadAssets();
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.2,
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

// ignore: must_be_immutable
class NotificationSwitch extends StatelessWidget {
  NotificationSwitch({super.key, this.onChanged, this.title, this.value});
  bool? value;
  String? title;
  void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title ?? ''),
        Switch(value: value ?? false, onChanged: onChanged),
      ],
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
          child: ClipOval(
            child: Image.network(
              profileImage ?? '',
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person,
                    color: Colors.white); // fallback
              },
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
