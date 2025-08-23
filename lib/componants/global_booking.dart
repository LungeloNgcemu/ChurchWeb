import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:master/componants/buttonChip.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:master/databases/database.dart';
import 'package:uuid/uuid.dart';


import 'dart:io';

final supabase = Supabase.instance.client;
AppWriteDataBase connect = AppWriteDataBase();

class AppWriteDataBase {
}
// List<String> listX = [];

// xsearchDeleteBook(
//     String collection,
//     List<String> bookings,
//     String time,
//     String title,
//     String duration,
//     String image,
//     String description,
//     String clientName,
//     String clientContact,
//     String price) async {
//   //Search
//   //////////////////////////////////////////NewBookings list
//   print("BOOKINGS OLD : $bookings");
//   bookings.remove(time);
//   List<String> newBookings = [...bookings];
//   print("BOOKINGS NEW : $newBookings");
//   ////////////////////////////////////////////////////////

//   final response = await connect.databases.listDocuments(
//     databaseId: '65c375bf12fca26c65db',
//     collectionId: collection,
//     queries: [
//       Query.equal(
//         "Date",
//         [DateFormat('yyyy-MM-dd').format(selectedDay)],
//       )
//       // queries: [Query.equal("Date",[selectedDD])],
//     ],
//   );
//   print("Response for ID : $response");
//   if (response.documents.isNotEmpty) {
//     final id = response.documents.first.$id;
//     print("Document ID: $id");

//     Future result = connect.databases.updateDocument(
//         databaseId: '65c375bf12fca26c65db',
//         collectionId: collection,
//         documentId: id,
//         data: {
//           'Date': DateFormat('yyyy-MM-dd').format(selectedDay),
//           //Todo replace
//           "Time": newBookings,
//         });

//     result.then((response) {
//       print(response);
//     }).catchError((error) {
//       print(error.response);
//     });
//   } else {
//     print("No documents found for the given query.");
//   }

