import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'package:master/componants/global_booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


StreamBuilder xbuildStreamBuilder(context, String path) {
  double h = MediaQuery.of(context).size.height;

  return StreamBuilder(
    stream: supabase.from('DisplayImages').stream(primaryKey: ['id']),
    builder: (context, snapshot) {


      if(snapshot.connectionState == ConnectionState.active){

        if (snapshot.hasError) {
          // Handle errors
          print("Error: ${snapshot.error}");
          return Text("Error: ${snapshot.error}");
        }

        final imageUrl = snapshot.data[0]?['$path'];
        print('URL HERE>>> $imageUrl');
        https://subejxnzdnqyovwhinle.supabase.co/storage/v1/object/public/SalonStorage/public/IMG_20240322_135240.jpg

        return Container(
          height: h * 0.3,
          child: CachedNetworkImage(
            imageUrl: imageUrl ?? 'https://picsum.photos/seed/picsum/200/300',
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
        );
      }
      return SizedBox();

    },
  );
}

Future<void> uploadForSalon(String path, image) async {
  try {
    await FirebaseFirestore.instance.collection(path).add({
      'image': image,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("image loaded to firebase forsestore");
  } catch (error) {
    print(error);
  }
}

Stream<String?> getForSalon(String collectionPath) {
  return FirebaseFirestore.instance
      .collection(collectionPath)
      .orderBy('timestamp',
          descending:
              true) // Replace 'timestamp' with your actual timestamp field
      .snapshots()
      .map((querySnapshot) {
    final List<String?> imageUrlList =
        querySnapshot.docs.map((doc) => doc['image'] as String?).toList();

    return imageUrlList.isNotEmpty ? imageUrlList.first : null;
  });
}

StreamBuilder<String?> buildStreamBuilder(context, String collectionPath) {
  double h = MediaQuery.of(context).size.height;

  return StreamBuilder<String?>(
    stream: getForSalon(collectionPath),
    builder: (context, AsyncSnapshot<String?> snapshot) {
      if (snapshot.hasError) {
        // Handle errors
        print("Error: ${snapshot.error}");
        return Text("Error: ${snapshot.error}");
      }

      final imageUrl = snapshot.data ?? "https://picsum.photos";
      print("This is the image: $imageUrl");

      return Container(
        height: h * 0.3,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
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
      );
    },
  );
}



class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

Stream? streamx;

void streamDelegate(){
  streamx = superbasePost();
}
 Stream superbasePost()  {
    return  supabase.from('Posts')
        .stream(primaryKey: ['id']).order('id', ascending: false);
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> documentStream =
      FirebaseFirestore.instance.collection('Posts').snapshots();

  @override
  void initState() {
    super.initState();
    streamDelegate();
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

  Future<String> _uploadProfileImageToFirebase() async {
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
        // Provider.of<ProfileImageUrlProvider>(context, listen: false).imageUrl =
        //   profileImageUrl;

        print("Image uploaded to Firebase: $_profileImage");

        return profileImageUrl!;
      } else {
        print("No image selected");
        return "";
      }
    } catch (e) {
      return "";
      print("Error uploading image to Firebase: $e");
    }
  }

  Future<String> _uploadBackImageToFirebase() async {
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
        // Provider.of<BackImageUrlProvider>(context, listen: false).imageUrl =
        //   backImageUrl;
        return backImageUrl!;

        print("Image uploaded to Firebase: $backImageUrl");

        setState(() {}); // Trigger a rebuild to update the UI
      } else {
        return "";
        print("No image selected");
      }
    } catch (e) {
      return "";
      print("Error  uploading image to Firebase: $e");
    }
  }

  // Stream<QuerySnapshot> getForSalon (String path) {
  //   return FirebaseFirestore.instance
  //       .collection(path)
  //       .snapshots();
  // }

  // StreamBuilder<String> buildStreamBuilder(String collectionPath) {
  //   return StreamBuilder<String>(
  //     stream: getForSalon(collectionPath),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         return snapshot.data!;
  //       } else if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       } else {
  //         return Text('Loading...');
  //       }
  //     },
  //   );
  // }
  //
  //
  // Stream<String> myStreamBuilder(String collectionPath) {
  //   return FirebaseFirestore.instance.collection(collectionPath).snapshots().map(
  //         (QuerySnapshot snapshot) {
  //       if (snapshot.docs.isNotEmpty) {
  //         return snapshot.docs.first['image'] ?? 'No image found';
  //       } else {
  //         return 'No documents found';
  //       }
  //     },
  //   );
  // }


XFile? _image; // Change PickedFile to XFile
String? imageUrl;

Future<void> _pickImage() async {
  _image = await _picker.pickImage(source: ImageSource.gallery) as XFile?;
  // Handle the picked image as needed
}

void _uploadImageToSuperbase(String where) async {
  try {
    await _pickImage();
    print('Image picked');
    if (_image != null) {
      final imageFile = File(_image!.path);
      final fileName = path.basename(imageFile.path);
      print('File picked: $fileName');

      final String pathv = await supabase.storage
          .from('SalonStorage')
          .upload('$fileName', imageFile,
          fileOptions: const FileOptions(
              cacheControl: '3600', upsert: false));
      print('Uploaded image path: $pathv');

      final publicUrl = await supabase.storage
          .from('SalonStorage')
          .getPublicUrl(fileName);
      print('Public URL: $publicUrl');

      https://subejxnzdnqyovwhinle.supabase.co/storage/v1/object/public/SalonStorage/public/IMG_20240322_135240.jpg

      //Upload to the Image table
      await supabase.from('DisplayImages').upsert({ 'id': 1 ,'$where': publicUrl});
      print('Image inserted into DisplayImages table');
    } else {
      print("No image selected");
    }
  } catch (e) {
    print("Error uploading image to Supabase: $e");
  }
}



void superbaseDeletePost(id) async {
  await supabase
      .from('Posts')
      .delete()
      .match({ 'id': id });
}
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      slivers: [
        SliverAppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
          ],
          backgroundColor: Colors.white,
          //pinned: true,
          expandedHeight: 300,
          flexibleSpace: FlexibleSpaceBar(
            // title: Text(
            //   'Classic Styling',
            //   style: TextStyle(color: Colors.black),
            // ),
            background: Stack(
              children: [
                Container(
                  height: 250,
                  color: Colors.red,
                  child: xbuildStreamBuilder(context, "BackImage"),
                ),
                Positioned(
                  top: 215.0,
                  left: 375.0,
                  child: GestureDetector(
                    onTap: () async {
                      _uploadImageToSuperbase("BackImage");
                      // await _backPickImage();
                      // final backImage = await _uploadBackImageToFirebase();
                      // uploadForSalon("BackImage", backImage);
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
                          child: xbuildStreamBuilder(context, "ProfileImage"),
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 260,
                  left: 213,
                  child: FittedBox(
                    child: Text(
                      "Classical Styling",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 255.0,
                  left: 145.0,
                  child: GestureDetector(
                    onTap: () async {
                      _uploadImageToSuperbase("ProfileImage");
                      // await _profilePickImage();
                      // final profileImage =
                      //     await _uploadProfileImageToFirebase();
                      // uploadForSalon("ProfileImage", profileImage);
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
        ),


        StreamBuilder(
          stream: streamx,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData ||
                  snapshot.data.isEmpty == true) {
                return SliverToBoxAdapter(
                  child: Text('No posts available.'),
                );
              } else {
               // final postsData = snapshot.data?.docs;

                final listDoc = snapshot.data;
                print('THIS IS SATA : $listDoc');
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                     // final post = listDoc?[index].data();
                      return SocialPost(
                        description: listDoc[index]['Description'] ?? '',
                        imageUrl: listDoc[index]['ImageUrl'] ?? '',
                        postId: listDoc[index]['id'].toString() ?? '',
                        onPressedDelete: (){
                          superbaseDeletePost(listDoc[index]['id']);
                        },
                      );
                    },
                    childCount:listDoc.length ?? 0,
                  ),
                );
              }
            } else {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 130.0),
                  child: Center(child: Text("Loading...")),
                ),
              );
            }
          },
        )
      ],
    );

    // SizedBox(
    //   height: 300,
    // ),
    //
    // //Divider is in the Padding
    // const Padding(
    //   padding: EdgeInsets.symmetric(horizontal: 15.0),
    //   child: Divider(
    //     color: Colors.black,
    //     height: 0.1,
    //   ),
    // ),
  }
}

