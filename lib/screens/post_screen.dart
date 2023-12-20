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
import 'package:master/comment_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:master/poster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> documentStream =
      FirebaseFirestore.instance.collection('Posts').snapshots();

  @override
  void initState() {
    super.initState();
    Provider.of<BackImageUrlProvider>(context, listen: false)
        .loadImageUrlLocally();
    Provider.of<ProfileImageUrlProvider>(context, listen: false)
        .loadImageUrlLocally();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  XFile? _backImage; // Change PickedFile to XFile
  String? profileImageUrl;
  String? backImageUrl;

  Future<void> _profilePickImage() async {
    _profileImage =
        await _picker.pickImage(source: ImageSource.gallery) as XFile?;
    // Handle the picked image as needed
  }

  Future<void> _backPickImage() async {
    _backImage = await _picker.pickImage(source: ImageSource.gallery) as XFile?;
    // Handle the picked image as needed
  }

  Future<void> _uploadProfileImageToFirebase() async {
    try {
      await _profilePickImage();

      if (_profileImage != null) {
        File imageFile = File(_profileImage!.path);
        String fileName = path.basename(imageFile.path);

        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child("images")
            .child(fileName);

        var metadata = firebase_storage.SettableMetadata(
          contentType:
              'image/jpeg', // Set the correct content type based on your image type
        );

        await ref.putFile(imageFile, metadata);

        profileImageUrl = await ref.getDownloadURL(); // Update state variable
        Provider.of<ProfileImageUrlProvider>(context, listen: false).imageUrl =
            profileImageUrl;

        print("Image uploaded to Firebase: $_profileImage");

        setState(() {}); // Trigger a rebuild to update the UI
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error uploading image to Firebase: $e");
    }
  }

  Future<void> _uploadBackImageToFirebase() async {
    try {
      await _backPickImage();

      if (_backImage != null) {
        File imageFile = File(_backImage!.path);
        String fileName = path.basename(imageFile.path);

        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child("images")
            .child(fileName);

        var metadata = firebase_storage.SettableMetadata(
          contentType:
              'image/jpeg', // Set the correct content type based on your image type
        );

        await ref.putFile(imageFile, metadata);

        backImageUrl = await ref.getDownloadURL(); // Update state variable
        Provider.of<BackImageUrlProvider>(context, listen: false).imageUrl =
            backImageUrl;

        print("Image uploaded to Firebase: $backImageUrl");

        setState(() {}); // Trigger a rebuild to update the UI
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error  uploading image to Firebase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          SizedBox(
            height: 340,
            child: Stack(
              children: [
                Container(
                  height: 250,
                  color: Colors.red,
                  child: CachedNetworkImage(
                    imageUrl:
                        Provider.of<BackImageUrlProvider>(context).imageUrl!,
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
                    height: 250,
                    width: double.maxFinite,
                  ),
                ),
                Positioned(
                  top: 215.0,
                  left: 375.0,
                  child: GestureDetector(
                    onTap: () async {
                      await _backPickImage();
                      _uploadBackImageToFirebase();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.green,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(1.0),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 140.0,
                  left: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    height: 155.0,
                    width: 155.0,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 145.0,
                          width: 145.0,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: CachedNetworkImage(
                            imageUrl:
                                Provider.of<ProfileImageUrlProvider>(context)
                                        .imageUrl ??
                                    "https://picsum.photos/seed/picsum",
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                height: 40.0,
                                width: 40.0,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover,
                            height: 250,
                            width: double.maxFinite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 260,
                  left: 213,
                  child: Text(
                    "Classical Styling",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                ),
                Positioned(
                  top: 255.0,
                  left: 145.0,
                  child: GestureDetector(
                    onTap: () async {
                      await _profilePickImage();
                      _uploadProfileImageToFirebase();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.orange,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(1.0),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  color: Colors.orange,
                  onPressed: () {
                    // Navigator.pushNamed(context, '/products');
                    Navigator.pushNamed(context, '/create');
                  },
                  child: const Text('New Post'),
                ),
              ],
            ),
          ),
          //Divider is in the Padding
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Divider(
              color: Colors.black,
              height: 0.1,
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: documentStream,
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData ||
                    snapshot.data?.docs.isEmpty == true) {
                  return Text('No posts available.');
                } else {
                  final postsData = snapshot.data?.docs;

                  return SizedBox(
                    height: double.maxFinite,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: postsData?.length ?? 0,
                      itemBuilder: (context, index) {
                        final post = postsData?[index].data();
                        return SocialPost(
                          description: post?['description'] ?? '',
                          imageUrl: post?['imageUrl'] ?? '',
                          postId: post?['postId'] ?? '', // Pass the postId
                        );
                      },
                    ),
                  );
                }
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 100.0),
                  child: CircularProgressIndicator(),
                ); // Replace with your custom loading widget
              }
            },
          )
        ],
      ),
    );
  }
}