//   //Book
//   await supabase.from('Bookings').insert(
//     {
//       //
//       'Day': DateFormat('yyyy-MM-dd').format(selectedDay),
//       'SlotTime': time,
//       'Product': title,
//       'ClientName': clientName,
//       'Contact': clientContact,
//       'Duration': duration,
//       'Price': price,
//       'Type': "Upcoming",
//       'PostId': uuid.v1().toString(),
//       "ProductImage": image,
//       "Description": description,
//     },
//   );
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Future<List<String>> matrixSelection(
//     String selectedDD,
//     List<String> bookingTime,
//     String collection,
//     Function(void Function()) setState) async {
//   print("SELECTEDDD : $selectedDD");
//   final response = await connect.databases.listDocuments(
//     databaseId: '65c375bf12fca26c65db',
//     collectionId: collection,
//     queries: [
//       Query.equal("Date", [selectedDD])
//     ],
//   );
//   // Check each document in the response
//   try {
//     if (response.documents.isNotEmpty) {
//       for (var document in response.documents) {
//         final data = document.data;
//         final date = data['Date'];
//         print("DATA : $data");
//         print("DATE : $date");
//         if (date == selectedDD) {
//           final list = data['Time'];
//           List<String> convert = [];
//           for (var item in list) {
//             convert.add(item);
//           }
//           print("CONVERY : $convert");

//           return convert;
//         } else {
//           final documentId = uuid.v1();
//           final created = await connect.databases.createDocument(
//             databaseId: '65c375bf12fca26c65db',
//             collectionId: collection,
//             documentId: documentId,
//             data: {
//               'Date': selectedDD,
//               'Time': bookingTime,
//             },
//           );
//           final test = created.data.values;
//           print(' created HERE : $test');
//           final list = created.data['Time'];
//           print("DOCUMENT : $list");
//           List<String> convert = [];
//           for (var item in list) {
//             convert.add(item);
//           }
//           print("CREATE 1");
//           return convert;
//         }
//       }
//     } else {
//       final documentId = uuid.v1();
//       final created = await connect.databases.createDocument(
//         databaseId: '65c375bf12fca26c65db',
//         collectionId: collection,
//         documentId: documentId,
//         data: {
//           'Date': selectedDD,
//           'Time': bookingTime,
//         },
//       );
//       final test = created.data.values;
//       print(' created HERE : $test');
//       final list = created.data['Time'];
//       print("DOCUMENT : $list");
//       List<String> convert = [];
//       for (var item in list) {
//         convert.add(item);
//       }
//       print("CREATE 2");
//       return convert;
//     }
//   } catch (error) {
//     return [];
//   }
//   return [];
// }

// Future<List<String>> matrixRevolution(
//     DateTime selectedDay, List<String> bookingTime, setState) async {
//   selectedDay ??=
//       DateTime.now(); // Use null-aware operator to assign a default value
//   print("Matrix : $bookingTime");

//   String selectedDD = DateFormat('yyyy-MM-dd').format(selectedDay);
//   //change for Three matrix collections.
//   try {
//     if (bookingTime.length > 1) {
//       List<String> one = await matrixSelection(
//           selectedDD, bookingTime, '65c3d04caeab0f9a8243', setState);
//       print("ONE : $one");
//       return one as List<String>;
//     } else if (bookingTime.length == 24) {
//       List<String> two = await matrixSelection(
//           selectedDD, bookingTime, '65c8b4804d67c5dab332', setState);
//       print("TWO : $two");
//       return two as List<String>;
//     } else if (bookingTime.length == 8) {
//       List<String> three = await matrixSelection(
//           selectedDD, bookingTime, '65c8b576b25fe9c38914', setState);
//       print("THREE : $three");

//       return three as List<String>;
//     } else {
//       print("THE LIST DOESNT EXIST");
//       return [];
//     }
//   } catch (error) {
//     print("MATRIX ERROR : $error");
//     return [];
//   }
// }

// var alertStyle = AlertStyle(
//   animationType: AnimationType.grow,
//   isCloseButton: false,
//   isOverlayTapDismiss: false,
//   descStyle: TextStyle(fontWeight: FontWeight.bold),
//   descTextAlign: TextAlign.center,
//   animationDuration: Duration(milliseconds: 400),
//   alertBorder: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(25.0),
//     side: BorderSide(
//       color: Colors.grey,
//     ),
//   ),
//   titleStyle: TextStyle(
//     color: Colors.red,
//   ),
//   alertAlignment: Alignment.center,
// );

// List<String> bookingTime1 = [
//   '6:00 - 7:00',
//   '7:00 - 8:00',
//   '8:00 - 9:00',
//   '9:00 - 10:00',
//   '10:00 - 11:00',
//   '11:00 - 12:00',
//   '12:00 - 13:00',
//   '13:00 - 14:00',
//   '14:00 - 15:00',
//   '15:00 - 16:00',
//   '16:00 - 17:00',
//   '17:00 - 18:00',
// ];
// //12

// List<String> bookingTime30 = [
//   '6:00 - 6:30',
//   '6:30 - 7:00',
//   '7:00 - 7:30',
//   '7:30 - 8:00',
//   '8:00 - 8:30',
//   '8:30 - 9:00',
//   '9:00 - 9:30',
//   '9:30 - 10:00',
//   '10:00 - 10:30',
//   '10:30 - 11:00',
//   '11:00 - 11:30',
//   '11:30 - 12:00',
//   '12:00 - 12:30',
//   '12:30 - 13:00',
//   '13:00 - 13:30',
//   '13:30 - 14:00',
//   '14:00 - 14:30',
//   '14:30 - 15:00',
//   '15:00 - 15:30',
//   '15:30 - 16:00',
//   '16:00 - 16:30',
//   '16:30 - 17:00',
//   '17:00 - 17:30',
//   '17:30 - 18:00',
// ];
// //24
// List<String> bookingTime1Hr30min = [
//   '6:00 - 7:30',
//   '7:30 - 9:00',
//   '9:00 - 10:30',
//   '10:30 - 12:00',
//   '12:00 - 13:30',
//   '13:30 - 15:00',
//   '15:00 - 16:30',
//   '16:30 - 18:00',
// ];
// //8

// List<String> bookingTime = [];

// List<String> booked = []; // need to decide what to do with this list
// List<dynamic> specificAll =
//     []; // needs to go into the cloud its the booking list
// Map<dynamic, dynamic> matrix = {};
// Map<dynamic, dynamic> matrix1 = {};
// Map<dynamic, dynamic> matrix2 = {};
// Map<dynamic, dynamic> matrix3 = {};
// List<String> currentList = ['Select Day'];
// String? selectedDD;
// DateTime selectedDay = DateTime.now();
// DateTime focusedDay = DateTime.now();
// CalendarFormat calendarFormat = CalendarFormat.month;
// var uuid = Uuid();

// // Future<List<String>> getCurrentList(Function(void Function()) setState) async {
// //
// //   return await connect.databases
// //       .listDocuments(
// //           databaseId: '65c375bf12fca26c65db',
// //           // if its another list since there is three time frames the collection id has to be dynamic.
// //           collectionId: '65c37bc7d33f2414cd49')
// //       .then((value) {
// //     if (value.documents.isNotEmpty) {
// //       print(value.documents[0].data['Time']);
// //       final list = value.documents[0].data['Time'];
// //       print("the list : $list");
// //       //
// //       // final newList = list.data.map((item){
// //       //   item.toString();
// //       // }).toList();
// //
// //       List<String> finalDraft = [];
// //       for (var item in list) {
// //         print("'$item'");
// //         finalDraft.add(item);
// //       }
// //       print('YESSSS : $finalDraft');
// //
// //       // print('Finally : $newList');
// //       ////////////////////////////////////
// //       // setState(() {
// //       //   currentList = finalDraft.toList() ?? [];
// //       // });
// //       return finalDraft;
// // //////////////////////////////////////
// //     } else {
// //       return [];
// //       print('No documents found');
// //     }
// //   });
// // }

// Future<List<String>> getCurrentList(Function(void Function()) setState) async {
//   try {
//     final data = await supabase.from('Appointment').select('Time').single();
//     print("TIME Time");

//     List<String> change = [];
//     if (data.isNotEmpty) {
//       final list = data['Time'];
//       print('List: $list');

//       for(var item in list){
//         change.add(item);
//       }

//       return change;
// //////////////////////////////////////
//     } else {
//       print('No documents found');
//       return [];
//     }
//   } catch (error) {
//     print(error);
//     return [];
//   }
// }

// // void matrixRevolution(DateTime selectedDay,List<String> bookingTime) async {
// //   AppWriteDataBase connect = AppWriteDataBase();
// //   //matrix1
// //
// //   selectedDay == null ? selectedDay = DateTime.now() : selectedDay;
// //
// //   String selectedDD = DateFormat('yyyy-MM-dd').format(selectedDay);
// //
// //   if (bookingTime.length > 1) {
// // //Matrix One
// //     final response = await connect.databases.listDocuments(
// //       databaseId: '65c375bf12fca26c65db',
// //       collectionId: '65c3d04caeab0f9a8243',
// //       queries: [Query.equal('Date', selectedDD)],
// //     );
// //
// //     if (response.documents.isNotEmpty) {
// //       await connect.databases
// //           .getDocument(
// //               databaseId: '65c375bf12fca26c65db',
// //               collectionId: '65c3d04caeab0f9a8243',
// //               documentId: selectedDD)
// //           .then((value) {
// //         final list = value.data['Date'];
// //         print('nooooooo : $list');
// //       });
// //     } else {
// //       connect.databases.createDocument(
// //         databaseId: '65c375bf12fca26c65db',
// //         collectionId: '65c3d04caeab0f9a8243',
// //         documentId: uuid.v1(),
// //         data: {
// //           'Date': DateFormat('yyyy-MM-dd').format(selectedDay),
// //           'Time': bookingTime,
// //         },
// //       ).then((value){
// //         final list = value.data['Date'];
// //         print(list);
// //       });
// //     }
// //     /////////////////////////////////////////////////////////////////
// //   } else if (bookingTime.length == 24) {
// //     print('No documents found');
// //     final response = await connect.databases.listDocuments(
// //       databaseId: '65c375bf12fca26c65db',
// //       collectionId: '65c3d04caeab0f9a8243',
// //       queries: [Query.equal('Date', selectedDD)],
// //     );
// //
// //     if (response.documents.isNotEmpty) {
// //       await connect.databases
// //           .getDocument(
// //               databaseId: '65c375bf12fca26c65db',
// //               collectionId: '65c3d04caeab0f9a8243',
// //               documentId: selectedDD)
// //           .then((value) {
// //         final list = value.data['Day'];
// //         print(list);
// //       });
// //
// //       ///////////////////////////////////////////////////////////////////
// //     } else {
// //       final response = await connect.databases.listDocuments(
// //         databaseId: '65c375bf12fca26c65db',
// //         collectionId: '65c3d04caeab0f9a8243',
// //         queries: [Query.equal('Date', selectedDD)],
// //       );
// //
// //       if (response.documents.isNotEmpty) {
// //         await connect.databases
// //             .getDocument(
// //                 databaseId: '65c375bf12fca26c65db',
// //                 collectionId: '65c3d04caeab0f9a8243',
// //                 documentId: selectedDD)
// //             .then((value) {
// //           final list = value.data['Day'];
// //           print(list);
// //         });
// //       }
// //     }
// //   }
// // }

// ////////////////////////////////////////////////////////////////////////

// List<String> selectedBookDday(DateTime? selectedDay, List<String> bookingTime,
//     Function(void Function()) setState) {
//   if (bookingTime.length == 12) {
//     setState(() {
// // collection
//       matrix = matrix1;
//     });
//   } else if (bookingTime.length == 24) {
//     setState(() {
//       matrix = matrix2;
//     });
//   } else {
//     setState(() {
//       matrix = matrix3;
//     });
//   }

//   selectedDay == null ? selectedDay = DateTime.now() : selectedDay;
//   selectedDD = DateFormat('yyyy-MM-dd').format(selectedDay);

//   if (matrix.containsKey(selectedDD)) {
//     return matrix[selectedDD] as List<String>;
//   } else {
//     matrix[selectedDD!] = [...bookingTime];
//     return matrix[selectedDD] as List<String>;
//   }
// }

// // List<String> selectedBookDday(DateTime? selectedDay, List<String> bookingTime,
// //     //selected day is local
// //     Function(void Function()) setState) {
// //   if (bookingTime.length == 12) {
// //     setState(() {
// //       matrix = matrix1;
// //     });
// //   } else if (bookingTime.length == 24) {
// //     setState(() {
// //       matrix = matrix2;
// //     });
// //   } else {
// //     setState(() {
// //       matrix = matrix3;
// //     });
// //   }
// //
// //   selectedDay == null ? selectedDay = DateTime.now() : selectedDay;
// //   selectedDD = DateFormat('yyyy-MM-dd').format(selectedDay);
// //
// //   if (matrix.containsKey(selectedDD)) {
// //     return matrix[selectedDD] as List<String>;
// //   } else {
// //     matrix[selectedDD!] = [...bookingTime];
// //     return matrix[selectedDD] as List<String>;
// //   }
// // }

// void showInfoDialog(BuildContext context, IconData icon, String message) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         icon: Icon(icon),
//         iconColor: Colors.green,
//         title: Text(message),
//       );
//     },
//   );
// }

// searchDeleteBook(
//     String collection,
//     List<String> bookings,
//     String time,
//     String title,
//     String duration,
//     String image,
//     String description,
//     String clientName,
//     String clientContact,
//     String price) async {
//   //Search
//   //////////////////////////////////////////NewBookings list
//   print("BOOKINGS OLD : $bookings");
//   bookings.remove(time);
//   List<String> newBookings = [...bookings];
//   print("BOOKINGS NEW : $newBookings");
//   ////////////////////////////////////////////////////////

//   final response = await connect.databases.listDocuments(
//     databaseId: '65c375bf12fca26c65db',
//     collectionId: collection,
//     queries: [
//       Query.equal(
//         "Date",
//         [DateFormat('yyyy-MM-dd').format(selectedDay)],
//       )
//       // queries: [Query.equal("Date",[selectedDD])],
//     ],
//   );
//   print("Response for ID : $response");
//   if (response.documents.isNotEmpty) {
//     final id = response.documents.first.$id;
//     print("Document ID: $id");

//     Future result = connect.databases.updateDocument(
//         databaseId: '65c375bf12fca26c65db',
//         collectionId: collection,
//         documentId: id,
//         data: {
//           'Date': DateFormat('yyyy-MM-dd').format(selectedDay),
//           //Todo replace
//           "Time": newBookings,
//         });

//     result.then((response) {
//       print(response);
//     }).catchError((error) {
//       print(error.response);
//     });
//   } else {
//     print("No documents found for the given query.");
//   }

//   //Book
//   connect.databases.createDocument(
//     databaseId: '65c375bf12fca26c65db',
//     collectionId: '65c902f10e37ac37f20a',
//     documentId: uuid.v1(),
//     data: {
//       //
//       'Day': DateFormat('yyyy-MM-dd').format(selectedDay),
//       'SlotTime': time,
//       'Product': title,
//       'ClientName': clientName,
//       'Contact': clientContact,
//       'Duration': duration,
//       'Price': price,
//       'Type': "Upcoming",
//       'PostId': uuid.v1().toString(),
//       "ProductImage": image,
//       "Description": description,
//     },
//   );
// }

// bookerBooker(
//     DateTime selectedDay,
//     List<String> bookings,
//     bool isSelected,
//     List<String> bookingTime,
//     List<dynamic> specificAll,
//     Function(void Function()) setState,
//     String title,
//     String duration,
//     String image,
//     String description,
//     String clientName,
//     String clientContact,
//     String price) {
//   return SizedBox(
//     height: 200.0,
//     child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             mainAxisExtent: 30,
//             childAspectRatio: 100,
//             crossAxisSpacing: 20,
//             mainAxisSpacing: 20),
//         itemCount: bookings.length,
//         itemBuilder: (context, index) {
//           return NewButton(
//             tapColor: Colors.red,
//             inSideChip: bookings[index],
// ////////////////////////////////////////
//             where: () {
//               setState(() {
//                 isSelected = true;
//                 colour = Colors.red;
//               });

//               Alert(
//                 context: context,
//                 style: alertStyle,
//                 title: "Complete Booking",
//                 buttons: [
//                   DialogButton(
//                       color: Colors.white,
//                       radius: BorderRadius.circular(20.0),
//                       border: Border.fromBorderSide(BorderSide(
//                           color: Colors.red,
//                           width: 3,
//                           style: BorderStyle.solid)),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Text(
//                         "Cancel",
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       )),
//                   DialogButton(
//                     color: Colors.white,
//                     radius: BorderRadius.circular(20.0),
//                     border: const Border.fromBorderSide(BorderSide(
//                         color: Colors.red, width: 3, style: BorderStyle.solid)),
//                     child: const Text(
//                       "Book",
//                       style: TextStyle(color: Colors.black, fontSize: 20),
//                     ),
//                     onPressed: () {
// /////////////////////////////////////////////////

