
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/databases/database.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:appwrite/appwrite.dart';
import 'package:master/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:postgres/postgres.dart';
import 'package:master/componants/global_booking.dart';

import 'package:uuid/uuid.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<dynamic> streamList = [];
  final wsUrl = Uri.parse(
      'wss://cloud.appwrite.io/v1/realtime?project=65bc947456c1c0100060&channels%5B%5D=databases.65c375bf12fca26c65db.collections.65d0612a901236115ecc.documents');
  late final channel = WebSocketChannel.connect(wsUrl);

  Future listenForTableNotifications() async {
    print("LIsten");
    final conn = await connectPostgres();
    await conn.open();

    await conn.execute('LISTEN chats');

    return conn.stream;
  }

  String parseDateTimeToHourMinute(String timeStamp) {
    // String timestamp = "2024-02-22T13:58:35.977+00:00";
    DateTime dateTime = DateTime.parse(timeStamp);
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String time = '$hour : $minute';
    return time;
  }

  // StreamListner()  {
  //   return channel.stream.listen((message) {
  //
  //     Map getData = jsonDecode(message);
  //     print(getData['data']['payload']);
  //     final data = getData['data']['payload'];
  //     channel.sink.add('received!');
  //     channel.sink.close(status.goingAway);
  //   });
  //   return data
  // }`

  bool isLoading = false;
  String messagex = '';

  TextEditingController controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    // TODO: implement initState
    userInit();
    calling();

    // getMessagesInit();

    setState(() {
      isLoading = false;
    });
    //readMessages();
    // get2Streams(currentUser['UserId']);
    super.initState();
  }

  // Stream<Map<String, dynamic>> getMessagesStream() {
  //   AppWriteDataBase connect = AppWriteDataBase();
  //   final realtime = connect.realtime;
  //   final subscription = realtime.subscribe([
  //     'databases.65c375bf12fca26c65db.collections.65d0612a901236115ecc.documents',
  //   ]);
  //
  //   // Create a StreamController to handle the stream
  //   StreamController<Map<String, dynamic>> controller = StreamController();
  //
  //   // Listen to the subscription
  //   subscription.stream.listen((response) {
  //     // Add response to the stream
  //     controller.add(response.payload);
  //
  //     // Close the subscription
  //     subscription.close();
  //   });
  //
  //   return controller.stream;
  // }

  Future<void> readMessages() async {
    print('Current User ${currentUser['UserId']}');
    AppWriteDataBase connect = AppWriteDataBase();
    print("Messages length: ${messages.length}");
    List<Map<String, dynamic>> messagesCopy = List.from(messages);
    List<Map<String, dynamic>> filteredList = [];

    for (Map<String, dynamic> item in messagesCopy) {
      if (item.containsKey('id') && item['SenderId'] != currentUser['UserId']) {
        filteredList.add(item);
      }
    }

    try {
      for (var message in filteredList) {
        print("DOCIDZ : ${message['id']}");

        await supabase.from('Message').update({
          'Status': 'Read',
        }).match({'id': message['id']}).neq('SenderId', currentUser['UserId']);
      }
      print("Read");
    } catch (error) {
      print('READ ERROR : $error');
    }
  }

  Stream<Map<String, dynamic>> getMessagesStream() {
    AppWriteDataBase connect = AppWriteDataBase();

    final realtime = connect.realtime;
    final subscription = realtime.subscribe([
      'databases.65c375bf12fca26c65db.collections.65d0612a901236115ecc.documents',
    ]);

    return subscription.stream.map((response) => response.payload);
  }

  getMessagesInit() async {
    print(
        "NEXT PAGR ID : ${Provider.of<CurrentRoomIdProvider>(context, listen: false).currentRoomId}");
    AppWriteDataBase connect = AppWriteDataBase();
    try {
      final result = await connect.databases.listDocuments(
        databaseId: '65c375bf12fca26c65db',
        collectionId: '65d0612a901236115ecc',
        queries: [
          Query.limit(1000),
          Query.equal("ChatRoomId", [
            Provider.of<CurrentRoomIdProvider>(context, listen: false)
                .currentRoomId
          ])
        ],
      );
      final documents = result.documents;

      List<dynamic> messageData = [];

      for (var document in documents) {
        String time = parseDateTimeToHourMinute(document.data['\$createdAt']);

        print('HELLO $time');
        Map<String, dynamic> mesenger = {
          'ChatRoomId': document.data['ChatRoomId'],
          'Sender': document.data['Sender'],
          'SenderId': document.data['SenderId'],
          "Message": document.data['Message'],
          'Time': time,
          'Timex': document.data['\$createdAt'],
          'Status': document.data['Status'],
          'DocId': document.data['DocId'],
          'ProfileImage': document.data['ProfileImage']

          // 'ProfileImage': document.data['ProfileImage'],
        };

        messageData.add(mesenger);
      }

      messageData.sort((a, b) {
        return DateTime.parse(b["Timex"]).compareTo(DateTime.parse(a["Timex"]));
      });
      setState(() {
        // messages = messageData.toString().toList().toString();
        // messages = messageData.toList().reversed.toList();
        messages = List.from(messageData.reversed);
      });
      scrollAnimateToEnd(_scrollController);
      readMessages();
      // get2Streams(currentUser['UserId']);

      print('THIS IS MESSAGE DATA : $messageData');
    } catch (error) {
      print(error);
    }
  }

  supabaseMessagesInit() async {
    print(
        "NEXT PAGR ID : ${Provider.of<CurrentRoomIdProvider>(context, listen: false).currentRoomId}");

    try {
      final documents = await supabase.from('Message').select().eq(
          'ChatRoomId',
          Provider.of<CurrentRoomIdProvider>(context, listen: false)
              .currentRoomId);

      print('DOCUMYMENTS  : $documents');
      List<dynamic> messageData = [];

      for (var document in documents) {
        String time = parseDateTimeToHourMinute(document['created_at']);

        // print('HELLO $time');
        Map<String, dynamic> mesenger = {
          'id': document['id'],
          'ChatRoomId': document['ChatRoomId'],
          'Sender': document['Sender'],
          'SenderId': document['SenderId'],
          "Message": document['Message'],
          'Time': time,
          'Timex': document['created_at'],
          'Status': document['Status'],
          'DocId': document['DocId'],
          'ProfileImage': document['ProfileImage'],
          'TimeSent': document['Time']

          // 'ProfileImage': document.data['ProfileImage'],
        };

        messageData.add(mesenger);
      }

      messageData.sort((a, b) {
        return DateTime.parse(b["TimeSent"]).compareTo(DateTime.parse(a["TimeSent"]));
      });
      setState(() {
        // messages = messageData.toString().toList().toString();
        // messages = messageData.toList().reversed.toList();
        messages = List.from(messageData.reversed);
        print('MESAGES : $messages');
      });
      scrollAnimateToEnd(_scrollController);
      readMessages();
      // get2Streams(currentUser['UserId']);

      print('THIS IS MESSAGE DATA : $messageData');
    } catch (error) {
      print('EROR ON GET $error');
    }
  }

  Map<String, dynamic> currentUser = {};

  void userInit() async {
    setState(() {
      isLoading = true;
    });

    final user = await getCurrentUser();
    if (user != null) {
      setState(() {
        currentUser = user;
      });
      print(currentUser);
      supabaseMessagesInit();
    } else {
      // Handle the case where getCurrentUser() returns null
      print('User is null');
    }
    setState(() {
      isLoading = false;
    });
  }
  //final supabase = Supabase.instance.client;
  Future getCurrentUser() async {
    AppWriteDataBase connect = AppWriteDataBase();
    try {
      final user = await connect.account.get();
   final nameMap = await supabase.from("Manager").select('ManagerName').eq('PhoneNumber', user.phone).single();

      print(user.name);
      Map<String, dynamic> userData = {
         "UserName": nameMap['ManagerName'],
        "UserId": user.$id,
        // "UserEmail": user.email,
        //Just the phone number...
        "PhoneNumber" : user.phone,
      };
      return userData;
    } catch (error) {
      print(error);
      // return null;
    }
  }

  // void createMessageTable() async {
  //   final conn = await connectPostgres();
  //   try {
  //     await conn.execute('CREATE TABLE IF NOT EXISTS messages ('
  //         'ChatRoomId VARCHAR(200),'
  //         'Sender VARCHAR(200),'
  //         'SenderId VARCHAR(200),'
  //         'Message VARCHAR(200),'
  //         'ProfileImage VARCHAR(200),'
  //         'DocId VARCHAR(200)'
  //         ')');
  //     conn.close();
  //     print("created message table");
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  // void pgSend(String roomId, String sender, String senderId, String message,
  //     String profileImage, docId) async {
  //   final conn = await connectPostgres();
  //   try {
  //     final Map<String, dynamic> data = {
  //       'ChatRoomId': roomId,
  //       'Sender': sender,
  //       'SenderId': senderId,
  //       "Message": message,
  //       'ProfileImage': profileImage,
  //       'DocId': docId,
  //     };
  //     final send = jsonEncode(data);
  //
  //     final result =
  //         await conn.execute("SELECT pg_notify('messages', 'hello')");
  //     print('result drom send :$result');
  //   } catch (error) {
  //     print("SEnd error  potgress $error");
  //   }
  // }

  Future listenForNotifications() async {
    try {
      final conn = await connectPostgres();
      if (conn == null) {
        print('Failed to connect to the database');
        return;
      }

      final stream =
          conn.execute('Select * From "Children" ORDER BY "Id" DESC LIMIT 1');

      print(stream.toString());
      print('Postgress connected, Stream: $stream');
      return stream;
    } catch (error) {
      print('Postgress Error: $error');
    }
  }

  void childTable() async {
    final conn = await connectPostgres();
    try {
      final name = "woooow";
      final result1 = await conn.execute(
          r'INSERT INTO "Children" ("Name")'
          r'VALUES ($1)',
          parameters: [
            name,
          ]);

      print("Done");
      conn.close();
    } catch (error) {
      print(error);
    }
  }

  StreamController<dynamic> _insertsStreamController =
      StreamController<dynamic>();

  void handleInserts(payload) {
    print("PAYLOAD : $payload");

    _insertsStreamController.add(payload);
  }

  Stream<dynamic> listining() {
    supabase
        .channel('Messages')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'Message',
            callback: handleInserts)
        .subscribe();
    return _insertsStreamController.stream;
  }

