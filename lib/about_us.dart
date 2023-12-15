import 'package:flutter/material.dart';
import 'screens/salon_screen.dart';
import 'package:readmore/readmore.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: 15.0,
          ),
          child: ReadMoreText(
            'Our salon sits at the core of our business and has been the life blood for 34 years, We only use top of the range salon professional products, and are trusted partners within the hair care industry.',
            trimLines: 2,
            colorClickableText: Colors.pink,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Show more',
            trimExpandedText: 'Show less',
            moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Working Hours',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monday - Friday'),
                Text('Saturday - Sunday'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ': 8am - 12pm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ': 8am - 6pm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        StartLeftText(
          call: 'Contact Us',
          wait: FontWeight.normal,
        ),
        StartLeftText(call: '0648992478'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StartLeftText(
              call: 'Our Address',
              wait: FontWeight.bold,
            ),
            StartLeftText(
              call: 'See on Map',
              wait: FontWeight.bold,
            ),
          ],
        ),
      ],
    );
  }
}