//                       if (isSelected) {
//                         final time = bookings[index];
//                         ////////////////////////////////////////Navigating
//                         if (bookingTime.length > 1) {
//                           xsearchDeleteBook(
//                               '65c3d04caeab0f9a8243',
//                               bookings,
//                               time,
//                               title,
//                               duration,
//                               image,
//                               description,
//                               clientName,
//                               clientContact,
//                               price);
//                         } else if (bookingTime.length == 24) {
//                           xsearchDeleteBook(
//                               '65c8b4804d67c5dab332',
//                               bookings,
//                               time,
//                               title,
//                               duration,
//                               image,
//                               description,
//                               clientName,
//                               clientContact,
//                               price);
//                         } else if (bookingTime.length == 8) {
//                           xsearchDeleteBook(
//                               '65c8b576b25fe9c38914',
//                               bookings,
//                               time,
//                               title,
//                               duration,
//                               image,
//                               description,
//                               clientName,
//                               clientContact,
//                               price);
//                         }
//                         ///////////////////////////////////////////////
//                       }

// //////////////////////////////////////////////
//                       Navigator.of(context)
//                           .popUntil(ModalRoute.withName('/salon'));
//                       showInfoDialog(context, Icons.done, "Complete");
//                     },
//                   ),
//                 ],
//               ).show();
//             },
// /////////////////////////////////////////
//           );
//         }),
//   );
// }

