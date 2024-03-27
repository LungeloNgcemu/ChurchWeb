import 'package:flutter/material.dart';
import 'componants/global_booking.dart';
import 'poster.dart';
import 'componants/buttonChip.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'functions_for_cloud.dart';
import 'specialist_modal.dart';
import 'package:master/url_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// THIS HAS TO BE UNIVERSAL!!!!!!

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String? specialistId;
  String image = '';

  bool isLoading = false;
  TextEditingController workController = TextEditingController();
  TextEditingController nameController = TextEditingController();

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

  void addId(String specialistId) async {
    try {
      // Reference to the post document
      DocumentReference postDocRef =
          FirebaseFirestore.instance.collection("Specialist").doc(specialistId);

      // Update the post with the post ID
      await postDocRef.update({
        'specialistId': specialistId,
      });

      print('Specialist ID updated successfully!');
    } catch (e) {
      print('Error updating post ID: $e');
      // Handle the error accordingly
    }
  }

  Future<String> addPostToFirestore(Specialist special) async {
    try {
      String postImageUrl =
          await uploadImageToFirebaseStorage(File(_image!.path));
      Provider.of<PostImageUrlProvider>(context, listen: false).imageUrl =
          postImageUrl;
      debugPrint("this is it :" + postImageUrl);

      DocumentReference postRef =
          await FirebaseFirestore.instance.collection("Specialist").add({
        'name': special.name,
        'work': special.work,
        'image': postImageUrl,
      });

      final newPostKey = postRef.id;

      print('Specialist added to Firestore successfully! ${newPostKey}');

      return newPostKey;
    } catch (e) {
      print('$e');
      return "";
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


 Future <void> uploadSpecialist(String name,String work,String image) async {
    await supabase .from('Specialist')
        .insert({'Name': name, 'Work': work,'Image': image,});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        height: 50.0,
                        width: 50.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Create Specialsit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 23.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  EnterText(
                    height: 50.0,
                    text: "Work Title",
                    inText: "Enter Title",
                    controller: workController,
                  ),
                  EnterText(
                    height: 50.0,
                    text: "Name and Surname",
                    inText: " Enter Name and Surname",
                    controller: nameController,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NewButton(
                        inSideChip: "Load Image",
                        where: () async {

                            await _uploadImageToSuperbase();


                          /// Update state variables here
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
                          inSideChip: "Create Specialist",
                          where: () async {
                            // Show a loading overlay/modal with CircularProgressIndicator

                            // Rebuild the widget to show CircularProgressIndicator
                            setState(() {
                              isLoading = true;
                            });

                            try {
                        await uploadSpecialist( nameController.text,workController.text,image);
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
          color: Colors.green,
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

    if (image is XFile) {
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