//TODO
  Stream<dynamic> listining2() {
    return supabase.from('Message').stream(primaryKey: ['id']);
  }

  final supabase = Supabase.instance.client;

  Future sendMessage(String sender, String senderId, String message, String id,
      String profileImage,String number) async {
    var uuid = Uuid();
    var docId = uuid.v1();
    try {
      await supabase.from('Message').insert({
        'Sender': sender,
        'SenderId': senderId,
        'ChatRoomId': id,
        'Message': message,
        'ProfileImage': profileImage,
        'DocId': docId,
        'Status': 'Unread',
        'Time': DateTime.now().toIso8601String(),
        'PhoneNumber': number,
      });

      print("Sent Message");
      setState(() {});
    } catch (error) {
      print('This is the eror : $error');
    }
  }

  List<dynamic> messages = [];
  String message = '';

  List<String> items = [];

  @override
  void dispose() {
    //await  end();
    _scrollController.dispose();
    channel.sink.close();

    super.dispose();
  }

  Future end() async {
    await readMessages();
    await get2Streams(currentUser['UserId']);
  }

  List<String> processedMessageIds = [];

  void scrollAnimateToEnd(ScrollController controller) {
    Future.delayed(const Duration(milliseconds: 400)).then((_) {
      try {
        controller
            .animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.fastOutSlowIn,
        )
            .then((value) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut,
          );
        });
      } catch (e) {
        print('error on scroll $e');
      }
    });
  }

  get2Streams(currentUserId) async {
    print(
        "NEXT PAGE Stream ID : ${Provider.of<CurrentRoomIdProvider>(context, listen: false).currentRoomId}");
    AppWriteDataBase connect = AppWriteDataBase();
    try {
      //1
      final result1 = await connect.databases.listDocuments(
        databaseId: '65c375bf12fca26c65db',
        collectionId: '65ecd78ee650f1509ca2',
        queries: [
          Query.limit(50),
          Query.equal("ChatRoomId", [
            Provider.of<CurrentRoomIdProvider>(context, listen: false)
                .currentRoomId
          ]),
          Query.notEqual("SenderId", [currentUserId])
        ],
      );

      //2
      final result2 = await connect.databases.listDocuments(
        databaseId: '65c375bf12fca26c65db',
        collectionId: '65ecde2786c77bcd4597',
        queries: [
          Query.limit(1000),
          Query.equal("ChatRoomId", [
            Provider.of<CurrentRoomIdProvider>(context, listen: false)
                .currentRoomId
          ]),
          Query.notEqual("SenderId", [currentUserId]),
        ],
      );

      final documents1 = result1.documents;

      List<dynamic> messageData1 = [];

      for (var document in documents1) {
        Map<String, dynamic> mesenger = {
          'DocId': document.data['DocId'],
          // 'ProfileImage': document.data['ProfileImage'],
        };

        messageData1.add(mesenger);
      }

      final documents2 = result2.documents;

      List<dynamic> messageData2 = [];

      for (var document in documents2) {
        Map<String, dynamic> mesenger = {
          'DocId': document.data['DocId'],
          // 'ProfileImage': document.data['ProfileImage'],
        };

        messageData2.add(mesenger);
      }

      final List<dynamic> combo = [...messageData1, ...messageData2];

      for (var item in combo) {
        await connect.databases.deleteDocument(
            databaseId: '65c375bf12fca26c65db',
            collectionId: '65ecd78ee650f1509ca2',
            documentId: item['DocId']);

        await connect.databases.deleteDocument(
            databaseId: '65c375bf12fca26c65db',
            collectionId: '65ecde2786c77bcd4597',
            documentId: item['DocId']);
      }

      // setState(() {
      //   streamList = combo;
      // });

      print('THIS IS Combo List DATA : $combo');
    } catch (error) {
      print(error);
    }
  }

  Stream load() {
    return  supabase.from('Message').stream(primaryKey: ['id']).eq('ChatRoomId', Provider.of<CurrentRoomIdProvider>(context, listen: false).currentRoomId).order('id', ascending: false);
  }

  void calling(){
    final calz = load();
    setState(() {
      listen = calz;
    });

  }

  Stream? listen;


  _callNumber(number) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    AppWriteDataBase connect = AppWriteDataBase();

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: w * 15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //postgress
                HeaderMessage(
                  clientName: Provider.of<ClientNameProvider>(
                    context,
                    listen: false,
                  ).clientName,
                  onPressedCall:  (){_callNumber(Provider.of<ClientNumberProvider>(
                    context,
                    listen: false,
                  ).clientNumber); },
                ),
                SizedBox(
                  height:  h * 0.75418,
                  child: StreamBuilder(stream: listen,
                      builder: (context,snap){


                        switch(snap.connectionState){
                          case ConnectionState.none:
                            return CircularProgressIndicator();
                          case ConnectionState.waiting:
                            return Center(child: Text("Loading Messages"));
                          case ConnectionState.active:
                            if(snap.hasError){
                              print(snap.error);

                            }else if(!snap.hasData){
                              print('No Data Here');
                            }else if(snap.hasData){

                              final rev = snap.data;

                              print('THIS IS REV : $rev');

                              if(rev != null){

                                return  SizedBox(
                                  height: h * 0.75418,
                                  child: GroupedListView<dynamic, String>(
                                    elements: rev ?? [],
                                    groupBy: (element) {
                                      // Parse the 'Time' string into a DateTime object
                                      DateTime time = DateTime.parse(element?['Time']);
                                      // Group by year
                                      return DateTime(time.year, time.month, time.day)
                                          .year
                                          .toString() ?? '';
                                    },
                                    groupSeparatorBuilder: (String groupByValue) =>
                                        Text('Year: $groupByValue'),
                                    itemComparator: (item1, item2) => item1['Time'].compareTo(item2['Time']),
                                    useStickyGroupSeparators: true,
                                    floatingHeader: true,
                                    // sort: true,
                                    reverse: true,
                                    order: GroupedListOrder.DESC,
                                    itemBuilder: (context, dynamic element) {
                                      final String senderId = element['PhoneNumber'] ?? '';
                                      final String current = currentUser['PhoneNumber'] ?? '';
                                      bool isSender = senderId == current;

                                      DateTime dateTime = DateTime.parse(element['Time']);
                                      int hour = dateTime.hour;
                                      int minute = dateTime.minute;



                                      return isSender
                                          ? MessageBubbleRight(
                                        name: '$hour:$minute',
                                        text: element['Message'],
                                        image:
                                        Provider.of<CurrentUserImageProvider>(
                                          context,
                                          listen: false,
                                        ).currentUserImage,
                                      )
                                          : MessageBubbleLeft(
                                        text: element['Message'],
                                        image: Provider.of<ClientImageProvider>(
                                          context,
                                          listen: false,
                                        ).clientImage,
                                      );
                                    },
                                  ),
                                );

                              }



                            }
                          case ConnectionState.done:
                            return SizedBox();

                        };
                        return SizedBox();
                      }

                  ),
                ),

                // SizedBox(
                //   height: h * 0.75418,
                //   child: ListView.builder(
                //       padding: EdgeInsets.only(bottom: 50.0),
                //       //reverse: true,
                //       controller: _scrollController,
                //       itemCount: messages.length,
                //       itemBuilder: (context, index) {
                //         final senderId = messages[index]
                //             ['SenderId']; // Fetch sender ID from the message
                //         final isCurrentUser = currentUser['UserId'] ==
                //             senderId; // Check if sender ID matches current user's ID
                //
                //         return isCurrentUser
                //             ? Padding(
                //                 padding: const EdgeInsets.all(8.0),
                //                 //Remember u spelt profile as pofile!!!
                //                 child: MessageBubbleRight(
                //                   name: messages[index]['Time'],
                //                   text: messages[index]['Message'],
                //                   image: Provider.of<CurrentUserImageProvider>(
                //                           context,
                //                           listen: false)
                //                       .currentUserImage,
                //                   // name: messages[index]['Sender'],
                //                 ),
                //               )
                //             : Padding(
                //                 padding: const EdgeInsets.all(8.0),
                //                 child: MessageBubbleLeft(
                //                   text: messages[index]['Message'],
                //                   image: Provider.of<ClientImageProvider>(
                //                           context,
                //                           listen: false)
                //                       .clientImage,
                //                   //  name: messages[index]['Sender'],
                //                 ),
                //               );
                //       }),
                // ),
                // MessageBubbleLeft(),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 11,
                        child: ForTextInput(
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
                              getCurrentUser();
                              sendMessage(
                                //Neeed to sort for name
                                  currentUser['UserName'] ?? '',
                                  currentUser['SenderId'] ?? '',
                                  message,
                                  Provider.of<CurrentRoomIdProvider>(context,
                                          listen: false)
                                      .currentRoomId,
                                  Provider.of<CurrentUserImageProvider>(context,
                                          listen: false)
                                      .currentUserImage,
                                currentUser['PhoneNumber'] ?? '',
                              );
                              controller.clear();
                              FocusScope.of(context).requestFocus(FocusNode());

                              // scrollAnimateToEnd(_scrollController );

                              // _scrollController.animateTo(
                              //   _scrollController.position.maxScrollExtent,
                              //   duration: Duration(milliseconds: 300),
                              //   curve: Curves.easeOut,
                              // );
                            },
                            icon: Icon(Icons.send_outlined)),
                      )
                    ],
                  ),
                ),
                StreamBuilder(
                    stream: listining2(),
                    builder: (context, snapshot) {
                      print("ON");
                      switch (snapshot.connectionState) {
                        // Use snack bars here...
                        case ConnectionState.none:
                          //   print("NONE");
                          return SizedBox();
                        case ConnectionState.waiting:
                          //    print("Waiting");
                          return SizedBox();

                        case ConnectionState.active:
                          if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          } else if (!snapshot.hasData) {
                            return Text('No data');
                          } else if (snapshot.hasData) {
                            print('THis is the data  ${snapshot.data.length}');

                            final length = snapshot.data.length;

                            final decodedMap = snapshot.data.last;

                            print(
                                "decoed :${decodedMap["Message"].toString()}");

                            String time = parseDateTimeToHourMinute(
                                decodedMap['created_at']);

                            Map<String, dynamic> item = {
                              'id': decodedMap['id'] ?? '',
                              'ChatRoomId': decodedMap['ChatRoomId'] ?? '',
                              'Sender': decodedMap['Sender'] ?? "",
                              'SenderId': decodedMap['SenderId'].toString(),
                              "Message": decodedMap['Message'] ?? '',
                              'Time': time,
                              'ProfileImage': decodedMap['ProfileImage'] ?? "",
                              'DocId': decodedMap['DocId'] ?? '',
                              'TimeSent': decodedMap['Time'] ?? '',
                            };

                            if (item == null) {
                              print("NO data!");
                            } else {
                              final messegeId = item['DocId'];
                              if (processedMessageIds.contains(messegeId)) {
                                print("already have");
                              } else {
                                final currentId = item['DocId'];

                                processedMessageIds.add(currentId);
                               // messages.add(item);
                                print("added ID");
                                scrollAnimateToEnd(_scrollController);
                                final id = item['id'];

                                if (currentUser['PhoneNumber'] != item['PhoneNumber']) {
                                  void update(a) async {
                                    await supabase.from('Message').update({
                                      'Status': 'Read',
                                    }).match({'id': a});
                                  }

                                  update(id);
                                }

                                Future.delayed(
                                  Duration.zero,
                                  () async {
                                    setState(() {});
                                  },
                                );
                              }
                            }
                          }
                        case ConnectionState.done:
                          print("Done");

                          return SizedBox();
                      }

                      return SizedBox();
                    }),
              ],
            ),
          ),
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
    super.key,
  });

  String? text;
  String? name;
  String? image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 5.0,
                  bottom: 5.0,
                ),
                child: Text(name ?? ''),
              )),
          Stack(
            children: [
              Positioned(
                top: 1,
                child: Container(
                  height: 35.0,
                  width: 35.0,
                  decoration: const BoxDecoration(
                      color: Colors.grey, shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: CachedNetworkImage(
                      imageUrl: image ?? "",
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
                      //height: 250,
                      //width: double.maxFinite,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
        ],
      ),
    );
  }
}

class MessageBubbleRight extends StatefulWidget {
  MessageBubbleRight({
    this.text,
    this.name,
    this.image,
    super.key,
  });

  String? text;
  String? name;
  String? image;

  @override
  State<MessageBubbleRight> createState() => _MessageBubbleRightState();
}

class _MessageBubbleRightState extends State<MessageBubbleRight> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
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
                    child: CachedNetworkImage(
                      imageUrl: widget.image ?? "",
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
                      //height: 250,
                      //width: double.maxFinite,
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
                  child: CachedNetworkImage(
                    imageUrl:
                        Provider.of<ClientImageProvider>(context, listen: false)
                            .clientImage,
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
                    //height: 250,
                    //width: double.maxFinite,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                     clientName ?? 'Client Name',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
