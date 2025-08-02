import 'package:flutter/material.dart';
import 'package:master/componants/tittle_head.dart';
import '../../classes/church_init.dart';
import '../../classes/minister_class.dart';
import '../../componants/global_booking.dart';
import '../../componants/overview.dart';

import '../../componants/buttonChip.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateMinister extends StatefulWidget {
  const CreateMinister({super.key});

  @override
  State<CreateMinister> createState() => _CreateMinisterState();
}

class _CreateMinisterState extends State<CreateMinister> {
  String? specialistId;

  bool isLoading = false;
  TextEditingController workController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  MinisterClass ministerClass = MinisterClass();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Container(
          color: Colors.white,
          height: h * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Create Minister",
                        style: TextStyle(fontSize: 30.0),
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[100]),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Column(
                      children: [
                        EnterText(
                          height: 50.0,
                          text: "Ministery Work",
                          inText: "Enter Title",
                          controller: workController,
                        ),
                        EnterText(
                          height: 50.0,
                          text: "Name and Surname",
                          inText: " Enter Name and Surname",
                          controller: nameController,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NewButton(
                      inSideChip: "Load Image",
                      where: () async {
                        await ministerClass.uploadImageToSuperbase(
                            context, setState);

                        /// Update state variables here
                      },
                    ),
                    ImageFrame(
                      image: ministerClass.xImage,
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: NewButton(
                        inSideChip: "Create Minister",
                        where: () async {
                          // Show a loading overlay/modal with CircularProgressIndicator

                          // Rebuild the widget to show CircularProgressIndicator
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            await ministerClass.uploadMinister(
                                nameController.text,
                                workController.text,
                                ministerClass.image,
                                context);
                          } finally {
                            // Clear text controllers and close the loading overlay/modal
                            workController.clear();
                            nameController.clear();
                            Navigator.of(context)
                                .pop(); // Close the AlertDialog
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
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
      return Image.network(
          "https://picsum.photos/seed/picsum/200/300"); // Handle other cases if needed
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
                      //  filled: true,
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
