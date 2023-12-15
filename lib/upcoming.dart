import 'package:flutter/material.dart';
import 'cards/cardBook.dart';
import 'componants/buttonChip.dart';

class UpComing extends StatefulWidget {
  const UpComing({super.key});

  @override
  State<UpComing> createState() => _UpComingState();
}

class _UpComingState extends State<UpComing> {
  List<Widget> upcomingCared = [];

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        // height: 400,
        child: Column(
          children: [
            CardBooked(
              cornerColor: Colors.green,
              cornerText: 'Up coming',
              buttonChoice: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: NewButton(
                      inSideChip: 'Cancel booking',
                    ),
                  )),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: NewButton(
                      inSideChip: 'Complete',
                    ),
                  )),
                ],
              ),
            ),
            // ListView.builder(
            //     reverse: true,
            //     itemCount: upcomingCared.length,
            //     itemBuilder: (context, index) {
            //       return const CardBooked(
            //         cornerColor: Colors.green,
            //         cornerText: 'Up coming',
            //         buttonChoice: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Expanded(
            //                 child: Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Chips(
            //                 inchip: 'Cancel booking',
            //               ),
            //             )),
            //             Expanded(
            //                 child: Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Chips(
            //                 inchip: 'View Details',
            //               ),
            //             )),
            //           ],
            //         ),
            //       );
            //     }),
          ],
        ),
      ),
    );
  }
}

// ListView.builder(
// reverse: true,
// itemCount: upcomingCared.length,
// itemBuilder: (context, index) {
// return CommentBubble(lastComment: comments[index]);
// //Text('Angela: ${comments[index]}');
// }),;


//.colorizedBracketPairs