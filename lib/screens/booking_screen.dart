import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../componants/text_input.dart';
import '../componants/extrabutton.dart';
import '../componants/chips.dart' as MyChips;
import 'salon_screen.dart';
import '../componants/buttonChip.dart';
import 'package:intl/intl.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/databases/database.dart';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:simple_chips_input/select_chips_input.dart';

bool? isSelected = false;

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    //bookingTime = bookingTime1;
    //currentList = selectedBookDday(selectedDay, bookingTime, setState);
    // TODO: implement initState
    super.initState();
  }

//  DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<String>> _events = {};

  Future airTimeList(List<String> list) {
    AppWriteDataBase connect = AppWriteDataBase();

    final result = connect.databases.updateDocument(
      databaseId: '65c375bf12fca26c65db',
      collectionId: '65c37bc7d33f2414cd49',
      documentId: '65c37e6d8ea27e7117e4',
      data: {'Time': list},
    );
    return result;
  }

  List<String> currentList = [];
  List<String>? listx;
  List<String> listP = [];

  Future<void> updateList(selectedDay) async {
    List<String> list = await getCurrentList(setState);
    List<String> goodx = await matrixRevolution(selectedDay, list, setState);
    setState(() {
      listP = goodx;
      listx = list;
      isLoading = false;
    });
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            // height: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0, left: 8.0),
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
                          'Create Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 23.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 1.0,
                    bottom: 20.0,
                  ),
                  child: Text(
                    '1. Select Booking Time Period',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                //////////////////////////////////////////////////////////////////////////////////////////

                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyChips.Chips(
                        inchip: "30min",
                        isSelected: selectedOption == "30min",
                        onSelected: () async {
                          await airTimeList(bookingTime30);
                          List<String> list = await getCurrentList(setState);
                          print("BANK BANK : $list");
                          List<String> good = await matrixRevolution(
                              selectedDay, list, setState);
                          print("LISTX : $good");
                          setState(() {
                            selectedOption = "30min";

                            // bookingTime = bookingTime30;
                            listX = good;

                            //this needs the current list
                            // currentList = selectedBookDday(selectedDay, bookingTime ,setState);
                          });
                        },
                      ),
                      MyChips.Chips(
                        inchip: "1 Hr",
                        isSelected: selectedOption == "1 Hr",
                        onSelected: () async {
                          await airTimeList(bookingTime1);
                          List<String> list = await getCurrentList(setState);
                          List<String> good = await matrixRevolution(
                              selectedDay, list, setState);
                          setState(() {
                            selectedOption = "1 Hr";
                            // bookingTime = bookingTime1;
                            listX = good;
                            //  currentList = selectedBookDday(selectedDay, bookingTime,setState );
                          });
                        },
                      ),
                      MyChips.Chips(
                        inchip: "1Hr 30min",
                        isSelected: selectedOption == "1Hr 30min",
                        onSelected: () async {
                          await airTimeList(bookingTime1Hr30min);
                          List<String> list = await getCurrentList(setState);
                          List<String> good = await matrixRevolution(
                              selectedDay, list, setState);
                          setState(() {
                            selectedOption = "1Hr 30min";
                            listX = good;
                            // bookingTime = bookingTime1Hr30min;
                            //  currentList = selectedBookDday(selectedDay, bookingTime,setState );
                          });
                        },
                      ),
                    ],
                  ),
                ),
                /////////////////////////////////////////////////////////////////////////////////////////
                Padding(
                  padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 0.1,
                            blurRadius: 10.0,
                          )
                        ]),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: DateTime.now(),
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedDay, day);
                      },
                      onDaySelected: (sselectedDay, focusedDay) async {
                        setState(() {
                          isLoading = true;
                          selectedDay = sselectedDay;
                          focusedDay = focusedDay;
                        });
                        updateList(selectedDay);
                      },
                      calendarFormat: calendarFormat,
                      onFormatChanged: (format) {
                        setState(() {
                          calendarFormat = format;
                        });
                      },
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Text(
                    '2.Booking Periods For Selection',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),

                // TODO this is where il have the booking Grid

                // BookingInput(
                //   onAddBookingSlot: _addBookingSlot,
                // ),

                isLoading
                    ? SizedBox(
                        height: 150,
                        child: Center(child: CircularProgressIndicator()))
                    : bookerBooker2(selectedDay, listP, isSelected!, booked,
                        specificAll, setState),

                // _buildBookingSlots(isSelected),

                // const Padding(
                //   padding: EdgeInsets.only(top: 15.0),
                //   child: Text(
                //     'Update Specilist',
                //     style: TextStyle(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 20.0,
                //     ),
                //   ),
                // ),
                // const SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Padding(
                //     padding: EdgeInsets.only(top: 15.0),
                //     child: SizedBox(
                //       height: 135.0,
                //       child: Row(
                //         children: [
                //           Specialist(),
                //           Specialist(),
                //           Specialist(),
                //           Specialist(),
                //           Specialist(),
                //           Specialist(),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                //     Padding(
                //       padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Expanded(
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(horizontal: 15.0),
                //               child: OutlinedButton(
                //                 //color: Colors.red,
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                   () {

                // };
                //                 },

                //                 style: OutlinedButton.styleFrom(
                //                   padding: const EdgeInsets.symmetric(
                //                       horizontal: 8.0, vertical: 4.0),
                //                   shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(20.0),
                //                   ),
                //                   backgroundColor: Colors.white,
                //                   side: const BorderSide(
                //                     color: Colors.red,
                //                     width: 2.0,
                //                   ),
                //                 ),
                //                 child: const Text(
                //                   'Create Booking',
                //                   style: TextStyle(
                //                     color: Colors.black,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildBookingSlots(isSelected) {
    List<String> bookingSlots = _events[selectedDay] ?? [];

    return bookingSlots.isEmpty
        ? const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(child: Text('Booking periods will appear shortly.')),
          )
        : SizedBox(
            height: 250.0,
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 45,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              scrollDirection: Axis.vertical,
              children: bookingSlots.map((slot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 200,
                    child: NewButton(
                      where: () {
                        setState(() {
                          isSelected = isSelected!;
                          colour = Colors.red;
                        });
                      },
                      tapColor: Colors.red,
                      inSideChip: slot,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
  }

  void _showBookingConfirmation(String bookingSlot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Confirmation'),
          content:
              Text('You have booked a slot at $bookingSlot on $selectedDay'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to add a booking slot for the selected day
  void _addBookingSlot(String slotTime) {
    setState(() {
      _events[selectedDay] = [...(_events[selectedDay] ?? []), slotTime];
    });
  }
}

class BookingInput extends StatefulWidget {
  final Function(String) onAddBookingSlot;

  const BookingInput({Key? key, required this.onAddBookingSlot})
      : super(key: key);

  @override
  _BookingInputState createState() => _BookingInputState();
}

class _BookingInputState extends State<BookingInput> {
  String bookingSlot = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                bookingSlot = value;
              });
            },
            decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 18.0, right: 5.0),
                child: Icon(Icons.calendar_today),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
              labelText: 'Period3',
              hintText: 'Input',
            ),
          ),
          const SizedBox(width: 10.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: NewButton(
                    where: () {
                      widget.onAddBookingSlot(bookingSlot);
                      // Optionally clear the text field after adding
                      // (You might choose to leave it as-is)
                      setState(() {
                        bookingSlot = '';
                      });
                    },
                    inSideChip: 'Create Booking Period',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class Chips extends StatefulWidget {
//   final String inchip;

//   const Chips({
//     Key? key,
//     required this.inchip,
//   }) : super(key: key);

//   @override
//   _ChipsState createState() => _ChipsState();
// }

// class _ChipsState extends State<Chips> {
//   bool isSelected = false;

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton(
//       onPressed: () {
//         setState(() {
//           isSelected = !isSelected;
//         });
//         _showBookingConfirmation(widget.inchip);
//       },
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0),
//         ),
//         backgroundColor: isSelected ? Colors.red : Colors.white,
//         side: const BorderSide(
//           color: Colors.red,
//           width: 2.0,
//         ),
//       ),
//       child: Text(
//         widget.inchip,
//         style: TextStyle(color: isSelected ? Colors.black : Colors.black),
//       ),
//     );
//   }

//   void _showBookingConfirmation(String slot) {
//     print('Selected slot: $slot');
//     // Add your confirmation logic here
//   }
// }
