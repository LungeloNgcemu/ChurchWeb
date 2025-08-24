// import 'package:flutter/material.dart';
// import 'package:master/classes/calender_class.dart';
// import 'package:master/screens/home/church_screen.dart';
// import '../../extra/cancelled.dart';
// import '../../cards/prayer_card.dart';
// import '../../classes/church_init.dart';
// import '../../classes/on_create_class.dart';
// import '../../classes/prayer_class.dart';
// import '../../componants/chips.dart' as MyChips;
// import '../../componants/buttonChip.dart';
// import 'package:master/cards/product_card.dart';
// import 'package:master/providers/url_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:bottom_sheet/bottom_sheet.dart';
// import 'package:master/componants/text_input.dart';
// import 'package:master/componants/global_booking.dart';
// import 'package:table_calendar/table_calendar.dart' as here;

// //TODO product count

// // import 'product_card.dart';
// import '../../cards/product_selection.dart';
// import '../../cards/editable_card.dart' as pro;
// import '../../componants/tittle_head.dart';
// import 'create_prayer.dart';
// import '../media/fullscreen.dart';

// class PrayerScreen extends StatefulWidget {
//   const PrayerScreen({super.key});

//   @override
//   State<PrayerScreen> createState() => _PrayerScreenState();
// }

// class _PrayerScreenState extends State<PrayerScreen> {
//   Calender calenderClass = Calender();
//   Prayer pray = Prayer();
//   CreateClass create = CreateClass();
//   ChurchInit visibility = ChurchInit();
//   ScrollController controller = ScrollController();
// //  DraggableScrollableController controller = DraggableScrollableController();

//   void initState() {

//     super.initState();
//   }





//   Color selectedOp(String selectedOption) {
//     if (selectedOption == 'Upcoming') {
//       return Colors.green;
//     } else if (selectedOption == 'Canceled') {
//       return Colors.purple;
//     } else if (selectedOption == 'Completed') {
//       return Colors.orange;
//     } else if (selectedOption == 'Face') {
//       return Colors.pink;
//     } else {
//       return Colors.black;
//     }
//   }




//   Stream? productStream;

//   Stream load() {
//     return supabase
//         .from('Procucts')
//         .stream(primaryKey: ['id'])
//         .eq('Category',
//             Provider.of<SelectedOptionProvider>(context).selectedOption)
//         .order('id', ascending: false);
//   }

//   void superbaseStream() {
//     productStream = load();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String selectedOption =
//         context.watch<SelectedOptionProvider>().selectedOption;

//     debugPrint("here :" + selectedOption);
//     // String selectedOption = Provider.of<SelectedOptionProvider>(context, listen: false).selectedOption;
// //stream product

//     return SafeArea(
//       child: CustomScrollView(
//         scrollDirection: Axis.vertical,
//         slivers: [
//           SliverAppBar(
//             backgroundColor: Colors.white54,
//             expandedHeight: 280,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Column(
//                 children: [
//                   TittleHead(
//                     title: 'Prayer Wall',
//                   ),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 5.0),
//                     child: Container(
//                         color: Colors.grey[100], child: pray.sliderPictures()),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: NewButton(
//                             where: () {
//                               create.sheeting(context, CreatePrayer());
//                               // Optionally clear the text field after adding
//                               // (You might choose to leave it as-is)
//                               setState(() {});
//                             },
//                             inSideChip: 'Create Prayer',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           StreamBuilder(
//             stream: supabase
//                 .from('Prayers')
//                 .stream(primaryKey: ['id']).eq("Church",Provider.of<christProvider>(context, listen: false)
//               .myMap['Project']?['ChurchName'] ??
//           "")
//                 .order('id', ascending: false),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.active) {
//                 if (snapshot.hasError) {
//                   return SliverToBoxAdapter(
//                       child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData ||
//                     snapshot.data?.isEmpty == true) {
//                   return SliverToBoxAdapter(
//                       child: Center(child: Text('No posts available.')));
//                 } else {
//                   // below is data available
//                   final productsList = snapshot.data;
//                   return SliverPadding(
//                     padding: EdgeInsets.all(20),
//                     sliver: SliverList(
//                       delegate: SliverChildBuilderDelegate(
//                         childCount: productsList?.length,
//                         (context, index) {
//                           return GestureDetector(
//                             onDoubleTap: () async {

//                               if(ChurchInit.visibilityToggle(context) == true){

//                                 await supabase
//                                     .from('Prayers')
//                                     .delete()
//                                     .match({'id': productsList?[index]['id']});

//                               }else{
//                                 print("Not admin");
//                               }



