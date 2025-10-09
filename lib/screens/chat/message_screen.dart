import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:master/Model/message_model.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/databases/database.dart';

import 'package:intl/intl.dart';
import 'package:master/providers/message_provider.dart';
import 'package:master/services/api/chat_service.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/services/socket/io_service.dart';
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

class _MessageScreenState extends State<MessageScreen> {
  MessageClass messageClass = MessageClass();
  Authenticate auth = Authenticate();
  TokenUser? currentUser;
  bool isLoading = false;

  List<dynamic> messages = [];
  String message = '';
  int previousMessageLength = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (mounted) {
      initChat();
    }

    super.initState();
  }

  Future<void> initChat() async {
    setState(() {
      isLoading = true;
    });
    initCurrentUser();

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });

      _scrollToBottom();
    });

    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    messageProvider.addListener(_onMessageUpdate);
  }

  void _onMessageUpdate() {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    if (messageProvider.messages != null &&
        messageProvider.messages!.length > previousMessageLength) {
      previousMessageLength = messageProvider.messages!.length;
      _scrollToBottom();
    }
  }

  Future<void> initCurrentUser() async {
    TokenUser? user = await TokenService.tokenUser();

    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }
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

  Future<void> deleteMessage({id, uniqueId}) async {
    print('Deleting message: $id and $uniqueId');
    await ChatService.deleteMessage(id: id, uniqueId: uniqueId);
  }

  Future<void> sendMessage(
      {uniqueId, message, sender, senderId, profileImage, time, church}) async {
    ChatService.sendMessage(
      uniqueId: uniqueId,
      message: message,
      sender: sender,
      senderId: senderId,
      time: time,
      church: church,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent + 400,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final messageProvider = Provider.of<MessageProvider>(context);

    // Listen to changes
    if (messageProvider.messages != null &&
        messageProvider.messages!.length + 2 > previousMessageLength) {
      previousMessageLength = messageProvider.messages!.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  List<String> processedMessageIds = [];

  @override
  Widget build(BuildContext context) {
    AppWriteDataBase connect = AppWriteDataBase();
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    final messageProvider = Provider.of<MessageProvider>(context, listen: true);

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
                  SizedBox(
                    height: h * 0.75418,
                    child: StreamBuilder<List<MessageModel>>(
                      stream:
                          Provider.of<MessageProvider>(context, listen: false)
                              .messagesStream,
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? [];
                        return ListView.builder(
                            // reverse: true,
                            controller: _scrollController, // Add controller
                            itemCount: messageProvider.messages?.length,
                            itemBuilder: (context, index) {
                              print(
                                  '📱 ListView building with ${messageProvider.messages?.length} messages');

                              final String senderId = messageProvider
                                      .messages?[index].phoneNumber ??
                                  '';

                              final String current =
                                  currentUser?.phoneNumber ?? '';

                              bool isSender = senderId == current;

                              DateTime dateTime = DateTime.parse(
                                  messageProvider.messages?[index].time ?? '');
                              int hour = dateTime.hour;
                              int minute = dateTime.minute;

                              return isSender
                                  ? MessageBubbleRight(
                                      name: '$hour:$minute',
                                      text: messageProvider
                                              .messages?[index].message ??
                                          '',
                                      image: messageProvider
                                              .messages?[index].profileImage ??
                                          '',
                                      callBack: () async {
                                        const message = "Delete this message?";
                                        alertDeleteMessage(
                                          context,
                                          message,
                                          () async {
                                            await deleteMessage(
                                                id: messageProvider
                                                        .messages?[index].id ??
                                                    '',
                                                uniqueId: messageProvider
                                                        .messages?[index]
                                                        .uniqueChurchId ??
                                                    '');
                                          },
                                        );
                                      },
                                    )
                                  : MessageBubbleLeft(
                                      name: '$hour:$minute',
                                      text: messageProvider
                                              .messages?[index].message ??
                                          '',
                                      image: messageProvider
                                              .messages?[index].profileImage ??
                                          '',
                                      person: messageProvider
                                              .messages?[index].sender ??
                                          '',
                                      callBack: () {
                                        const message = "Delete this message?";
                                        alertDeleteMessage(
                                          context,
                                          message,
                                          () async {
                                            await deleteMessage(
                                                id: messageProvider
                                                        .messages?[index].id ??
                                                    '',
                                                uniqueId: messageProvider
                                                        .messages?[index]
                                                        .uniqueChurchId ??
                                                    '');
                                          },
                                        );
                                      },
                                    );
                            });
                      },
                    ),
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
                                onPressed: () async {
                                  message = messagex;

                                  print('Sending message: $message');
                                  await sendMessage(
                                    uniqueId: currentUser?.uniqueChurchId ?? '',
                                    message: message,
                                    sender: currentUser?.userName ?? '',
                                    senderId: currentUser?.phoneNumber ?? '',
                                    time: DateTime.now().toIso8601String(),
                                    church: currentUser?.church ?? '',
                                  );

                                  controller.clear();
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());

                                  PushNotifications.sendMessageToTopic(
                                      topic: currentUser?.uniqueChurchId ?? '',
                                      title: currentUser?.userName ?? '',
                                      body: message);
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
                          child: Image.network(
                            image ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                // Image is fully loaded
                                return child;
                              }
                              // While loading, show a placeholder
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                              ); // fallback if image fails
                            },
                          ),
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
                                  text ?? '',
                                  style: TextStyle(fontSize: 16.0),
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
              child: SizedBox(
                height: h * 0.03,
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
                                    style: const TextStyle(fontSize: 16.0),
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
                      child: Image.network(
                        widget.image ?? '',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            // Image is fully loaded
                            return child;
                          }
                          // While loading, show a placeholder
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                          ); // fallback if image fails
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SizedBox(
                height: h * 0.04,
                child: const Text("Me ", softWrap: true),
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
    try {
      TokenUser? user = await TokenService.tokenUser();

      if (user != null) {
        print(user.userName);
        return user;
      }
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
                  child: Image.network(
                      Provider.of<ClientImageProvider>(context, listen: false)
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
