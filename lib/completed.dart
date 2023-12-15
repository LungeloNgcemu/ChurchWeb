import 'package:flutter/material.dart';
import 'cards/cardBook.dart';
import 'componants/buttonChip.dart';

class Completed extends StatefulWidget {
  const Completed({super.key});

  @override
  State<Completed> createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  List<Widget> completedCared = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            const CardBooked(
              cornerText: 'Completed',
              cornerColor: Colors.blue,
              buttonChoice: NewButton(
                inSideChip: 'View Details',
              ),
            ),
            // ListView.builder(
            //     reverse: true,
            //     itemCount: completedCared.length,
            //     itemBuilder: (context, index) {
            //       return const CardBooked(
            //         cornerText: 'Completed',
            //         cornerColor: Colors.blue,
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