class SocialPost extends StatefulWidget {
  SocialPost({
    this.description,
    required this.imageUrl,
    this.postId,
    this.onPressedDelete,// Add postId as a parameter
    // this.comments = const [],
    Key? key,
  });

  String? description;
  String imageUrl;
  String? postId;
  VoidCallback? onPressedDelete;
  // Declare postId as a field
  // final List<dynamic> comments;

  @override
  State<SocialPost> createState() => _SocialPostState();
}

class _SocialPostState extends State<SocialPost> {
  late PostIdProvider postIdProvider;

  @override
  void initState() {

    streamCommentDelegate(widget.postId);
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    postIdProvider = Provider.of<PostIdProvider>(context, listen: false);
  }

  void delete(postId) {
    FirebaseFirestore.instance.collection("Posts").doc(postId).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
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

  String user = "Amber";
  String enteredText = '';

  bool isTextFieldVisible = false;
  TextEditingController textEditingController = TextEditingController();

  void superbaseComment(String text, String postId) async {
    await supabase
        .from('Comments')
        .insert({'UserName': 'Lungelo', 'Text': text, 'PostId': postId});
  }

  Stream? streamComment;

  void streamCommentDelegate(postId){
    streamComment = superbaseCommentStream(postId);
  }
  Stream superbaseCommentStream(postId)  {
    return  supabase.from('Comments')
        .stream(primaryKey: ['id'])..eq('PostId',postId).order('id', ascending: false);
  }


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
                    maxRadius: 25,
                    backgroundColor: Colors.red,
                    child: ClipOval(
                      child: xbuildStreamBuilder(context, "ProfileImage"),
                    ),
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
              height: 280.0,
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
                // IconButton.filled(
                //     color: Colors.red,
                //
                //     // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                //     icon: const Icon(Icons.favorite_border_rounded),
                //     onPressed: () {
                //       print("Pressed");
                //     }),
                IconButton(
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: const FaIcon(FontAwesomeIcons.comments),
                    onPressed: () {
                      setState(() {
                        isTextFieldVisible = !isTextFieldVisible;
                        if (!isTextFieldVisible) {
                          textEditingController.clear();
                        }
                      });
                    }),
                IconButton(
                  onPressed: widget.onPressedDelete ?? (){},
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
                  child: Text(
                    'Comments...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FaIcon(FontAwesomeIcons.comments),
                ),
              ],
            ),
            Visibility(
              visible: isTextFieldVisible,
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: StreamBuilder(
                    stream:streamComment,
                    builder: (context, snapshot) {
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
                                        comments[index]['Text']);
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
                      child: SizedBox(
                        height: 50.0,
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
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            // for comments
                            // final postIdProvider = Provider.of<PostIdProvider>(
                            //     context,
                            //     listen: false);
                            // final postId = postIdProvider.postId;
                            // uploadCommentFirestore(user,
                            //     textEditingController.text, widget.postId!);
                             isTextFieldVisible = false;

                            superbaseComment(textEditingController.text,  widget.postId!);
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
        // const Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        //   child: CircleAvatar(
        //     backgroundColor: Colors.purple,
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('${lastComment}'),
            ),
          ),
        ),
      ],
    );
  }
}
