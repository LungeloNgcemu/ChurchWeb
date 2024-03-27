import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:master/componants/avatar_profile.dart';
import 'package:master/componants/buttonChip.dart';
import 'package:master/databases/database.dart';
import 'package:appwrite/appwrite.dart';
import 'package:uuid/uuid.dart';
import 'package:master/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart' as b;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AppWriteDataBase connect = AppWriteDataBase();
  final wsUrl = Uri.parse(
      'ws://cloud.appwrite.io/v1/realtime?project=65bc947456c1c0100060&channels%5B%5D=databases.65c375bf12fca26c65db.collections.65ecd78ee650f1509ca2.documents');
  late final channel = WebSocketChannel.connect(wsUrl);
bool isLoading = false;
  Future stream() async {
    return await channel.stream;
  }

  @override
  void dispose() {
    channel.sink.close();

    super.dispose();
  }

  Future<String> countPerson(id) async {
    try {
      final user = await connect.account.get();
      //final id = user.$id;

      // print("ID ID !!!!!!!!!!!!!!!!!!!!!! $id");

      final result = await connect.databases.listDocuments(
        databaseId: '65c375bf12fca26c65db',
        collectionId: '65d1e705ceb53916f35a',
        queries: [
          Query.equal("ManangerId", [user.$id])
        ],
      );

      final doc = result.documents.first.data['ManagerSingleChatId'];
      List<String> idList = [];
      for (var item in doc) {
        idList.add(item);
      }
      // if list is not empty

      if (idList.isNotEmpty) {
        final result2 = await connect.databases.listDocuments(
          databaseId: '65c375bf12fca26c65db',
          collectionId: '65d0612a901236115ecc',
          queries: [
            Query.equal("ChatRoomId", idList),
            Query.equal("Status", ["Unread"]),
            Query.equal("SenderId", [id]),
            Query.notEqual("SenderId", [user.$id])
          ],
        );
        final documents = result2.documents.length.toString();
        return documents;
      }
    } catch (error) {
      print('COUNR ERROR : $error');
      return '';
    }
    return '';
  }


  List<dynamic> userList = [];

  void getget() async {
    final user = await connect.account.get();
    print("Lungelo THIS IS THE USE ${user.$id}");
  }

  @override
  void initState() {
    userStreamInit();
    getget();
    setState(() {
      isLoading = true;
    });
    getUsersInit();
    fetchData();
    // TODO: implement initState
    super.initState();
  }

  void getUsersInit() {
    getUsers().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  String number = '0';

  Future<void> getUsers() async {
    final response = await connect.databases.listDocuments(
      databaseId: '65c375bf12fca26c65db',
      collectionId: '65d10b7e4aa972ce0a61',
    );
    final documents = response.documents;
    List<dynamic> users = [];
    for (var document in documents) {
      number = await countPerson(document.data['UserId']);
      Map<String, dynamic> item = {
        'UserName': document.data['UserName'] ?? '',
        'UserId': document.data['UserId'],
        'Email': document.data['Email'],
        'DocId': document.$id,
        'SingleChatId': document.data['SingleChatId'],
        'ProfileImage': document.data['ProfileImage'],
        'PhoneNumber': document.data['PhoneNumber'],
        'Count': number,
      };
      users.add(item);
    }
    print(users);
    setState(() {
      userList = users;
    });
  }

  ///TODO this chat box will fetc the owners image...
  void ChatBox(
      List<dynamic> xingleChatId,
      String userDocId,
      String userName,
      String userId,
      String email,
      String profileImage,
      String phoneNumber) async {
    try {
      List<String> singleChatId = [];

      for (String item in xingleChatId) {
        singleChatId.add(item);
      }
      print("LIST INPUT : $singleChatId");

      AppWriteDataBase connect = AppWriteDataBase();
// get current manager
      final manager = await connect.account.get();
      final managerId = manager.$id;

      //get manager room list

      final response = await connect.databases.listDocuments(
        databaseId: '65c375bf12fca26c65db',
        collectionId: '65d1e705ceb53916f35a',
        queries: [
          Query.equal('ManangerId', [managerId])
        ],
      );

      final managerDocument = response.documents.first;
      final masterDocForUpdate = managerDocument.$id;

      final list = managerDocument.data['ManagerSingleChatId'];
      final image = managerDocument.data['PofileImage'];
      print('IMAGE URL : $image');
// this cant be null
      context
          .read<CurrentUserImageProvider>()
          .updatecCurrentRoomId(newValue: image);

      List<String> rooms = [];
      for (var item in list) {
        rooms.add(item);
      }

      //mananger list
      print(rooms);
      String matchedId = '';

      // Check if there is a match in both lists
      for (var item in rooms) {
        for (var id in singleChatId) {
          if (item == id) {
            setState(() {
              matchedId = id;
              print("MATCHEDID : $matchedId");
            });

            break;
          }
        }
        if (matchedId.isNotEmpty) {
          break; // Exit loop if matchedId is found
        }
      }
      print('THIS IS WHAT YOU HAVE : $matchedId');
      if (matchedId.isNotEmpty) {
        context
            .read<CurrentRoomIdProvider>()
            .updatecCurrentRoomId(newValue: matchedId);

        print(
            " FOUND ROOM ID : ${Provider.of<CurrentRoomIdProvider>(context, listen: false).currentRoomId}");
        final chats = await connect.databases.listDocuments(
          databaseId: '65c375bf12fca26c65db',
          collectionId: '65d0612a901236115ecc',
          queries: [
            Query.equal('ChatRoomId', [matchedId])
          ],
        );

        final messages = chats.documents;
        List<dynamic> talks = [];
        for (var i in messages) {
          talks.add(i.data);
        }
        Navigator.pushNamed(context, '/messageScreen');
        print('This is iost : $talks');
      } else {
        final roomId = Uuid();
        final roomIdComplete = roomId.v1();
        print("NEW ROOM ID : $roomIdComplete");
        //  var userId = uuid.v1();
//1. update mananger list

        List<String> manangerRooms = [];
        for (var item in rooms) {
          manangerRooms.add(item);
        }
        manangerRooms.add(roomIdComplete);
        await connect.databases.updateDocument(
            databaseId: '65c375bf12fca26c65db',
            collectionId: '65d1e705ceb53916f35a',
            documentId: masterDocForUpdate,
            data: {
              'ManagerName': managerDocument.data['ManagerName'],
              'ManagerEmail': managerDocument.data['ManagerEmail'],
              'ManangerId': managerDocument.data['ManangerId'],
              'ManagerSingleChatId': manangerRooms,
            });

        //2. update user list
//////////////////////////
        final forUser = await connect.databases.getDocument(
            databaseId: '65c375bf12fca26c65db',
            collectionId: '65d10b7e4aa972ce0a61',
            documentId: userDocId);
        final userDoc = forUser.data;
        final userList = userDoc['SingleChatId'];

        List<String> userRooms = [];
        for (var item in userList) {
          userRooms.add(item);
        }
        userRooms.add(roomIdComplete);
        await connect.databases.updateDocument(
            databaseId: '65c375bf12fca26c65db',
            collectionId: '65d10b7e4aa972ce0a61',
            documentId: userDocId,
            data: {
              'UserName': userName,
              'UserId': userId,
              'Email': email,
              'SingleChatId': userRooms,
              'ProfileImage': profileImage,
              'PhoneNumber': phoneNumber
            });

        // return chat list with documents
      }
    } catch (error) {
      print('PRESSED CHAT : $error');
    }
    // Navigator.pushNamed(context, '/messageScreen');
  }

  void ChatBox2(
      String userName, String profileImage, String phoneNumber) async {
    try {
      AppWriteDataBase connect = AppWriteDataBase();
// get current manager
      final manager = await connect.account.get();
      final digits = manager.phone;
      print(digits);

      //get manager room list
      final data = await supabase
          .from('Manager')
          .select('SingleChatId')
          .eq('PhoneNumber', digits)
          .single();

      var  managerItem = data['SingleChatId'] ?? [];

      final image = await supabase
          .from('Manager')
          .select('ProfileImage')
          .eq('PhoneNumber', digits)
          .single();

      String  managerImage = image['ProfileImage'] ?? 'https://picsum.photos/200/300/?blur';

      context.read<CurrentUserImageProvider>().updatecCurrentRoomId(newValue: managerImage);
      print('Manager List : $managerItem');
      List<String> managerList =[];
      for(var item in managerItem){
        if(managerItem == null){
          managerList;
          break;
        }else if(managerItem != null){
          managerList.add(item);
        }
      }

//get user room List
      final userData = await supabase
          .from('User')
          .select('SingleChatId')
          .eq('PhoneNumber', phoneNumber)
          .single();

      var userItem = userData['SingleChatId'] ?? [];
      print('User List : $userItem');
      // context
      //     .read<CurrentUserImageProvider>()
      //     .updatecCurrentRoomId(newValue: image);


      List<String> userList =[];
      for(var item in userItem){
        if(userItem == null){
          userList;
          break;
        }else if(userItem != null){
          userList.add(item);
        }
      }


      String matchedId = '';

      // Check if there is a match in both lists
      for (var item in managerItem) {
        for (var id in userItem) {
          if (item == id) {
            setState(() {
              matchedId = id;
              print("MATCHEDID : $matchedId");
            });
            break;
          }
        }
        if (matchedId.isNotEmpty) {
          break; // Exit loop if matchedId is found
        }
      }
      print('THIS IS WHAT YOU HAVE : $matchedId');
      if (matchedId.isNotEmpty) {
        context
            .read<CurrentRoomIdProvider>()
            .updatecCurrentRoomId(newValue: matchedId);

        print(
            " FOUND ROOM ID : ${Provider.of<CurrentRoomIdProvider>(context, listen: false).currentRoomId}");
        Navigator.pushNamed(context, '/messageScreen');
      } else {
        final roomId = Uuid();
        final roomIdComplete = roomId.v1();
        print("NEW ROOM ID : $roomIdComplete");

        //Update Lists
        final List<String> userInsert = [...userList, roomIdComplete];


        await supabase
            .from('User')
            .update({'SingleChatId': '{${userInsert.join(',')}}'}).match(
                {'PhoneNumber': phoneNumber});

         final List<String> mangerInsert = [...managerList,roomIdComplete];
        String result1 = mangerInsert.join(',');

        await supabase
            .from('Manager')
            .update({'SingleChatId': '{${mangerInsert.join(',')}}'}).match(
                {'PhoneNumber': digits});
        Navigator.pushNamed(context, '/messageScreen');
      }
    } catch (error) {
      print('PRESSED CHAT : UserAccound Deactivated $error');
    }
    //Navigator.pushNamed(context, '/messageScreen');
  }

  String item = '0';

  final supabase = Supabase.instance.client;

  Future<Map<String, int>> Person2() async {
    try {
      final user = await connect.account.get();

      final result = await connect.databases.listDocuments(
        databaseId: '65c375bf12fca26c65db',
        collectionId: '65d1e705ceb53916f35a',
        queries: [
          Query.equal("ManangerId", [user.$id])
        ],
      );

      final doc = result.documents.first.data['ManagerSingleChatId'];
      List<String> idList = [];
      for (var item in doc) {
        idList.add(item);
      }
      // if list is not empty

      if (idList.isNotEmpty) {
        // final result2 = await connect.databases.listDocuments(
        //   databaseId: '65c375bf12fca26c65db',
        //   collectionId: '65d0612a901236115ecc',
        //   queries: [
        //     Query.equal("ChatRoomId", idList),
        //     Query.equal("Status", ["Unread"]),
        //     Query.notEqual("SenderId", [user.$id])
        //   ],
        // );

        final forcountc = await supabase
            .from('Message')
            .select()
            .inFilter('ChatRoomId', idList)
            .eq('Status', "Unread");

        // final documents = result2.documents;
        Map<String, int> counts = {};

        for (var item in forcountc) {
          print('THis is item for count ${item}');
          final senderId = item['SenderId'];
          counts[senderId] = (counts[senderId] ?? 0) + 1;
        }

        return counts;
      }
    } catch (error) {
      print('COUNR ERROR : $error');
      return {};
    }
    return {};
  }

  Map<String, int> forCount = {};

  void fetchData() async {
    Map<String, int> tim = await Person2();
    setState(() {
      forCount = tim;
    });
    print("Fetching count");
  }

  Stream? userStream;

  void userStreamInit() async {
    final stream = await usersStream();

    setState(() {
      userStream = stream;
    });
  }

  Stream usersStream() {
    return supabase.from('User').stream(primaryKey: ['id']);
  }

  _callNumber(number) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 10.0, left: 8.0, top: 10.0),
              child: Row(
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
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Contact',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ///////////////////////////////////////////////////////TODO why get users again??????????
            StreamBuilder(
                stream: userStream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.active) {
                    if (snap.hasError) {
                      print("Snap Error : ${snap.error}");
                    } else if (snap.hasData) {
                      print('Incomming User');
                      final dataList = snap.data;
                      print('DATA LIST : $dataList');
                      // fetchData();
                      return Container(
                        height: h * 0.78395,
                        child: ListView.builder(
                          itemCount: dataList?.length,
                          itemBuilder: (context, index) {
                            final id = dataList?[index]['UserId'];
                            return FittedBox(
                              child: ClientStrip(
                                // Assuming item is declared somewhere in your stateful widget
                                bala: forCount[id]?.toString() ?? "0",
                                // Using the fetched data
                                name: dataList?[index]['UserName'] ,
                                profileImage: dataList?[index]['ProfileImage'],

                                onPressed1: () {
                                  // 1. clientName
                                  // 2. clientImage
                                  // 3. clientNumber
                                  context
                                      .read<ClientNameProvider>()
                                      .updateClientName(
                                      newValue: dataList[index]['UserName'] ?? '');

                                  context
                                      .read<ClientNumberProvider>()
                                      .updateClientNumber(
                                    newValue: dataList[index]['PhoneNumber'] ?? '');

                                  // Inside onPressed1 callback
                                  context
                                      .read<ClientImageProvider>()
                                      .updateClientImage(
                                    newValue: dataList[index]['ProfileImage'],
                                  );

                                  // Assuming ChatBox is a widget to handle chat interactions
                                  ChatBox2(
                                    dataList[index]?['UserName'] ?? '',
                                    dataList[index]?['ProfileImage'] ??
                                        'https://picsum.photos/id/237/200/300',
                                    dataList[index]?['PhoneNumber'] ??
                                        'No number Yet',
                                  );
                                },
                                onPressed2: () {
                                  _callNumber(userList[index]['PhoneNumber']);
                                },
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      print("No data Available in snap");
                    }
                  }
                  return SizedBox();
                }),

            const Divider(
              thickness: 0.0,
            ),
          ],
        ),
      ),
    );
  }
}