class SocialPost extends StatefulWidget {
  SocialPost({
    this.description,
    required this.imageUrl,
    this.postId, // Add postId as a parameter
    // this.comments = const [],
    Key? key,
  });

  String? description;
  String imageUrl;
  String? postId; // Declare postId as a field
  // final List<dynamic> comments;

  @override
  State<SocialPost> createState() => _SocialPostState();
}

class _SocialPostState extends State<SocialPost> {
  late PostIdProvider postIdProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    postIdProvider = Provider.of<PostIdProvider>(context, listen: false);
  }

  void uploadCommentFirestore(
      String username, String text, String postId) async {
    // Retrieve the current post ID from the PostIdProvider

    if (postId.isNotEmpty) {
      Comment newComment = Comment(
        username: username,
        text: text,
        timestamp: DateTime.now(),
      );

      FirebaseFirestore.instance
          .collection("Posts")
          .doc(postId)
          .collection("comments")
          .add({
        'username': newComment.username,
        'text': newComment.text,
        'timestamp': newComment.timestamp.toUtc().toIso8601String(),
      }).then((commentRef) {
        // Handle success if needed
        print('Comment added successfully with ID: ${commentRef.id}');
      }).catchError((error) {
        // Handle error if needed
        print('Error adding comment to Firestore: $error');
      });
    } else {
      print('Error: Post ID is empty. Make sure to add a post first.');
    }
  }

  CommentService commentService = CommentService();

  // String getaLastComment() {
  //   return widget.comments.isNotEmpty ? widget.comments.last : 'No Comment Available yet';
  // }
  String user = "Amber";
  String enteredText = '';

  bool isTextFieldVisible = false;
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // String lastComment = getaLastComment();
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        color: Colors.white,
        //gvgvjvhbhjbjhvjhvjhvjhvjh

        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      // widget.imageUrl,
                      Provider.of<ProfileImageUrlProvider>(context).imageUrl ??
                          '',
                    ),
                    maxRadius: 25,
                    backgroundColor: Colors.red,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Salon Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 15.0),
              child: Text(widget.description ?? ""),
            ),
            Container(
              color: Colors.green,
              height: 200.0,
              child: CachedNetworkImage(
                // will setup post image provider.
                imageUrl: widget.imageUrl!,
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
                // height: 250,
                width: double.maxFinite,
              ),
            ),
            Row(
              children: [
                IconButton.filled(
                    color: Colors.red,

                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: const Icon(Icons.favorite_border_rounded),
                    onPressed: () {
                      print("Pressed");
                    }),
                IconButton(
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: const FaIcon(FontAwesomeIcons.comments),
                    onPressed: () {
                      setState(() {
                        isTextFieldVisible = !isTextFieldVisible;
                        if (!isTextFieldVisible) {
                          // widget.comments.add(textEditingController.text);
                          // Do something meaningful with the entered text, e.g., send it
                          // print("Entered Text: $enteredText");
                          // Clear the text field for the next input
                          textEditingController.clear();
                        }
                      });
                    }),
                IconButton(
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: const FaIcon(FontAwesomeIcons.paperPlane),
                    onPressed: () {
                      print("Pressed");
                    }),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    color: Colors.orange,
                    Icons.delete,
                    size: 30.0,
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FaIcon(FontAwesomeIcons.comments),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Comments...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: isTextFieldVisible,
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: StreamBuilder<List<Comment>>(
                    stream: commentService.getCommentsStream(widget.postId!),
                    builder: (context, AsyncSnapshot<List<Comment>?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.data?.isEmpty == true) {
                          return Text('No comments available.');
                        } else {
                          final comments = snapshot.data!;
                          print(comments);

                          // Display comments for the specific post
                          return SizedBox(
                            height: 130.0,
                            child: ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                return CommentBubble(
                                    lastComment:
                                        comments[index].text.toString());
                              },
                            ),
                          );
                        }
                      } else {
                        return const Padding(
                          padding: EdgeInsets.only(top: 100.0),
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  )),
            ),
            Visibility(
              visible: isTextFieldVisible,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: TextField(
                        onSubmitted: (value) {
                          setState(() {
                            // widget.comments.add(value);
                            isTextFieldVisible = false;
                            // Do something meaningful with the entered text, e.g., send it
                            print("Comment: $enteredText");
                            // Clear the text field for the next input
                            textEditingController.clear();
                          });
                        },
                        controller: textEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            // for comments
                            final postIdProvider = Provider.of<PostIdProvider>(
                                context,
                                listen: false);
                            final postId = postIdProvider.postId;
                            uploadCommentFirestore(user,
                                textEditingController.text, widget.postId!);
                            isTextFieldVisible = false;
                            // Clear the text field for the next input
                            textEditingController.clear();
                          });
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentBubble extends StatelessWidget {
  const CommentBubble({
    super.key,
    required this.lastComment,
  });

  final String lastComment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.purple,
          ),
        ),
        Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('${lastComment}'),
          ),
        ),
      ],
    );
  }
}
