import 'package:flutter/material.dart';
import 'componants/buttonChip.dart';
import 'model.dart';
import 'package:path_provider/path_provider.dart';
import 'url_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../componants/text_input.dart';
import 'package:readmore/readmore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:master/url_provider.dart';
import 'dart:io';
import 'package:master/model.dart';
import 'comment_model.dart';
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
  final ImagePicker _picker = ImagePicker();

  XFile? _image;

  // Change PickedFile to XFile
  String? postImageUrl;

  // Future<void> _pickImage() async {
  //   _image = await _picker.pickImage(source: ImageSource.gallery) as XFile?;
  //   // Handle the picked image as needed
  //   debugPrint('Image path: ${_image?.path}');
  // }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<String> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("images")
          .child("${DateTime.now().millisecondsSinceEpoch}");

      var metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
      );

      await ref.putFile(imageFile, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return ''; // Return an empty string or handle the error accordingly
    }
  }

  @override
  void initState() {
    super.initState();
    getPostsFromFirebase();
  }

  Future<String> addPostToFirebase(Post post) async {
    try {
      DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('posts');

      // Upload image to Firebase Storage and get download URL
      String postImageUrl =
          await uploadImageToFirebaseStorage(File(_image!.path));
      Provider.of<PostImageUrlProvider>(context, listen: false).imageUrl =
          postImageUrl;
      debugPrint("this is it :" + postImageUrl);

      // Add post data to Firebase Realtime Database
      await reference.push().set({
        'title': post.title,
        'description': post.description,
        'imageUrl': postImageUrl,
        'comments':post.comments,
      });
      final  newPostKey =
          await FirebaseDatabase.instance.ref().child('posts').push().key;

      print('Post added to Firebase successfully! ${newPostKey}',);

      return newPostKey ?? "";
    } catch (e) {
      print('Error adding post to Firebase: $e');
      return "";
    }
  }

  TextEditingController titleController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
                  'Create Post',
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
            text: "Title",
            inText: "Enter Title",
            controller: titleController,
          ),
          EnterText(
            height: 150.0,
            text: "Description",
            inText: "Enter description",
            controller: descriptionController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NewButton(
                inSideChip: "Load Image for Post",
                where: () {
                  _pickImage();

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
                inSideChip: "Post",
                where: () async {
                  // Handle submission here
                  // Post post = Post(
                  //   description: descriptionController.text,
                  //   imageUrl: Provider.of<ImageUrlProvider>(context).imageUrl ??
                  //       "", // Replace with your image URL or handle image upload separately
                  // );

                  Post post = Post(
                    title: titleController.text,
                    description: descriptionController.text,
                    imageUrl: Provider.of<PostImageUrlProvider>(context,
                                listen: false)
                            .imageUrl ??
                        "https://picsum.photos/seed/picsum",
                  comments: [],
                  );
                  // Call a function to upload the post data to Firebase
                  final  neWPostKey = await addPostToFirebase(post);
                  debugPrint("this is it again"+ neWPostKey.toString());
                },
              )),
            ],
          )
        ],
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
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      filled: true,
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