class ClientStrip extends StatefulWidget {
  ClientStrip({
    this.name,
    this.onPressed1,
    this.onPressed2,
    this.profileImage,
    this.bala,
    super.key,
  });

  String? name;
  String? bala;
  VoidCallback? onPressed1;

  VoidCallback? onPressed2;
  String? profileImage;

  @override
  State<ClientStrip> createState() => _ClientStripState();
}

class _ClientStripState extends State<ClientStrip> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50.0,
              width: 50.0,
              decoration: const BoxDecoration(
                color: Colors.indigoAccent,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CachedNetworkImage(
                  imageUrl: widget.profileImage ?? "",
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: 150.0,
              height: 30,
             // color: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name ?? "",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  // const Text(
                  //   "the last text message sent ",
                  //   style: TextStyle(fontSize: 12.0),
                  // ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: w * 0.01, right: w * 0.01),
                child: SizedBox(
                  child: b.Badge(
                    position: b.BadgePosition.topEnd(top: 30, end: 106),
                    badgeContent: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(widget.bala ?? '',
                          style: TextStyle(fontSize: 20.0)),
                    ),
                  ),
                ),
              ),
              ContactButton(
                  word: 'Chat', onPressed: widget.onPressed1 ?? () {}),
              ContactButton(
                  word: 'Call', onPressed: widget.onPressed2 ?? () {}),
            ],
          )
        ],
      ),
    );
  }
}

class ContactButton extends StatelessWidget {
  const ContactButton({this.word, super.key, this.onPressed});

  final VoidCallback? onPressed;
  final String? word;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SizedBox(
        height: 25,
        width: 60,
        child: OutlinedButton(
          onPressed: onPressed ?? () {}, //
          //     () {
          //   Navigator.pushNamed(context, '/messageScreen');
          // },
          style: OutlinedButton.styleFrom(
            elevation: 2.0,
            foregroundColor: Colors.red.withOpacity(0.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.red,
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              word ?? '',
              style: const TextStyle(color: Colors.black, fontSize: 10.0),
            ),
          ),
        ),
      ),
    );
  }
}