// bookerBooker2(
//     DateTime selectedDay,
//     List<String> bookings,
//     bool isSelected,
//     List<String> booked,
//     List<dynamic> specificAll,
//     Function(void Function()) setState) {
//   return SizedBox(
//     height: 400.0,
//     child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             mainAxisExtent: 30,
//             childAspectRatio: 100,
//             crossAxisSpacing: 20,
//             mainAxisSpacing: 20),
//         itemCount: bookings.length,
//         itemBuilder: (context, index) {
//           return NewButton(
//             tapColor: Colors.red,
//             inSideChip: bookings[index],
// ////////////////////////////////////////
//             where: () {
//               setState(() {
//                 isSelected = true;
//                 colour = Colors.red;
//               });

//               showInfoDialog(
//                   context, Icons.date_range, "Available for Booking");
//             },
// /////////////////////////////////////////
//           );
//         }),
//   );
// }

// Stream<Map<String, dynamic>> generateStream() {
//   final realtime = connect.realtime;

//   final subscription = realtime.subscribe([
//     'databases.65c375bf12fca26c65db.collections.65c902f10e37ac37f20a.documents'
//   ]);
//   return subscription.stream.map((response) => response.payload);
// }

// Future<List<Map<String, dynamic>>> getBookings() async {
//   AppWriteDataBase connect = AppWriteDataBase();

