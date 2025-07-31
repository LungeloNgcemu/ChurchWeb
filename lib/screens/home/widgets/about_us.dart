import 'package:flutter/material.dart';
import 'package:master/providers/url_provider.dart';
import 'package:provider/provider.dart';
import '../../../classes/church_init.dart';
import '../../../componants/overview.dart';
import '../church_screen.dart';
import 'package:readmore/readmore.dart';

class AboutUs extends StatelessWidget {
  AboutUs({
    super.key,
  });
  ChurchInit churchStart = ChurchInit();

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                children: [
                  // Icon(Icons.church_outlined),
                  // SizedBox(width: 10),
                  Text(
                    "Vision and Mission",
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 15.0,
              ),
              child: ReadMoreText(
                Provider.of<christProvider>(context, listen: false)
                        .myMap?['Project']?['Read'] ??
                    "",
                trimLines: 2,
                colorClickableText: Colors.pink,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
                moreStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 15.0,
              ),
              child: ReadMoreText(
                Provider.of<christProvider>(context, listen: false)
                        .myMap?['Project']?['About'] ??
                    "",
                trimLines: 2,
                colorClickableText: Colors.pink,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
                moreStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            //  const  Padding(
            //     padding: EdgeInsets.only(bottom: 10.0),
            //     child: Align(
            //       alignment: Alignment.centerLeft,
            //       child: Text(
            //         'Working Hours',
            //         textAlign: TextAlign.start,
            //         style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text('Monday - Saturday'),
            //         Text('Sunday'),
            //       ],
            //     ),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           ': 8am - 6pm',
            //           style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         Text(
            //           ': Closed',
            //           style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // StartLeftText(
            //   call: 'Contact Us',
            //   wait: FontWeight.normal,
            // ),
            // StartLeftText(call: churchStart.projects['Project']?['ContactNumber']),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     StartLeftText(
            //       call: 'Our Address',
            //       wait: FontWeight.bold,
            //     ),
            //     StartLeftText(
            //       call: 'See on Map',
            //       wait: FontWeight.bold,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
