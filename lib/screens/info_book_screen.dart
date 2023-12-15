import 'package:flutter/material.dart';
import 'package:master/componants/extrabutton.dart';
import 'booking_screen.dart';
import '../componants/chips.dart' as MyChips;
import 'booking_screen.dart';
import '../upcoming.dart';
import '../completed.dart';
import '../cancelled.dart';
import '../cards/cardBook.dart';

String? selectedOption;

class InfoBook extends StatefulWidget {
  const InfoBook({super.key});

  @override
  State<InfoBook> createState() => _InfoBookState();
}

class _InfoBookState extends State<InfoBook> {
  String selectedOption = 'Upcoming';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top:8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Bookings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 23.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 30.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Icon(
                          Icons.more_horiz,
                          size: 30.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 70.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyChips.Chips(
                    stretch: 70.0,
                    inchip: 'Upcoming',
                    isSelected: selectedOption == 'Upcoming',
                    onSelected: () {
                      setState(() {
                        selectedOption = 'Upcoming';
                      });
                    },
                  ),
                  MyChips.Chips(
                    stretch: 70.0,
                    inchip: 'Completed',
                    isSelected: selectedOption == 'Completed',
                    onSelected: () {
                      setState(() {
                        selectedOption = 'Completed';
                      });
                    },
                  ),
                  MyChips.Chips(
                    stretch: 70.0,
                    inchip: 'Cancelled',
                    isSelected: selectedOption == 'Cancelled',
                    onSelected: () {
                      setState(() {
                        selectedOption = 'Cancelled';
                      });
                    },
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                height: 400.0,
                child: Column(
                  children: [
                    //    CardBooked(),
                    selectedOption == 'Upcoming' ? const UpComing() : Container(),
                    selectedOption == 'Completed'
                        ? const Completed()
                        : Container(),
                    selectedOption == 'Cancelled'
                        ? const Cancelled()
                        : Container(),
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