//   final response = await connect.databases.listDocuments(
//     databaseId: '65c375bf12fca26c65db',
//     collectionId: '65c902f10e37ac37f20a',
//   );

//   List<Map<String, dynamic>> bookings = [];

//   if (response.documents.isNotEmpty) {
//     for (var document in response.documents) {
//       Map<String, dynamic> item = {
//         'ClientName': document.data['ClientName'] ?? "",
//         'Contact': document.data['Contact'] ?? "",
//         'Type': document.data['Type'] ?? "",
//         'PostId': document.data['PostId'] ?? "",
//         'Day': document.data['Day'] ?? "",
//         'Description': document.data['Description'] ?? "",
//         'SlotTime': document.data['SlotTime'] ?? "",
//         'ProductImage': document.data['ProductImage'] ?? "",
//         'Product': document.data['Product'] ?? "",
//         'Duration': document.data['Duration'] ?? "",
//         'Price': document.data['Price'] ?? "",
//       };
//       bookings.add(item);
//     }

//     // print out the entire list of bookings after the loop has completed
//     print(bookings);
//   } else {
//     print("No bookings found");
//   }

//   return bookings;
// }

// List<List<dynamic>> filterList(List<dynamic> list) {
//   List<dynamic> list1 = [];
//   List<dynamic> list2 = [];
//   List<dynamic> list3 = [];

