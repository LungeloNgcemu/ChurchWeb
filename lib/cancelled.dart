import 'package:flutter/material.dart';
import 'cards/cardBook.dart';
import 'componants/buttonChip.dart';

class Cancelled extends StatefulWidget {
  const Cancelled({super.key});

  @override
  State<Cancelled> createState() => _CancelledState();
}

class _CancelledState extends State<Cancelled> {
  List<Widget> canceledCared = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            CardBooked(
              cornerColor: Colors.red,
              cornerText: 'Cancelled',
              buttonChoice: NewButton(
                inSideChip: 'View Details',
              ),
            ),
            // ListView.builder(
            //     reverse: true,
            //     itemCount: canceledCared.length,
            //     itemBuilder: (context, index) {
            //       return const CardBooked(
            //         cornerColor: Colors.red,
            //         cornerText: 'Cancelled',
            //         buttonChoice: Chips(
            //           inchip: 'View Details',
            //         ),
            //       );
            //     }),
          ],
        ),
      ),
    );
  }
}
