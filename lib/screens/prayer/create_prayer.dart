import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master/classes/prayer_class.dart';
import 'package:master/componants/tittle_head.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../classes/church_init.dart';
import '../../componants/buttonChip.dart';
import 'package:image_picker/image_picker.dart' as p;
import 'dart:io';
import '../../componants/overview.dart';
import '../../util/functions_for_cloud.dart';
import '../../providers/url_provider.dart';
import '../../componants/global_booking.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../../../classes/message_class.dart';
import 'package:intl/intl.dart';

// create_page and poster are linked
class CreatePrayer extends StatefulWidget {
  CreatePrayer({
    super.key,
  });

  ScrollController? controller;
  @override
  State<CreatePrayer> createState() => _CreatePrayerState();
}

class _CreatePrayerState extends State<CreatePrayer> {
  bool isLoading = false;

  Map<String, dynamic> currentUser = {};

  MessageClass userClass = MessageClass();

  Prayer prayerClass = Prayer();

  void user() async {
    currentUser = await userClass.getCurrentUser(context);
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });

    user();
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  TextEditingController prayerController = TextEditingController();

  Future<void> superbaseProduct(
      prayer, userName, userId, phoneNumber, image) async {

final formattedDate = prayerClass.convertDate();



    await supabase.from('Prayers').insert({
      'Name': userName,
      'UserId': userId,
      'PhoneNumber': phoneNumber,
      'Prayer': prayer.toString(),
      "Date": formattedDate,
      'Status': "Praying",
      'Image': image,
      'Church': Provider.of<christProvider>(context, listen: false)
              .myMap['Project']?['ChurchName'] ??
          ""
    });
  }

  @override
  Widget build(BuildContext context) {
    String selectedOption =
        Provider.of<SelectedOptionProvider>(context).selectedOption;
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: SingleChildScrollView(
        controller: widget.controller,
        child: Container(
          height: h * 0.8,
          // color: Colors.yellow,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 40.0, left: 10.0, right: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                          alignment: Alignment.center,
                          child: const Text(
                            "Create Prayer",
                            style: TextStyle(fontSize: 30.0),
                          )),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: EnterText(
                          height: 50.0,
                          text: "Prayer",
                          inText: "Enter Prayer",
                          controller: prayerController!,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: NewButton(
                            inSideChip: "Create Prayer",
                            where: () async {
                              setState(() {
                                isLoading = true;
                              });

                              final prayer = prayerController.text;

                              await superbaseProduct(
                                  prayer,
                                  currentUser['UserName'],
                                  currentUser['UserId'],
                                  currentUser['PhoneNumber'],
                                  Provider.of<CurrentUserImageProvider>(context,
                                          listen: false)
                                      .currentUserImage);

                              setState(() {
                                isLoading = false;
                              });

                              prayerController.clear();

                              Navigator.of(context)
                                  .pop(); // Close the AlertDialog
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
      ),
    );
  }
}

class ImageFrame extends StatefulWidget {
  ImageFrame({this.image, Key? key}) : super(key: key);

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

    if (image is p.XFile) {
      return Image.file(
        File(image.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250.0,
      );
    } else if (image is File) {
      return Image.file(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250.0,
      );
    } else {
      return Image.network(
          "https://picsum.photos/seed/picsum/200/300"); // Handle other cases if needed
    }
  }
}

class EnterText extends StatefulWidget {
  EnterText({
    this.height,
    this.text,
    this.inText,
    required this.controller, // Add this line
    Key? key,
  }) : super(key: key);

  final double? height;
  final String? text;
  final String? inText;
  final TextEditingController? controller;
  @override
  State<EnterText> createState() => _EnterTextState();
}

class _EnterTextState extends State<EnterText> {
  // Add this line
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.text!,
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
                  height: widget.height!,
                  child: TextField(
                    controller: widget.controller!,
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
                      hintText: widget.inText ?? "",
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