//   for (var item in list) {
//     final type = item['Type'];

//     switch (type) {
//       case 'Upcoming':
//         list1.add(item);
//         break; // Don't forget to break to continue to the next item
//       case 'Completed':
//         list2.add(item);
//         break;
//       case 'Cancelled': // Typo: should be 'Cancelled'
//         list3.add(item);
//         break;
//       default:
//         // Handle other cases if needed
//         break;
//     }
//   }
//   return [list1, list2, list3];
// }

// // void changeStatus(
// //     String oldStatus,
// //     String newStatus,
// //     List<dynamic> fromList,
// //     List<dynamic> toList,
// //     Map<String, dynamic> item,
// //     String postId,
// //     String day,
// //     String slotTime,
// //     String clientName,
// //     String product,
// //     String duration,
// //     String contact,
// //     String price,
// //     String type,
// //     String description,
// //     String image,
// //     Function(void Function()) setState) async {
// //   setState(() {
// //     isOn = true;
// //   });
// //
// //   // Product image and Profiile image?????
// //   print(oldStatus);
// //   print(newStatus);
// //   print(item);
// //   print(postId);
// //   String newId = '';
// //
// //   final response = await connect.databases.listDocuments(
// //     databaseId: '65c375bf12fca26c65db',
// //     collectionId: '65c902f10e37ac37f20a',
// //     queries: [
// //       Query.equal("Day", [
// //         day,
// //       ]),
// //       Query.equal(
// //         "Type",
// //         [oldStatus],
// //       ),
// //       Query.equal(
// //         "PostId",
// //         [postId],
// //       ),
// //     ],
// //   );
// //   final num = response.documents.length;
// //   print(num);
// //   if (response.documents.isNotEmpty) {
// //     final id = response.documents.first.$id;
// //     print("Document ID: $id");
// //     newId = id;
// //     // update online
// //     await connect.databases.updateDocument(
// //       databaseId: '65c375bf12fca26c65db',
// //       collectionId: '65c902f10e37ac37f20a',
// //       documentId: newId,
// //       data: {
// //         'Day': day,
// //         'SlotTime': slotTime,
// //         'Product': product,
// //         'ClientName': clientName,
// //         'Contact': contact,
// //         'Duration': duration,
// //         'Price': price,
// //         'Type': newStatus,
// //         'PostId': postId,
// //         'Description': description,
// //         'ProductImage': image,
// //         //product image and profile image
// //       },
// //     );
// //     print(fromList);
// //     fromList.remove(item);
// //     upComing.remove(item);
// //
// //     print(fromList);
// //     toList.add(item);
// //     setState(() {});
// //   } else {
// //     print("Document is Empty");
// //   }
// //
// //   setState(() {
// //     isOn = false;
// //   });
// // }

