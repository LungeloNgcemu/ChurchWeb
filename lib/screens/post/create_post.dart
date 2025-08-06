import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../classes/church_init.dart';
import '../../componants/buttonChip.dart';
import '../../componants/overview.dart';
import '../../componants/tittle_head.dart';
import '../../models/model.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../componants/text_input.dart';
import 'package:readmore/readmore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:master/providers/url_provider.dart';
import 'dart:io';
import 'package:master/models/model.dart';
import '../../models/comment_model.dart';
import '../../util/functions_for_cloud.dart';
import '../../componants/global_booking.dart';

// create_page and poster are linked
String postKey = '';

class Poster extends StatefulWidget {
  Poster({
    super.key,
  });

  @override
  State<Poster> createState() => _PosterState();
}

class _PosterState extends State<Poster> {
  bool isLoading = false;
  final ImagePickerCustom _picker = ImagePickerCustom();
  ChurchInit churchStart = ChurchInit();
  Authenticate auth = Authenticate();

  Uint8List? _image;
  String? npostKey;

  // Change PickedFile to XFile
  String? postImageUrl;

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImageToByte();
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String? imageUrl;

  Future<void> _uploadImageToSuperbase(image) async {
    try {
      print('Image picked');
      if (image != null) {
        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .uploadBinary(fileName, image,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));

        final publicUrl = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .getPublicUrl(fileName);

        setState(() {
          imageUrl = publicUrl;
        });
      } else {}
    } catch (e) {
      log("Error uploading image to Supabase: $e");
    }
  }

  void superbasePost(String Des, String img) async {
    await supabase.from('Posts').insert({
      'Description': Des,
      'ImageUrl': img,
      'Church': Provider.of<christProvider>(context, listen: false)
          .myMap['Project']?['ChurchName']
    });
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        // color: Colors.yellow,
        height: h * 0.75,
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Create Post",
                          style: TextStyle(fontSize: 30.0),
                        )),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[100]),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: EnterText(
                        height: 50.0,
                        text: "Description",
                        inText: "Enter description",
                        controller: descriptionController,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NewButton(
                        inSideChip: "Load Image for Post",
                        where: () {
                          setState(() {
                            _pickImage();
                          });
                        },
                      ),
                      ImageFrame(
                        image: _image,
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: NewButton(
                          inSideChip: "Create Post",
                          where: () async {
                            // Show a loading overlay/modal with CircularProgressIndicator

                            // Rebuild the widget to show CircularProgressIndicator
                            setState(() {
                              isLoading = true;
                            });

                            final description = descriptionController.text;

                            try {
                              if (_image == null) {
                                const message = "Please select an image";
                                alertSuccess(context, message);
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              } else if (description == "") {
                                const message =
                                    "Please fill in the description";
                                alertSuccess(context, message);
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              } else {
                                await _uploadImageToSuperbase(_image);
                                superbasePost(description, imageUrl!);

                                PushNotifications.sendMessageToTopic(
                                    topic: Provider.of<christProvider>(context,
                                            listen: false)
                                        .myMap['Project']?['ChurchName'],
                                    title: 'Post',
                                    body: description);

                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });

                                titleController.clear();
                                descriptionController.clear();
                                Navigator.of(context).pop();
                              }
                            } catch (error) {
                              // Clear text controllers and close the loading overlay/modal
                              // Close the AlertDialog
                              const message = "Something went wrong";
                              alertSuccess(context, message);
                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  // Semi-transparent overlay
                  child: const Center(
                    child: SizedBox(
                      height: 100.0,
                      width: 100.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ImageFrame extends StatefulWidget {
  const ImageFrame({this.image, Key? key}) : super(key: key);

  final dynamic image;

  @override
  _ImageFrameState createState() => _ImageFrameState();
}

class _ImageFrameState extends State<ImageFrame> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: 145.0,
        width: 145.0,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: _buildImage(widget.image),
      ),
    );
  }

  Widget _buildImage(dynamic image) {
    if (image == null) {
      return Container(); // You can use a placeholder here
    }

    if (image != null) {
      return Image.memory(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250.0,
      );
    } else {
      return SizedBox();
    }
  }
}

class EnterText extends StatelessWidget {
  const EnterText({
    this.height,
    this.text,
    this.inText,
    this.controller, // Add this line
    Key? key,
  }) : super(key: key);

  final double? height;
  final String? text;
  final String? inText;
  final TextEditingController? controller; // Add this line

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: height!,
                  child: TextField(
                    controller: controller,
                    // Add this line
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                          left: 8.0, bottom: 8.0, top: 8.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      // filled: true,
                      hintText: inText ?? "",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
