import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart%20';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/databases/database.dart';

import 'package:intl/intl.dart';
import 'package:master/util/alerts.dart';
import 'package:uuid/uuid.dart';
import 'package:appwrite/appwrite.dart';
import 'package:master/providers/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../classes/message_class.dart';
import '../../componants/global_booking.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>  {
  MessageClass messageClass = MessageClass();
  Authenticate auth = Authenticate();
  Map<String, dynamic> currentUser = {};
  bool isLoading = false;

  List<dynamic> messages = [];
  String message = '';

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    messageClass.userInit(setState, context);
    messageClass.calling(context, setState);
    currentUser = messageClass.currentUser;

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
         isLoading = false;
      });
    });

    super.initState();
  }

  String parseDateTimeToHourMinute(String timeStamp) {
    // String timestamp = "2024-02-22T13:58:35.977+00:00";
    DateTime dateTime = DateTime.parse(timeStamp);
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String time = '$hour : $minute';
    return time;
  }

  String messagex = '';

  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> deleteMessage(id) async {
    await supabase.from('Message').delete().match({'id': id});
  }

  List<String> processedMessageIds = [];

  @override
 
  Widget build(BuildContext context) {
    AppWriteDataBase connect = AppWriteDataBase();

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(
          children: [
            Container(
              color: Colors.grey.shade300,
              width: w * 15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StreamBuilder(
                      stream: messageClass.listen,
                      builder: (context, snap) {
                        switch (snap.connectionState) {
                          case ConnectionState.none:
                            return CircularProgressIndicator();
                          case ConnectionState.waiting:
                            return Center(child: Text("Loading Messages"));
                          case ConnectionState.active:
                            if (snap.hasError) {
                              print(snap.error);
                            } else if (!snap.hasData) {
                              print('No Data Here');
                            } else if (snap.hasData) {
                              final rev = snap.data;

                              print('THIS IS REV : $rev');

                              final String current =
                                  messageClass.currentUser['PhoneNumber'] ?? '';
                              for (var item in rev!) {
                                final String senderId =
                                    item['PhoneNumber'] ?? '';

                                if (senderId != current) {
                                  //TODO mark as read

                                  //  supabase.from('Message').update({
                                  //   'Status': 'Read',
                                  // }).match({'id': item['id']}).neq(
                                  //     'SenderId', messageClass.currentUser['PhoneNumber']);

                                  // supabase.from('Message').insert({
                                  //   'Sender': "blank",
                                  //   'SenderId': "blank",
                                  // });
                                  //
                                  // supabase.from('Message').delete().match({ 'SenderId': "blank" });
                                }
                              }
                              return SizedBox();
                            }
                          case ConnectionState.done:
                            return SizedBox();
                        }
                        ;
                        return SizedBox();
                      }),

                  /////////////////////////////
                  SizedBox(
                    height: h * 0.75418,
                    child: StreamBuilder(
                        stream: messageClass.listen,
                        builder: (context, snap) {
                          switch (snap.connectionState) {
                            case ConnectionState.none:
                              return CircularProgressIndicator();
                            case ConnectionState.waiting:
                              return Center(child: Text("Loading Messages"));
                            case ConnectionState.active:
                              if (snap.hasError) {
                                print(snap.error);
                              } else if (!snap.hasData) {
                                print('No Data Here');
                              } else if (snap.hasData) {
                                final rev = snap.data;

                                print('THIS IS REV : $rev');

                                if (rev != null) {
                                  return SizedBox(
                                    height: h * 0.75418,
                                    child: ListView.builder(
                                        reverse: true,
                                        itemCount: rev?.length,
                                        itemBuilder: (context, index) {
                                          final String senderId =
                                              rev[index]['PhoneNumber'] ?? '';
                                          final String current = messageClass
                                                  .currentUser['PhoneNumber'] ??
                                              '';
                                          bool isSender = senderId == current;
                                          DateTime dateTime = DateTime.parse(
                                              rev[index]['Time']);
                                          int hour = dateTime.hour;
                                          int minute = dateTime.minute;

                                          return isSender
                                              ? MessageBubbleRight(
                                                  name: '$hour:$minute',
                                                  text: rev[index]['Message'],
                                                  image: Provider.of<
                                                      CurrentUserImageProvider>(
                                                    context,
                                                    listen: false,
                                                  ).currentUserImage,
                                                  callBack: () async {
                                                   const message =
                                                        "Delete this message?";
                                                    alertDeleteMessage(
                                                      context,
                                                      message,
                                                      () async {
                                                        await deleteMessage(
                                                            rev[index]['id']);
                                                      },
                                                    );
                                                  },
                                                )
                                              : MessageBubbleLeft(
                                                  name: '$hour:$minute',
                                                  text: rev[index]['Message'],
                                                  image: rev[index]
                                                      ['ProfileImage'],
                                                  person: rev[index]['Sender'],
                                                  callBack: () {
                                                    const message =
                                                        "Delete this message?";
                                                    alertDeleteMessage(
                                                      context,
                                                      message,
                                                      () async {
                                                        await deleteMessage(
                                                            rev[index]['id']);
                                                      },
                                                    );
                                                  },
                                                );
                                        }),
                                  );
                                }
                              }
                            case ConnectionState.done:
                              return SizedBox();
                          }
                          ;
                          return SizedBox();
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Visibility(
                      visible:
                          Provider.of<christProvider>(context, listen: false)
                                  .myMap['Project']?['Expire'] ??
                              false,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 11,
                            child: ForTextInput(
                              keyboard: TextInputType.text,
                              text: "Nessage",
                              controller: controller,
                              label: 'Message',
                              con: Icons.message_outlined,
                              onChanged: (value) {
                                setState(() {
                                  messagex = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    message = messagex;
                                  });
                                  messageClass.getCurrentUser(context);

                                  messageClass.sendMessage(
                                    context,
                                    //Neeed to sort for name
                                    messageClass.currentUser['UserName'] ?? '',
                                    messageClass.currentUser['UserId'] ?? '',
                                    message,
                                    Provider.of<CurrentRoomIdProvider>(context,
                                            listen: false)
                                        .currentRoomId,
                                    Provider.of<CurrentUserImageProvider>(
                                            context,
                                            listen: false)
                                        .currentUserImage,
                                    messageClass.currentUser['PhoneNumber'] ??
                                        '',
                                    setState,
                                  );
                                  controller.clear();
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                icon: Icon(Icons.send_outlined)),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.grey.shade300,
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

class MessageBubbleLeft extends StatelessWidget {
  MessageBubbleLeft({
    this.text,
    this.image,
    this.name,
    this.person,
    this.callBack,
    super.key,
  });

  String? text;
  String? name;
  String? image;
  String? person;
  VoidCallback? callBack;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onLongPress: callBack ?? () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: 5.0, bottom: 5.0, left: 55.0),
                  child: Text(name ?? ''),
                )),
            Stack(
              children: [
                Positioned(
                  top: 1,
                  child: Column(
                    children: [
                      Container(
                        height: 35.0,
                        width: 35.0,
                        decoration: const BoxDecoration(
                            color: Colors.grey, shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: 
                          Image.network(image ?? ""),
                          
                          // CachedNetworkImage(
                          //   imageUrl: image ?? "",
                          //   placeholder: (context, url) => const Center(
                          //     child: SizedBox(
                          //       height: 40.0,
                          //       width: 40.0,
                          //       child: CircularProgressIndicator(
                          //         value: 1.0,
                          //       ),
                          //     ),
                          //   ),
                          //   errorWidget: (context, url, error) =>
                          //       Icon(Icons.error),
                          //   fit: BoxFit.cover,
                          //   //height: 250,
                          //   //width: double.maxFinite,
                          // ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Material(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              color: Colors.indigoAccent,
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Text(
                                  text ?? '', style: TextStyle(fontSize: 16.0),
                                  // overflow: TextOverflow.ellipsis,
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                  maxLines: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Container(
                height: h * 0.03,
                // color: Colors.red,
                child: Text(person ?? "", softWrap: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubbleRight extends StatefulWidget {
  MessageBubbleRight({
    this.text,
    this.name,
    this.image,
    this.callBack,
    super.key,
  });

  String? text;
  String? name;
  String? image;
  VoidCallback? callBack;

  @override
  State<MessageBubbleRight> createState() => _MessageBubbleRightState();
}

class _MessageBubbleRightState extends State<MessageBubbleRight> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return GestureDetector(
      onLongPress: widget.callBack ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 60.0, bottom: 5.0),
                  child: Text(
                    widget.name ?? '',
                    style: TextStyle(fontSize: 11.0),
                  ),
                )),
            Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                color: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Text(
                                    widget.text ?? '',
                                    style: TextStyle(fontSize: 16.0),
                                    // overflow: TextOverflow.ellipsis,
                                    overflow: TextOverflow.clip,
                                    softWrap: true,
                                    maxLines: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 35.0,
                    width: 35.0,
                    decoration: const BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network( widget.image ?? "")
                      
                      // CachedNetworkImage(
                      //   imageUrl: widget.image ?? "",
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
                      //   //height: 250,
                      //   //width: double.maxFinite,
                      // ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Container(
                height: h * 0.04,
                //color: Colors.red,
                child: Text("Me ", softWrap: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderMessage extends StatelessWidget {
  HeaderMessage({
    this.onPressedCall,
    this.clientName,
    super.key,
  });

  String? clientName;
  VoidCallback? onPressedCall;

  Future getCurrentUser() async {
    AppWriteDataBase connect = AppWriteDataBase();
    try {
      final user = await connect.account.get();
      print(user.name);
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.keyboard_return)),
              //Provider.of<ClientImageProvider>(context, listen: false).clientImage
              Container(
                height: 40.0,
                width: 40.0,
                decoration: const BoxDecoration(
                    color: Colors.grey, shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: 
                  Image.network(Provider.of<ClientImageProvider>(context, listen: false)
                            .clientImage),
                  
                  // CachedNetworkImage(
                  //   imageUrl:
                  //       Provider.of<ClientImageProvider>(context, listen: false)
                  //           .clientImage,
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
                  //   //height: 250,
                  //   //width: double.maxFinite,
                  // ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName ?? 'Client Name',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    // Text(
                    //   'Last online',
                    //   style: TextStyle(fontSize: 14.0),
                    // )
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                    onPressed: onPressedCall ?? () {},
                    icon: Icon(Icons.phone_rounded)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
