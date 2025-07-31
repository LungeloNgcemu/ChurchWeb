import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/componants/tittle_head.dart';
import 'package:master/util/alerts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart' as p;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../../classes/media_class.dart';
import '../../componants/buttonChip.dart';
import '../../providers/url_provider.dart';

// create_page and poster are linked
class MediaPoster extends StatefulWidget {
  MediaPoster({
    super.key,
  });

  @override
  State<MediaPoster> createState() => _MediaPosterState();
}

class _MediaPosterState extends State<MediaPoster> {
  @override
  void initState() {
    print("hello;");
    // TODO: implement initState
    super.initState();
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  MediaClass medaiClass = MediaClass();
  Authenticate auth = Authenticate();

  @override
  
  Widget build(BuildContext context) {
    String selectedOption =
        Provider.of<SelectedOptionProvider>(context).selectedOption;

    double h = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Container(
        height: h * 0.79,
        //color: Colors.yellow,
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 const  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Align(
                        alignment: Alignment.center,
                        child: const Text(
                          "Create Media Content",
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
                            text: "Title",
                            inText: "Enter Title",
                            controller: titleController,
                          ),
                          EnterText(
                            height: 50.0,
                            text: "Description",
                            inText: "Enter description",
                            controller: descriptionController,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[100]),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: EnterText(
                        height: 50.0,
                        text: "YOUTUBE URL ADDRESS",
                        inText: "Enter URL Link",
                        controller: urlController,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: NewButton(
                          inSideChip: "Post Content",
                          where: () async {
                            setState(() {
                              medaiClass.isLoading = true;
                            });
                            final title = titleController.text;
                            final description = descriptionController.text;
                            final url = urlController.text;

                            if (title == "" || description == "" || url == "") {
                              const message = "Please fill in everything";
                              alertSuccess(context, message);
                               setState(() {
                                medaiClass.isLoading = false;
                              }); 
                            } else {
                              await medaiClass.superbaseMedia(title,
                                  description, selectedOption, url, context);

                              setState(() {
                                medaiClass.isLoading = false;
                              });
                              titleController.clear();
                              descriptionController.clear();
                              urlController.clear();
                              Navigator.of(context).pop();
                            }

                            // Close the AlertDialog
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (medaiClass.isLoading)
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