//                             },
//                             child: Cancelled(
//                               cornerText: productsList?[index]['Status'] ?? '' ,
//                               clientName:productsList?[index]['Name'] ?? '' ,
//                               description: productsList?[index]['Prayer'] ?? '',
//                               date: productsList?[index]['Date'] ?? '',
//                               profileImage: productsList?[index]['Image'] ?? '',
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 }
//               } else {
//                 return const SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 100.0),
//                     child: Center(child: Center(child: Text("Loading..."))),
//                   ),
//                 ); // Replace with your custom loading widget
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Sheeting extends StatefulWidget {
//   Sheeting(
//       {this.card,
//       this.postTitle,
//       this.postDuration,
//       this.image,
//       this.description,
//       this.price,
//       super.key});

//   ProductCard? card;

//   String? postTitle;
//   String? postDuration;
//   String? image;
//   String? description;
//   String? price;

//   @override
//   State<Sheeting> createState() => _SheetingState();
// }

// class _SheetingState extends State<Sheeting> {
//   List<String> listx = [];
//   List<String> listP = [];

//   // Future<void> updateList(selectedDay) async {
//   //   List<String> list = await getCurrentList(setState);
//   //   List<String> goodx = await matrixRevolution(selectedDay, list, setState);
//   //   setState(() {
//   //     listP = goodx;
//   //     listx = list;
//   //     isLoading = false;
//   //   });
//   // }

//   Future<void> updateList(selectedDay) async {
//     List<String> list = await getCurrentList(setState);

//     print('Good');
//     //from supabase
//     List<String> goodx = await revolution_matrix(selectedDay, list, setState);
//     setState(() {
//       listP = goodx;
//       listx = list;
//       isLoading = false;
//     });
//   }

//   bool isLoading = false;

//   TextEditingController controllerName = TextEditingController();
//   TextEditingController controllerContact = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: Padding(
//         padding: const EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             const Text(
//               "Product for Booking",
//               style: TextStyle(
//                 fontSize: 22.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             widget.card ?? Container(),
//             // const ProductCard(),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Text("1. Enter Client Name"),
//                 ],
//               ),
//             ),
//             ForTextInput(
//               keyboard: TextInputType.text,
//               controller: controllerName,
//               label: "Client Name",
//               text: "Enter Clients Name",
//               con: Icons.person,
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Text("2. Enter Clients Contact"),
//                 ],
//               ),
//             ),
//             ForTextInput(
//                 keyboard: TextInputType.number,
//               controller: controllerContact,
//               label: "Clients Contact",
//               text: "Enter Clients Contact",
//               con: Icons.phone_rounded,
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Text("3. Select Day for Client"),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8.0),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.grey,
//                         spreadRadius: 0.1,
//                         blurRadius: 10.0,
//                       )
//                     ]),
//                 child: here.TableCalendar(
//                   firstDay: DateTime.utc(2010, 10, 16),
//                   lastDay: DateTime.utc(2030, 3, 14),
//                   focusedDay: DateTime.now(),
//                   selectedDayPredicate: (day) {
//                     return here.isSameDay(selectedDay, day);
//                   },
//                   onDaySelected: (sselectedDay, focusedDay) {
//                     setState(() {
//                       isLoading = true;
//                       selectedDay = sselectedDay;
//                       focusedDay = focusedDay;
//                     });
//                     updateList(selectedDay);
//                     //
//                     // setState(()  {
//                     //   selectedDay = sselectedDay;
//                     //   focusedDay = focusedDay;
//                     // });
//                     // List<String> list = await getCurrentList(setState);
//                     // List<String> goodx = await matrixRevolution(selectedDay,list,setState);
//                     // setState(() {
//                     //   listP = goodx;
//                     //   listx = list;
//                     // });
//                   },
//                   calendarFormat: calendarFormat,
//                   onFormatChanged: (format) {
//                     setState(() {
//                       calendarFormat = format;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Text("4. Select Time for Client"),
//                 ],
//               ),
//             ),
//             isLoading
//                 ? SizedBox(
//                     height: 150,
//                     child: Center(child: CircularProgressIndicator()))
//                 : book_blue_print(
//                     selectedDay,
//                     listP,
//                     isSelected,
//                     listx,
//                     specificAll,
//                     setState,
//                     widget.postTitle ?? "",
//                     widget.postDuration ?? "",
//                     widget.image ?? "",
//                     widget.description ?? "",
//                     controllerName.text ?? '',
//                     controllerContact.text ?? '',
//                     widget.price ?? ''),
//             ElevatedButton(
//               child: const Text('Close BottomSheet'),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:appwrite/appwrite.dart';
// // import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// // import 'package:master/url_provider.dart';
// // import 'package:provider/provider.dart';
// // import 'package:flutter/material.dart';
// // import 'package:master/componants/extrabutton.dart';
// // import 'package:uuid/uuid.dart';
// // import '../componants/chips.dart' as MyChips;
// // import '../componants/tittle_head.dart';
// // import '../upcoming.dart';
// // import '../completed.dart';
// // import '../cancelled.dart';
// // import '../cards/cardBook.dart';
// // import 'package:master/componants/global_booking.dart';
// // import 'package:master/databases/database.dart';
// // import 'package:web_socket_channel/web_socket_channel.dart';
// //
// // //String selectedOption = 'Upcoming';
// // bool isLoading = true;
// // bool isOn = false;
// //
// //
// // class InfoBook extends StatefulWidget {
// //   const InfoBook({super.key});
// //
// //   @override
// //   State<InfoBook> createState() => _InfoBookState();
// // }
// //
// // class _InfoBookState extends State<InfoBook> {
// //   @override
// //   void dispose() {
// //     channel.sink.close();
// //     super.dispose();
// //   }
// //
// //   void ChatBox(
// //       //List<dynamic> xingleChatId,
// //       String userDocId,
// //       String userName,
// //       String userId,
// //       String email,
// //       String profileImage,
// //       String phoneNumber) async {
// //     try {
// //       // List<String> singleChatId = [];
// //       //
// //       // for (String item in xingleChatId) {
// //       //   singleChatId.add(item);
// //       // }
// //       // print("LIST INPUT : $singleChatId");
// //       //TODO get the uuser chatkistId from their id since you dont have it herr
// //
// //       AppWriteDataBase connect = AppWriteDataBase();
// // // get current manager
// //       final manager = await connect.account.get();
// //       final managerId = manager.$id;
// //       //Todo for user
// //       final userResponse = await connect.databases.listDocuments(
// //         databaseId: '65c375bf12fca26c65db',
// //         //Change collection id
// //         collectionId: '65d1e705ceb53916f35a',
// //         queries: [
// //           Query.equal('UserId', [userId])
// //         ],
// //       );
// //
// //       final userDocument = userResponse.documents.first;
// //       final singleChatId = userDocument.data['SingleChatId'];
// //
// //       //get manager room list
// //
// //       final response = await connect.databases.listDocuments(
// //         databaseId: '65c375bf12fca26c65db',
// //         collectionId: '65d1e705ceb53916f35a',
// //         queries: [
// //           Query.equal('ManangerId', [managerId])
// //         ],
// //       );
// //
// //       final managerDocument = response.documents.first;
// //       final masterDocForUpdate = managerDocument.$id;
// //
// //       final list = managerDocument.data['ManagerSingleChatId'];
// //       final image = managerDocument.data['PofileImage'];
// //       print('IMAGE URL : $image');
// // // this cant be null
// //       context
// //           .read<CurrentUserImageProvider>()
// //           .updatecCurrentRoomId(newValue: image);
// //
// //       List<String> rooms = [];
// //       for (var item in list) {
// //         rooms.add(item);
// //       }
// //
// //       //mananger list
// //       print(rooms);
// //       String matchedId = '';
// //
// //       // Check if there is a match in both lists
// //       for (var item in rooms) {
// //         for (var id in singleChatId) {
// //           if (item == id) {
// //             setState(() {
// //               matchedId = id;
// //               print("MATCHEDID : $matchedId");
// //             });
// //
// //             break;
// //           }
// //         }
// //         if (matchedId.isNotEmpty) {
// //           break; // Exit loop if matchedId is found
// //         }
// //       }
// //       print('THIS IS WHAT YOU HAVE : $matchedId');
// //       if (matchedId.isNotEmpty) {
// //         context
// //             .read<CurrentRoomIdProvider>()
// //             .updatecCurrentRoomId(newValue: matchedId);
// //
// //         print(
// //             " FOUND ROOM ID : ${Provider.of<CurrentRoomIdProvider>(context, listen: false).currentRoomId}");
// //         final chats = await connect.databases.listDocuments(
// //           databaseId: '65c375bf12fca26c65db',
// //           collectionId: '65d0612a901236115ecc',
// //           queries: [
// //             Query.equal('ChatRoomId', [matchedId])
// //           ],
// //         );
// //
// //         final messages = chats.documents;
// //         List<dynamic> talks = [];
// //         for (var i in messages) {
// //           talks.add(i.data);
// //         }
// //         Navigator.pushNamed(context, '/messageScreen');
// //         print('This is iost : $talks');
// //       } else {
// //         final roomId = Uuid();
// //         final roomIdComplete = roomId.v1();
// //         print("NEW ROOM ID : $roomIdComplete");
// //         //  var userId = uuid.v1();
// // //1. update mananger list
// //
// //         List<String> manangerRooms = [];
// //         for (var item in rooms) {
// //           manangerRooms.add(item);
// //         }
// //         manangerRooms.add(roomIdComplete);
// //         await connect.databases.updateDocument(
// //             databaseId: '65c375bf12fca26c65db',
// //             collectionId: '65d1e705ceb53916f35a',
// //             documentId: masterDocForUpdate,
// //             data: {
// //               'ManagerName': managerDocument.data['ManagerName'],
// //               'ManagerEmail': managerDocument.data['ManagerEmail'],
// //               'ManangerId': managerDocument.data['ManangerId'],
// //               'ManagerSingleChatId': manangerRooms,
// //             });
// //
// //         //2. update user list
// // //////////////////////////
// //         final forUser = await connect.databases.getDocument(
// //             databaseId: '65c375bf12fca26c65db',
// //             collectionId: '65d10b7e4aa972ce0a61',
// //             documentId: userDocId);
// //         final userDoc = forUser.data;
// //         final userList = userDoc['SingleChatId'];
// //
// //         List<String> userRooms = [];
// //         for (var item in userList) {
// //           userRooms.add(item);
// //         }
// //         userRooms.add(roomIdComplete);
// //         await connect.databases.updateDocument(
// //             databaseId: '65c375bf12fca26c65db',
// //             collectionId: '65d10b7e4aa972ce0a61',
// //             documentId: userDocId,
// //             data: {
// //               'UserName': userName,
// //               'UserId': userId,
// //               'Email': email,
// //               'SingleChatId': userRooms,
// //               'ProfileImage': profileImage,
// //               'PhoneNumber': phoneNumber
// //             });
// //
// //         // return chat list with documents
// //       }
// //     } catch (error) {
// //       print('PRESSED CHAT : $error');
// //     }
// //     // Navigator.pushNamed(context, '/messageScreen');
// //   }
// //
// //   final wsUrl = Uri.parse(
// //       'wss://cloud.appwrite.io/v1/realtime?project=65bc947456c1c0100060&channels%5B%5D=databases.65c375bf12fca26c65db.collections.65c902f10e37ac37f20a.documents');
// //   late final channel = WebSocketChannel.connect(wsUrl);
// //
// //   StreamSubscription<dynamic> love() {
// //     return channel.stream.listen((message) {});
// //   }
// //
// //   //List<dynamic> fromDatabase = [];
// //   bool isLoading = true;
// //
// //   @override
// //   void initState() {
// //     selectedOption = 'Upcoming';
// //
// //     bok();
// //    // bookings = one;
// //     // load2(selectedOption);
// //     // TODO: implement initState
// //     super.initState();
// //   }
// //   bool loading = true;
// //   void bok (){
// //     bookingInit1();
// //     bookingInit2();
// //     bookingInit3();
// //   }
// //
// //   List<dynamic> upComing = [{}];
// //   List<dynamic> completed = [{}];
// //   List<dynamic> cancelled = [{}];
// //
// //   Future<void> load() async {
// //     final list = await getBookings();
// //     print(list);
// //     setState(() {
// //       final triplex = filterList(list);
// //       upComing = triplex[0];
// //       completed = triplex[1];
// //       cancelled = triplex[2];
// //      // fromDatabase = upComing;
// //       print(upComing);
// //       // fromDatabase = list;
// //       isLoading = false;
// //     });
// //   }
// //
// //   Future<void> load2(String selectedOption) async {
// //     final list = await getBookings();
// //     print(list);
// //
// //     final triplex = filterList(list);
// //     switch (selectedOption) {
// //       case ('Upcoming'):
// //         upComing = triplex[0];
// //       //  fromDatabase = upComing;
// //         break;
// //       case ('Completed'):
// //         completed = triplex[1];
// //       //  fromDatabase = completed;
// //         break;
// //       case ('Cancelled'):
// //         cancelled = triplex[2];
// //        // fromDatabase = cancelled;
// //         break;
// //     }
// //     setState(() {});
// //   }
// //
// //   String selectedOption = 'Upcoming';
// //
// //   void filterItem(
// //       Map<String, dynamic> item, Function(void Function()) setState) {
// //     final type = item['type'];
// //     switch (type) {
// //       case ('UpComing'):
// //         upComing.add(item);
// //         setState(() {});
// //         break;
// //       case ('Completed'):
// //         completed.add(item);
// //         setState(() {});
// //         break;
// //       case ('Cancelled'):
// //         cancelled.add(item);
// //         setState(() {});
// //         break;
// //     }
// //   }
// //
// //   List<dynamic> switchToList(String selectedOption, List<dynamic> upComing,
// //       List<dynamic> completed, List<dynamic> cancelled) {
// //     List<dynamic> selectedList = [];
// //     switch (selectedOption) {
// //       case ('Upcoming'):
// //         selectedList = upComing;
// //         break;
// //       case ('Completed'):
// //         selectedList = completed;
// //         break;
// //       case ('Cancelled'):
// //         selectedList = cancelled;
// //         break;
// //     }
// //     return selectedList;
// //   }
// //
// //   StreamController streamController = StreamController();
// //
// //   List<String> preId = [];
// //
// //   Future stream() async {
// //     return await channel.stream;
// //   }
// //
// //   _callNumber(number) async {
// //     bool? res = await FlutterPhoneDirectCaller.callNumber(number);
// //   }
// //
// //   Stream? bookings;
// //   Stream? one;
// //   Stream? two;
// //   Stream? three;
// //
// //   Future<void> streamSwitch(String selectedOption) async {
// //
// //     switch (selectedOption) {
// //       case ('Upcoming'):
// //         bookings = one;
// //         break;
// //       case ('Completed'):
// //         bookings = two;
// //         break;
// //       case ('Cancelled'):
// //         bookings = three;
// //         break;
// //     }
// //     setState(() {});
// //   }
// //
// //   Future<void> bookingInit1() async {
// //     final result1 = await bookingStream1();
// //     setState(() {
// //       one = result1;
// //       bookings = one;
// //     });
// //   }
// //   Future<void> bookingInit2() async {
// //     final result2 = await bookingStream2();
// //     setState(() {
// //       two = result2;
// //     });
// //   }
// //   Future<void> bookingInit3() async {
// //     final result3 = await bookingStream3();
// //     setState(() {
// //       three = result3;
// //     });
// //   }
// //
// //
// //
// //   Stream bookingStream1() {
// //     return supabase
// //         .from('Bookings')
// //         .stream(primaryKey: ['id']).eq('Type', 'Upcoming');
// //   }
// //
// //   Stream bookingStream2() {
// //     return supabase
// //         .from('Bookings')
// //         .stream(primaryKey: ['id']).eq('Type', 'Completed');
// //   }
// //   Stream bookingStream3() {
// //     return supabase
// //         .from('Bookings')
// //         .stream(primaryKey: ['id']).eq('Type', 'Cancelled');
// //   }
// //
// //
// //   void supaChange(id,String update,slot,product,clientName,contact,duration,day,price,postId,description,productImage) async {
// //    await  supabase
// //         .from('Bookings')
// //         .delete()
// //         .match({ 'id': id });
// // //1. update
// //     await supabase.from('Bookings')
// //         .insert({
// //       'SlotTime': slot,
// //       'Product': product,
// //       'ClientName': clientName,
// //       'Contact': contact,
// //       'Duration': duration,
// //       'Day': day,
// //       'Price': price,
// //       'Type': update,
// //       'PostId': postId,
// //       'Description': description,
// //       'ProductImage': productImage,
// //
// //     });
// //
// //     // 2. Delete
// //
// //     setState(() {
// //
// //     });
// //
// //   }
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     double height = MediaQuery.of(context).size.height;
// //     // double height = MediaQuery.of(context).padding.
// //     return SafeArea(
// //       child: Container(
// //         child: Padding(
// //           padding: const EdgeInsets.only(top: 8.0),
// //           child:  SingleChildScrollView(
// //             child:Column(
// //               children: [
// //                 TittleHead(
// //                   title:  'Bookings',
// //                 ),
// //                 // Padding(
// //                 //   padding: const EdgeInsets.symmetric(
// //                 //     horizontal: 8.0,
// //                 //   ),
// //                 //   child: Row(
// //                 //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 //     children: [
// //                 //       Row(
// //                 //         mainAxisAlignment: MainAxisAlignment.start,
// //                 //         children: [
// //                 //           Container(
// //                 //             decoration: BoxDecoration(
// //                 //               color: Colors.red,
// //                 //               borderRadius: BorderRadius.circular(20.0),
// //                 //             ),
// //                 //             height: 50.0,
// //                 //             width: 50.0,
// //                 //           ),
// //                 //           const Padding(
// //                 //             padding: EdgeInsets.only(left: 8.0),
// //                 //             child: Text(
// //                 //               'Bookings',
// //                 //               style: TextStyle(
// //                 //                 fontWeight: FontWeight.bold,
// //                 //                 fontSize: 23.0,
// //                 //               ),
// //                 //             ),
// //                 //           ),
// //                 //         ],
// //                 //       ),
// //                 //
// //                 //     ],
// //                 //   ),
// //                 // ),
// //                 SizedBox(
// //                   height: 70.0,
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       MyChips.Chips(
// //                         stretch: 70.0,
// //                         inchip: 'Upcoming',
// //                         isSelected: selectedOption == 'Upcoming',
// //                         onSelected: () {
// //
// //                           setState(() {
// //                            // fromDatabase = [];
// //                             selectedOption = 'Upcoming';
// //                             streamSwitch(selectedOption);
// //
// //                             // final list = switchToList(
// //                             //     selectedOption, upComing, completed, cancelled);
// //                             // fromDatabase = list;
// //                            /// print(fromDatabase);
// //                             //   generateStream();
// //                           });
// //                         },
// //                       ),
// //                       MyChips.Chips(
// //                         stretch: 70.0,
// //                         inchip: 'Completed',
// //                         isSelected: selectedOption == 'Completed',
// //                         onSelected: () {
// //
// //                           setState(() {
// //                            // fromDatabase = [];
// //                             selectedOption = 'Completed';
// //                             streamSwitch(selectedOption);
// //                             // final list = switchToList(
// //                             //     selectedOption, upComing, completed, cancelled);
// //
// //                           });
// //                         },
// //                       ),
// //                       MyChips.Chips(
// //                         stretch: 70.0,
// //                         inchip: 'Cancelled',
// //                         isSelected: selectedOption == 'Cancelled',
// //                         onSelected: () {
// //
// //                           setState(() {
// //                            // fromDatabase = [];
// //                             selectedOption = 'Cancelled';
// //                             streamSwitch(selectedOption);
// //                             // final list = switchToList(
// //                             //     selectedOption, upComing, completed, cancelled);
// //                             // fromDatabase = list;
// //                           });
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //
// //                Column(
// //                   children: [
// //                     FutureBuilder(
// //                       future: stream(),
// //                       builder: (context, snapshot) {
// //                         switch (snapshot.connectionState) {
// //                           case ConnectionState.none:
// //                             return const SizedBox.shrink();
// //                           case ConnectionState.waiting:
// //                             return const SizedBox.shrink();
// //                           case ConnectionState.done:
// //                             if (snapshot.hasData) {
// //                               load2(selectedOption);
// //                               // Future.delayed(Duration.zero,
// //                               //         () async {
// //                               //       setState(() {
// //                               //         fromDatabase;
// //                               //       });
// //                               //     });
// //
// //                               try {
// //                                 final data = snapshot.data;
// //                                 final Map<String, dynamic>? doc =
// //                                     jsonDecode(data.toString());
// //
// //                                 final payload = doc?['data']['payload']
// //                                     as Map<String, dynamic>?;
// //
// //                                 if (payload == null) {
// //                                   print("NO data!");
// //                                 } else {
// //                                   final loadId = payload['\$id'] as String;
// //                                   if (preId.contains(loadId)) {
// //                                     print("LOAD ID : $loadId");
// //                                     print("already have");
// //
// //                                     if (loadId.isNotEmpty) {
// //                                       if (upComing.isNotEmpty) {
// //                                         final postId = payload['PostId'];
// //
// //                                         upComing.removeWhere((item) {
// //                                           print('THE DELETE : $item');
// //                                           return item.containsKey("PostId") &&
// //                                               item["Type"] == 'Upcoming' &&
// //                                               item["PostId"] == postId;
// //                                         });
// //                                         if (mounted) {
// //                                           Future.delayed(Duration.zero, () async {
// //                                             setState(() {
// //                                               upComing;
// //                                              // fromDatabase;
// //                                               print("Done");
// //                                             });
// //                                           });
// //                                         }
// //                                       }
// //                                     } else {
// //                                       print("DIDN'T Update");
// //                                     }
// //                                   } else {
// //                                     final postId = payload['PostId'];
// //                                     // final update = payload['\$permissions'];
// //                                     bool itemExists = upComing.any(
// //                                         (existingItem) =>
// //                                             existingItem['PostId'] ==
// //                                             payload['PostId']);
// //                                     bool typeRight =
// //                                         'Upcoming' == payload['PostId'];
// //
// //                                     if (!itemExists && typeRight) {
// //                                       Map<String, dynamic> insert = {
// //                                         'ClientName': payload['ClientName'] ?? "",
// //                                         'Contact': payload['Contact'] ?? "",
// //                                         'Type': payload['Type'] ?? "",
// //                                         'PostId': payload['PostId'] ?? "",
// //                                         'Day': payload['Day'] ?? "",
// //                                         'Description':
// //                                             payload['Description'] ?? "",
// //                                         'SlotTime': payload['SlotTime'] ?? "",
// //                                         'ProductImage':
// //                                             payload['ProductImage'] ?? "",
// //                                         'Product': payload['Product'] ?? "",
// //                                         'Duration': payload['Duration'] ?? "",
// //                                         'Price': payload['Price'] ?? "",
// //                                         'PhoneNumber':
// //                                             payload['PhoneNumber'] ?? ""
// //                                       };
// //                                       load();
// //
// //                                       Provider.of<ItemProvider>(context,
// //                                               listen: false)
// //                                           .updateItem(newValue: insert);
// //
// //                                       upComing.add(Provider.of<ItemProvider>(
// //                                               context,
// //                                               listen: false)
// //                                           .item);
// //                                       Future.delayed(Duration.zero, () async {
// //                                         setState(() {
// //                                           upComing;
// //                                           //fromDatabase;
// //                                           print("Done");
// //                                         });
// //                                       });
// //                                     } else {
// //                                       upComing.removeWhere((item) {
// //                                         print('THE DELETE : $item');
// //                                         return item.containsKey("PostId") &&
// //                                             item["PostId"] == postId;
// //                                       });
// //                                       Future.delayed(Duration.zero, () async {
// //                                         setState(() {
// //                                           upComing;
// //                                          // fromDatabase;
// //                                           print("Done");
// //                                         });
// //                                       });
// //
// //                                       print(payload);
// //
// //                                       final currentId = payload['\$id'] ?? '';
// //                                       preId.add(currentId);
// //                                       //final item = data['data']['payload'] as Map<String,dynamic>;
// //
// //                                       print("ITEM HERE : $payload");
// //                                     }
// //                                   }
// //                                 }
// //                               } catch (error) {
// //                                 print(error);
// //                               }
// //
// //         //////////////////////////////////////////////////////////////////////
// //                               // break;
// //                             }
// //                           case ConnectionState.active:
// //                             return const SizedBox.shrink();
// //                           default:
// //                             return const SizedBox.shrink();
// //                         }
// //                         return Container();
// //                       },
// //                     ),
// //         //Stream buileser
// //
// //                    StreamBuilder(
// //                         stream: bookings,
// //                         builder: (context, snap) {
// //                           if (snap.connectionState == ConnectionState.active) {
// //                             if (snap.hasError) {
// //                               return Text('${snap.error}');
// //                             } else if (!snap.hasData) {
// //                               return Text('No Bookings');
// //                             } else if (snap.hasData) {
// //
// //                               List<dynamic> fromDatabase = [];
// //                              fromDatabase = snap.data;
// //                               //here
// //         //                             print(datadata);
// //         //                            // List<dynamic> fromDatabase = [];
// //         // print('OPTION : $selectedOption');
// //         //                             sortData(b,a) {
// //         //                               final List<dynamic> test = [];
// //         //                               for (var item in b) {
// //         //                                 if (item['Type'] ==
// //         //                                     a) {
// //         //                                   test.add(item);
// //         //                                 }
// //         //                               }
// //         //                               print('Selected One : $test');
// //         //                               Future.delayed(Duration(milliseconds: 100), () {
// //         //                                 fromDatabase = test;
// //         //                               });
// //         //                             }
// //         //
// //         //                             sortData(datadata,selectedOption);
// //         //                             print(fromDatabase);
// //
// //
// //                               return SizedBox(
// //                                 height: height * 0.7,
// //                                 child: ListView.builder(
// //                                   itemCount: fromDatabase?.length,
// //                                   scrollDirection: Axis.vertical,
// //                                   itemBuilder: (context, index) {
// //                                     switch (selectedOption) {
// //                                       case ('Upcoming'):
// //                                         return UpComing(
// //                                           clientName: fromDatabase?[index ?? 0]
// //                                                   ['ClientName'] ??
// //                                               '',
// //                                           productName: fromDatabase?[index ?? 0]
// //                                                   ['Product'] ??
// //                                               '',
// //                                           date: fromDatabase?[index ?? 0]
// //                                                   ['Day'] ??
// //                                               '',
// //                                           description: fromDatabase?[index ?? 0]
// //                                                   ['Description'] ??
// //                                               '',
// //                                           duration: fromDatabase?[index ?? 0]
// //                                                   ['Duration'] ??
// //                                               '',
// //                                           slotTime: fromDatabase?[index ?? 0]
// //                                                   ['SlotTime'] ??
// //                                               '',
// //                                           profileImage: fromDatabase?[index ?? 0]
// //                                                   ['ProductImage'] ??
// //                                               '',
// //                                           productImage: fromDatabase?[index ?? 0]
// //                                                   ['ProductImage'] ??
// //                                               '',
// //                                           price: fromDatabase?[index ?? 0]
// //                                                   ['Price'] ??
// //                                               '',
// //                                           onPressedCall: () {
// //                                             _callNumber(fromDatabase?[index]
// //                                                 ['Contact']);
// //                                           },
// //                                           onPressedChat: () {
// //                                             ChatBox(
// //                                               fromDatabase?[index]['DocId'],
// //                                               fromDatabase?[index]['UserName'],
// //                                               fromDatabase?[index]['UserId'],
// //                                               fromDatabase?[index]['Email'],
// //                                               fromDatabase?[index]
// //                                                       ['ProfileImage'] ??
// //                                                   'https://picsum.photos/id/237/200/300',
// //                                               fromDatabase?[index]
// //                                                       ['PhoneNumber'] ??
// //                                                   'No number Yet',
// //                                             );
// //         //TODO check if the single chat an phone number is here
// //                                           },
// //                                           cancelBooking: () {
// //
// //                                             supaChange(fromDatabase?[index]['id'],'Cancelled',fromDatabase[index]['SlotTime'],fromDatabase[index]['Product'],fromDatabase[index]
// //                                             ['ClientName'],fromDatabase[index]['Contact'],fromDatabase[index]['Duration'],fromDatabase[index]['Day'],fromDatabase[index]['Price'],fromDatabase?[index]['PostId'],fromDatabase[index]
// //                                             ['Description'], fromDatabase[index]
// //                                             ['ProductImage'] );
// //                                             changeStatus(
// //                                                 fromDatabase?[index]['Type'],
// //                                                 'Cancelled',
// //                                                 upComing,
// //                                                 cancelled,
// //                                                 fromDatabase![index],
// //                                                 fromDatabase?[index]['PostId'] ??
// //                                                     "",
// //                                                 fromDatabase[index]['Day'] ?? "",
// //                                                 fromDatabase[index]['SlotTime'] ??
// //                                                     "",
// //                                                 fromDatabase[index]
// //                                                         ['ClientName'] ??
// //                                                     "",
// //                                                 fromDatabase[index]['Product'] ??
// //                                                     "",
// //                                                 fromDatabase[index]['Duration'] ??
// //                                                     "",
// //                                                 fromDatabase[index]['Contact'] ??
// //                                                     "",
// //                                                 fromDatabase[index]['Price'] ??
// //                                                     "",
// //                                                 fromDatabase[index]['Type'] ?? "",
// //                                                 fromDatabase[index]
// //                                                         ['Description'] ??
// //                                                     "",
// //                                                 fromDatabase[index]
// //                                                         ['ProductImage'] ??
// //                                                     "",
// //                                                 setState);
// //                                            // fromDatabase.removeAt(index);
// //                                             //  setState(() {});
// //                                           },
// //                                           completeBooking: () {
// //                                             supaChange(fromDatabase?[index]['id'],'Completed',fromDatabase[index]['SlotTime'],fromDatabase[index]['Product'],fromDatabase[index]
// //                                             ['ClientName'],fromDatabase[index]['Contact'],fromDatabase[index]['Duration'],fromDatabase[index]['Day'],fromDatabase[index]['Price'],fromDatabase?[index]['PostId'],fromDatabase[index]
// //                                             ['Description'], fromDatabase[index]
// //                                             ['ProductImage'] );
// //
// //                                             changeStatus(
// //                                                 fromDatabase?[index]['Type'],
// //                                                 'Completed',
// //                                                 upComing,
// //                                                 completed,
// //                                                 fromDatabase![index],
// //                                                 fromDatabase?[index]['PostId'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]['Day'] ?? "",
// //                                                 fromDatabase?[index]
// //                                                         ['SlotTime'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]
// //                                                         ['ClientName'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]
// //                                                         ['Product'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]
// //                                                         ['Duration'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]
// //                                                         ['Contact'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]
// //                                                         ['Price'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]
// //                                                         ['Type'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]
// //                                                         ['Description'] ??
// //                                                     "",
// //                                                 fromDatabase?[index]
// //                                                         ['ProductImage'] ??
// //                                                     "",
// //                                                 setState);
// //                                             // fromDatabase.removeAt(index);
// //                                             setState(() {});
// //                                           },
// //                                         );
// //                                       case ('Completed'):
// //                                         return Completed(
// //                                           clientName: fromDatabase?[index]
// //                                                   ['ClientName'] ??
// //                                               '',
// //                                           productName: fromDatabase?[index]
// //                                                   ['Product'] ??
// //                                               '',
// //                                           date: fromDatabase?[index]['Day'] ?? '',
// //                                           description: fromDatabase?[index]
// //                                                   ['Description'] ??
// //                                               '',
// //                                           duration: fromDatabase?[index]
// //                                                   ['Duration'] ??
// //                                               '',
// //                                           profileImage: fromDatabase?[index]
// //                                                   ['ProductImage'] ??
// //                                               '',
// //                                           productImage: fromDatabase?[index]
// //                                                   ['ProductImage'] ??
// //                                               '',
// //                                           price:
// //                                               fromDatabase?[index]['Price'] ?? '',
// //                                           onPressedCall: () {
// //                                             _callNumber(fromDatabase?[index]
// //                                             ['Contact']);
// //                                           },
// //                                           onPressedChat: () {
// //                                             ChatBox(
// //                                               fromDatabase?[index]['DocId'],
// //                                               fromDatabase?[index]['UserName'],
// //                                               fromDatabase?[index]['UserId'],
// //                                               fromDatabase?[index]['Email'],
// //                                               fromDatabase?[index]
// //                                                       ['ProfileImage'] ??
// //                                                   'https://picsum.photos/id/237/200/300',
// //                                               fromDatabase?[index]
// //                                                       ['PhoneNumber'] ??
// //                                                   'No number Yet',
// //                                             );
// //                                           },
// //                                         );
// //                                       case ('Cancelled'):
// //                                         return Cancelled(
// //
// //                                           clientName: fromDatabase?[index]
// //                                               ['ClientName'],
// //                                           productName: fromDatabase?[index]
// //                                               ['Product'],
// //                                           date: fromDatabase?[index]['Day'],
// //                                           description: fromDatabase?[index]
// //                                               ['Description'],
// //                                           duration: fromDatabase?[index]
// //                                               ['Duration'],
// //                                           profileImage: fromDatabase?[index]
// //                                               ['ProductImage'],
// //                                           productImage: fromDatabase?[index]
// //                                               ['ProductImage'],
// //                                           price: fromDatabase?[index]['Price'],
// //                                           onPressedCall: () {
// //                                             _callNumber(fromDatabase?[index]
// //                                             ['Contact']);
// //                                           },
// //                                           onPressedChat: () {
// //                                             ChatBox(
// //                                               fromDatabase?[index]['DocId'],
// //                                               fromDatabase?[index]['UserName'],
// //                                               fromDatabase?[index]['UserId'],
// //                                               fromDatabase?[index]['Email'],
// //                                               fromDatabase?[index]
// //                                                       ['ProfileImage'] ??
// //                                                   'https://picsum.photos/id/237/200/300',
// //                                               fromDatabase?[index]
// //                                                       ['PhoneNumber'] ??
// //                                                   'No number Yet',
// //                                             );
// //                                           },
// //                                         );
// //                                       default:
// //                                         return Container();
// //                                     }
// //                                   },
// //                                 ),
// //                               );
// //                             }
// //                           }
// //                           return SizedBox();
// //                         }),
// //
// //                     // StreamBuilder(
// //                     //   stream: generateStream(),
// //                     //   builder: (context, snapShot) {
// //                     //     if (snapShot.hasData) {
// //                     //       return Expanded(
// //                     //         flex: 1,
// //                     //           child: Text(snapShot.toString()));
// //                     //     } else {}
// //                     //     return Expanded(
// //                     //       flex: 1,
// //                     //         child: Text("No data"));
// //                     //   },
// //                     // ),
// //                     //    CardBooked(),
// //
// //                     // selectedOption == 'Upcoming' ? UpComing() : Container(),
// //                     // selectedOption == 'Completed'
// //                     //     ? const Completed()
// //                     //     : Container(),
// //                     // selectedOption == 'Cancelled'
// //                     //     ? const Cancelled()
// //                     //     : Container(),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