// List<dynamic> upComing = [{}];
// List<dynamic> completed = [{}];
// List<dynamic> cancelled = [{}];

// remove_update_book(
//     List<String> bookings,
//     String time,
//     String title,
//     String duration,
//     String image,
//     String description,
//     String clientName,
//     String clientContact,
//     String price) async {
//   try {
// //Remove from local list
//     bookings.remove(time);
//     List<String> newBookings = [...bookings];
//     print('NEW BOOKINGS : $newBookings');

// //Update the Calander List
//     await supabase
//         .from('Calender')
//         .update({'Times': '{${newBookings.join(',')}}'}).match(
//             {'Date': DateFormat('yyyy-MM-dd').format(selectedDay)});

//     //Book
//     await supabase.from('Bookings').insert(
//       {
//         //
//         'Day': DateFormat('yyyy-MM-dd').format(selectedDay),
//         'SlotTime': time,
//         'Product': title,
//         'ClientName': clientName,
//         'Contact': clientContact,
//         'Duration': duration,
//         'Price': price,
//         'Type': "Upcoming",
//         'PostId': uuid.v1().toString(),
//         "ProductImage": image,
//         "Description": description,
//       },
//     );
//   } catch (error) {
//     print('remove_update_book error : $error');
//   }
// }

// book_blue_print(
//     DateTime selectedDay,
//     List<String> bookings,
//     bool isSelected,
//     List<String> bookingTime,
//     List<dynamic> specificAll,
//     Function(void Function()) setState,
//     String title,
//     String duration,
//     String image,
//     String description,
//     String clientName,
//     String clientContact,
//     String price) {
//   return SizedBox(
//     height: 200.0,
//     child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             mainAxisExtent: 30,
//             childAspectRatio: 100,
//             crossAxisSpacing: 20,
//             mainAxisSpacing: 20),
//         itemCount: bookings.length,
//         itemBuilder: (context, index) {
//           return NewButton(
//             tapColor: Colors.red,
//             inSideChip: bookings[index],
//             where: () {
//               setState(() {
//                 isSelected = true;
//                 colour = Colors.red;
//               });

