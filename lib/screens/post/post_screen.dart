import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/classes/snack_bar.dart';
import 'package:master/constants/constants.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../classes/church_init.dart';
import '../../classes/on_create_class.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:master/models/comment_model.dart';
import 'package:master/componants/global_booking.dart';

import 'create_post.dart';

StreamBuilder xbuildStreamBuilder(context, String path) {
  double h = MediaQuery.of(context).size.height;

  return StreamBuilder(
    //TOdo update and add to "eq.church name"h
    stream: supabase.from('DisplayImages').stream(primaryKey: ['id']).eq(
        "Church",
        Provider.of<christProvider>(context, listen: false).myMap['Project']
            ?['ChurchName']),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        if (snapshot.hasError) {
          print("Error: ${snapshot.error}");
          Container(
            height: h * 0.3,
            child: Image.network(Assets.placeholder),

            // CachedNetworkImage(
            //   imageUrl: Assets.placeholder,
            //   placeholder: (context, url) => const Center(
            //     child: SizedBox(
            //       height: 40.0,
            //       width: 40.0,
            //       child: CircularProgressIndicator(
            //         value: 1.0,
            //       ),
            //     ),
            //   ),
            //   errorWidget: (context, url, error) => Icon(Icons.error),
            //   fit: BoxFit.cover,
            //   height: 250,
            //   width: double.maxFinite,
            // ),
          );
        }

        String imageUrl = '';
        // imageUrl = snapshot.data[0]?['$path'];
        try {
          imageUrl = snapshot.data[0]?['$path'];
        } catch (e) {
          imageUrl = Assets.placeholder;
        }

        return Container(
          height: h * 0.3,
          child: Image.network(imageUrl),
          // CachedNetworkImage(
          //   imageUrl: imageUrl,
          //   placeholder: (context, url) => const Center(
          //     child: SizedBox(
          //       height: 40.0,
          //       width: 40.0,
          //       child: CircularProgressIndicator(
          //         value: 1.0,
          //       ),
          //     ),
          //   ),
          //   errorWidget: (context, url, error) => Icon(Icons.error),
          //   fit: BoxFit.cover,
          //   height: 250,
          //   width: double.maxFinite,
          // ),
        );
      }
      return SizedBox();
    },
  );
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with AutomaticKeepAliveClientMixin {
  ChurchInit churchStart = ChurchInit();
  CreateClass create = CreateClass();
  Authenticate auth = Authenticate();
  SnackBarNotice snack = SnackBarNotice();
  ScrollController _scrollController = ScrollController();
  DraggableScrollableController controller = DraggableScrollableController();

  Stream? streamx;
  bool isLoading = false;

  void streamDelegate() {
    streamx = superbasePost();
  }

  Stream superbasePost() {
    return supabase
        .from('Posts')
        .stream(primaryKey: ['id'])
        .eq(
            "Church",
            Provider.of<christProvider>(context, listen: false).myMap['Project']
                    ?['ChurchName'] ??
                "")
        .order('id', ascending: false);
  }

  @override
  void initState() {
    super.initState();
    streamDelegate();
    Provider.of<BackImageUrlProvider>(context, listen: false)
        .loadImageUrlLocally();
    Provider.of<ProfileImageUrlProvider>(context, listen: false)
        .loadImageUrlLocally();
  }

  final ImagePickerCustom _picker = ImagePickerCustom();
  Uint8List? _profileImage;
  Uint8List? _backImage;
  String? profileImageUrl;
  String? backImageUrl;

  Future<void> _profilePickImage() async {
    _profileImage = await _picker.pickImageToByte();
  }

  Future<void> _backPickImage() async {
    _backImage = await _picker.pickImageToByte();
  }

  Uint8List? _image;
  String? imageUrl;

  Future<void> _pickImage() async {
    _image = await _picker.pickImageToByte();
  }

  Future<void> _uploadImageToSuperbase(String where) async {
    try {
      await _pickImage();
      const message1 = "Display Image Updating...";
      snack.snack(context, message1);
      print('Image picked');

      if (_image != null) {
        final provider = Provider.of<christProvider>(context, listen: false);
        final bucket = provider.myMap['Project']?['Bucket'] ?? "";
        final churchName = provider.myMap['Project']?['ChurchName'];

        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        try {
          await supabase.storage.from(bucket).remove([fileName]);
        } catch (e) {
          log('No existing image to delete or deletion failed: $e');
        }

        try {
          await supabase
              .from('DisplayImages')
              .delete()
              .eq('Church', churchName);
          print('Existing database row deleted');
        } catch (e) {
          print('No existing database row to delete: $e');
        }

        final String pathv = await supabase.storage.from(bucket).uploadBinary(
            fileName, _image!,
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: false));

        final publicUrl =
            await supabase.storage.from(bucket).getPublicUrl(fileName);

        print('Public URL: $publicUrl');

        final response = await supabase.from('DisplayImages').insert({
          'Church': churchName,
          where: publicUrl,
        });

        const message = "Display Image Updated";
        alertComplete(context, message);
        setState(() {});
      } else {
        log("No image selected");
        const message1 = "No Image Selected";
        snack.snack(context, message1);
      }
    } catch (e) {
      log("Error uploading image to Supabase: $e");
      const message2 = "Try Change the name of the Image";
      alertSuccess(context, message2);
    }
  }

  // void superbaseDeletePost(String id) async {
  //   try {
  //     await supabase.from('Comments').delete().match({'PostId': id});
  //     await supabase.from('Posts').delete().match({'id': id});

  //   } catch (e) {
  //     print('Error deleting post or comments: $e');
  //   }
  // }

  void superbaseDeletePost(String id, String imageUrl) async {
    try {
      // 1. Delete comments
      await supabase.from('Comments').delete().match({'PostId': id});

      // 2. Delete post
      await supabase.from('Posts').delete().match({'id': id});

      // 3. Delete image from Supabase Storage if imageUrl is not empty
      if (imageUrl.isNotEmpty) {
        final bucket = Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'] ??
            "";

        final uri = Uri.parse(imageUrl);
        final segments = uri.pathSegments;

        if (segments.isNotEmpty) {
          final startIndex = segments.indexOf(bucket) + 1;
          final filePath = segments.sublist(startIndex).join('/');

          await supabase.storage.from(bucket).remove([filePath]);
        }
      }
    } catch (e) {
      print('Error deleting post, comments, or image: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverAppBar(
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //                        MaterialButton(
                        //                         child: Text('data'),
                        //                         onPressed: () {

                        //           final provider = Provider.of<christProvider>(context, listen: false);

                        // final churchName = provider.myMap['Project']?['ChurchName'];
                        //         PushNotifications.sendMessageToTopic(
                        //             topic: churchName, title: "Hell", body: "World");
                        //       }),
                        Visibility(
                          visible: Provider.of<christProvider>(context,
                                      listen: false)
                                  .myMap['Project']?['Expire'] ??
                              false,
                          child: Visibility(
                            visible: ChurchInit.visibilityToggle(context),
                            child: MaterialButton(
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              color: Colors.orange,
                              onPressed: () {
                                create.sheeting(context, Poster());
                                // Navigator.pushNamed(context, '/products');
                                // Navigator.pushNamed(context, '/create');
                              },
                              child: const Text('Post'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                backgroundColor: Colors.white,
                //pinned: true,
                expandedHeight: 330,
                flexibleSpace: FlexibleSpaceBar(
                  // title: Text(
                  //   'Classic Styling',
                  //   style: TextStyle(color: Colors.black),
                  // ),
                  background: Stack(
                    children: [
                      Container(
                        height: 250,
                        color: Colors.grey[100],
                        child: Image.asset("lib/images/clear.png"),
                        // child: xbuildStreamBuilder(context, "BackImage"),
                      ),
                      // Positioned(
                      //   top: 215.0,
                      //   left: 250.0,
                      //   child: Visibility(
                      //     visible: churchStart.visibilityToggle(context),
                      //     child: GestureDetector(
                      //       onTap: () async {
                      //         _uploadImageToSuperbase("BackImage");
                      //         // await _backPickImage();
                      //         // final backImage = await _uploadBackImageToFirebase();
                      //         // uploadForSalon("BackImage", backImage);
                      //       },
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(5.0),
                      //           color: Colors.green,
                      //         ),
                      //         child: const Padding(
                      //           padding: EdgeInsets.all(1.0),
                      //           child: Icon(Icons.edit, color: Colors.white),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Positioned(
                        top: 140.0,
                        left: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          height: 155.0,
                          width: 158.0,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Container(
                                height: 145.0,
                                width: 145.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: xbuildStreamBuilder(
                                    context, "ProfileImage"),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: 300,
                      //   left: 123,
                      //   child: FittedBox(
                      //     child: Text(
                      //       Provider.of<christProvider>(context, listen: false)
                      //           .myMap['Project']?['ChurchName'],
                      //       textAlign: TextAlign.center,
                      //       style: const TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 15.0,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Positioned(
                        top: 255.0,
                        left: 145.0,
                        child: Visibility(
                          visible: Provider.of<christProvider>(context,
                                      listen: false)
                                  .myMap['Project']?['Expire'] ??
                              false,
                          child: Visibility(
                            visible: ChurchInit.visibilityToggle(context),
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                });

                                await _uploadImageToSuperbase("ProfileImage");

                                setState(() {
                                  isLoading = false;
                                });

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
                        child: Text('Connecting...'),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data.isEmpty == true) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text('No posts available.')),
                      );
                    } else {
                      // final postsData = snapshot.data?.docs;

                      final listDoc = snapshot.data;
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // final post = listDoc?[index].data();
                            return SocialPost(
                              description: listDoc[index]['Description'] ?? '',
                              imageUrl: listDoc[index]['ImageUrl'] ?? '',
                              postId: listDoc[index]['id'].toString() ?? '',
                              onPressedDelete: () {
                                alertDelete(context, "Delete Post?", () async {
                                  superbaseDeletePost(
                                      listDoc[index]['id'].toString(),
                                      listDoc[index]['ImageUrl']);
                                });

                                streamDelegate();
                              },
                            );
                          },
                          childCount: listDoc.length ?? 0,
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
    this.onPressedDelete, // Add postId as a parameter
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
  ChurchInit churchStart = ChurchInit();

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

  // CommentService commentService = CommentService();

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

  void streamCommentDelegate(postId) {
    streamComment = superbaseCommentStream(postId);
  }

  Stream superbaseCommentStream(postId) {
    return supabase.from('Comments').stream(primaryKey: ['id'])
      ..eq('PostId', postId).order('id', ascending: false);
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
                    backgroundColor: Colors.grey[100],
                    child: ClipOval(
                      child: xbuildStreamBuilder(context, "ProfileImage"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      Provider.of<christProvider>(context, listen: false)
                          .myMap['Project']?['ChurchName'],
                      style: const TextStyle(
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
              // color: Colors.grey[100],
              height: 280.0,
              child: Image.network(widget.imageUrl!),
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
                Visibility(
                  visible: ChurchInit.visibilityToggle(context),
                  child: IconButton(
                    onPressed: widget.onPressedDelete ?? () {},
                    icon: const Icon(
                      color: Colors.orange,
                      Icons.delete,
                      size: 30.0,
                    ),
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
                    stream: streamComment,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.data?.isEmpty == true) {
                          return Text('No comments available.');
                        } else {
                          final comments = snapshot.data!;

                          return SizedBox(
                            height: 130.0,
                            child: ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                return CommentBubble(
                                    lastComment: comments[index]['Text']);
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

                            superbaseComment(
                                textEditingController.text, widget.postId!);
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
