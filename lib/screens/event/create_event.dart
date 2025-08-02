import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_calendar/flutter_event_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/snack_bar.dart';
import 'package:master/componants/tittle_head.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../classes/calender_class.dart';
import '../../classes/church_init.dart';
import '../../componants/buttonChip.dart';
import 'package:image_picker/image_picker.dart' as p;
import 'dart:io';

import '../../providers/url_provider.dart';
import '../../componants/global_booking.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../../../classes/message_class.dart';

// create_page and poster are linked
class CreateEvent extends StatefulWidget {
  CreateEvent({
    super.key,
  });

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  bool isLoading = false;

  Map<String, dynamic> currentUser = {};

  MessageClass userClass = MessageClass();
  Calender calenderClass = Calender();
  final ImagePickerCustom _picker = ImagePickerCustom();
  SnackBarNotice snack = SnackBarNotice();
  Authenticate auth = Authenticate();

  Uint8List? _image;
  String? npostKey;
  String? imageUrl;
  bool isGood = false;
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

        await Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            imageUrl = publicUrl;
            isGood = true;
          });
        });
      } else {
        const message = "No image selected";
        snack.snack(context, message);
      }
    } catch (e) {
      const message = "Please Remane Your Picture";
      setState(() {
        isLoading = false;
      });
      alertSuccess(context, message);

      print("Error uploading image to Supabase: $e");
    }
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    currentUser = userClass.currentUser;

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  CalendarDateTime? selectedDate;

  void _onDateChanged(CalendarDateTime date) {
    setState(() {
      selectedDate = date;
    });
    print("Selected date: ${date.year}-${date.month}-${date.day}");
  }

  TextEditingController tittleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String SelectedDay = "";

  Future<void> superbaseEvent(tittle, description, date, image) async {
    print('Inserting Event');

    print('$tittle, $description, $date');

    try {
      await supabase.from('Events').insert({
        'Title': tittle,
        'Description': description,
        'Day': date,
        'ChurchName': Provider.of<christProvider>(context, listen: false)
            .myMap['Project']?['ChurchName'],
        'Image': image,
      });
    } catch (error) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  String convertMonth(String string) {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    var month = int.parse(string);

    final formattedMonth = "${months[month - 1]}";

    return formattedMonth;
  }

  @override
  Widget build(BuildContext context) {
    String selectedOption =
        Provider.of<SelectedOptionProvider>(context).selectedOption;
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: h * 0.79,
          // color: Colors.yellow,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 40.0, left: 10.0, right: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                          alignment: Alignment.center,
                          child: const Text(
                            "Create Event",
                            style: TextStyle(fontSize: 30.0),
                          )),
                    ),
                    calenderClass.calenderReturn(
                        _onDateChanged, context, setState),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 40.0),
                              child: Column(
                                children: [
                                  EnterText(
                                    height: 50.0,
                                    text: "Title",
                                    inText: "Create Title",
                                    controller: tittleController,
                                  ),
                                  EnterText(
                                    height: 50.0,
                                    text: "Description",
                                    inText: "Create Description",
                                    controller: descriptionController,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // color: Colors.red,
                            height: h * 0.3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: w * 0.4,
                                    margin:
                                        EdgeInsets.symmetric(vertical: 20.0),
                                    child: ImageFrame(
                                      image: _image,
                                    ),
                                  ),
                                ),
                                NewButton(
                                  inSideChip: "Choose Image ",
                                  where: () {
                                    setState(() {
                                      _pickImage();
                                    });

                                    /// Update state variables here
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: NewButton(
                            inSideChip: "Create Event",
                            where: () async {
                              FocusScope.of(context).unfocus();

                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  isLoading = true;
                                });
                              });

                              final year = Provider.of<SelectedDateProvider>(
                                      context,
                                      listen: false)
                                  .selectedDate["Year"];
                              final month = Provider.of<SelectedDateProvider>(
                                      context,
                                      listen: false)
                                  .selectedDate["Month"];
                              final day = Provider.of<SelectedDateProvider>(
                                      context,
                                      listen: false)
                                  .selectedDate["Day"];

                              print("Month $month");

                              final tittle = tittleController.text;
                              final description = descriptionController.text;

                              print(
                                  " title : $tittle,  description : $description");

                              try {
                                if (_image == null) {
                                  const message = "Please select an Image";
                                  alertSuccess(context, message);
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                } else if (tittle == "" || description == "") {
                                  const message = "Please fill in everything";
                                  alertSuccess(context, message);
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                } else if (month == null) {
                                  const message = "Please select a day";
                                  alertSuccess(context, message);
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                } else {
                                  await _uploadImageToSuperbase(_image);

                                  print("isGood status : $isGood");

                                  if (isGood == true) {
                                    final nameMonth = convertMonth(month);

                                    final date = "$year $nameMonth $day";
                                    print("$year $nameMonth $day");

                                    await superbaseEvent(
                                        tittle ?? "no title",
                                        description ?? "no description",
                                        date,
                                        imageUrl);

                                    setState(() {
                                      isLoading = false;
                                      isGood = false;
                                    });

                                    tittleController.clear();
                                    descriptionController.clear();

                                    Navigator.of(context).pop();
                                  }
                                }
                              } catch (error) {
                                print("refresh erroe $error");
                                const message =
                                    "Please refresh page and try again";
                                alertSuccess(context, message);
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              } // Close the AlertDialog
                            },
                          ),
                        ),
                      ],
                    ),
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
        height: 50.0,
        width: 50.0,
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
      return SizedBox(); // Handle other cases if needed
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



// class ImageFrame extends StatefulWidget {
//   ImageFrame({this.image, Key? key}) : super(key: key);
//
//   final dynamic image;
//
//   @override
//   _ImageFrameState createState() => _ImageFrameState();
// }
//
// class _ImageFrameState extends State<ImageFrame> {
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.0),
//       child: Container(
//         height: 145.0,
//         width: 145.0,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(20.0),
//         ),
//         child: _buildImage(widget.image),
//       ),
//     );
//   }
//
//   Widget _buildImage(dynamic image) {
//     if (image == null) {
//       return Container(); // You can use a placeholder here
//     }
//
//     if (image is XFile) {
//       return Image.file(
//         File(image.path),
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: 250.0,
//       );
//     } else if (image is File) {
//       return Image.file(
//         image,
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: 250.0,
//       );
//     } else {
//       return Image.network(
//           "https://picsum.photos/seed/picsum/200/300"); // Handle other cases if needed
//     }
//   }
// }