//               Alert(
//                 context: context,
//                 style: alertStyle,
//                 title: "Complete Booking",
//                 buttons: [
//                   DialogButton(
//                       color: Colors.white,
//                       radius: BorderRadius.circular(20.0),
//                       border: const Border.fromBorderSide(BorderSide(
//                           color: Colors.red,
//                           width: 3,
//                           style: BorderStyle.solid)),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Text(
//                         "Cancel",
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       )),
//                   DialogButton(
//                     color: Colors.white,
//                     radius: BorderRadius.circular(20.0),
//                     border: const Border.fromBorderSide(BorderSide(
//                         color: Colors.red, width: 3, style: BorderStyle.solid)),
//                     child: const Text(
//                       "Book",
//                       style: TextStyle(color: Colors.black, fontSize: 20),
//                     ),
//                     onPressed: () {
//                       if (isSelected) {
//                         final time = bookings[index];
//                         remove_update_book(
//                             bookings,
//                             time,
//                             title,
//                             duration,
//                             image,
//                             description,
//                             clientName,
//                             clientContact,
//                             price);
//                       }
//                       Navigator.of(context)
//                           .popUntil(ModalRoute.withName('/salon'));
//                       showInfoDialog(context, Icons.done, "Complete");
//                     },
//                   ),
//                 ],
//               ).show();
//             },
//           );
//         }),
//   );
// }

// Future<List<String>> revolution_matrix(
//     DateTime selectedDay, List<String> bookingTime, setState) async {
//   selectedDay ??=
//       DateTime.now(); // Use null-aware operator to assign a default value

//   print("Matrix : $bookingTime");

//   String selectedDD = DateFormat('yyyy-MM-dd').format(selectedDay);

//   try {
//     List<String> one =
//         await find_create_matrix(selectedDD, bookingTime, setState);
//     print("matrix list : $one");
//     return one as List<String>;
//   } catch (error) {
//     print("MATRIX ERROR : $error");
//     return [];
//   }
// }


// Future<List<String>> find_create_matrix(String selectedDD,
//     List<String> bookingTime, Function(void Function()) setState) async {
//   try {
//     //Find the List
//     print("SELECTEDDD : $selectedDD");

//     final available = await supabase
//         .from('Calender')
//         .select('Times')
//         .eq('Date', DateFormat('yyyy-MM-dd').format(selectedDay))
//         .single();

//     final convert1 = available['Times'];
//     List<String> output = [];

//     for(var item in convert1){
//       output.add(item);

//     }
//     print("CONVET : $convert1");

//     return output;
//   } catch (error) {
//     //Create List
//     try {
//       await supabase.from('Calender').insert({
//         'Date': DateFormat('yyyy-MM-dd').format(selectedDay),
//         'Times': '{${bookingTime.join(',')}}'
//       });

//       final available2 = await supabase
//           .from('Calender')
//           .select('Times')
//           .eq('Date', DateFormat('yyyy-MM-dd').format(selectedDay))
//           .single();

//       final convert2 = available2['Times'];
//       print("CONVET : $convert2");

//       List<String> output = [];

//       for(var item in convert2){
//         output.add(item);
//       }
//       return output;
//     } catch (error) {
//       print('CANT CREATE NEW ON CALENDER E$error');
//       return [];
//     }
//   }
// }
