import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import '../componants/chips.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard(
      {this.cornerText,
      this.cornerColor,
      this.buttonChoice,
      this.clientName,
      this.productName,
      this.date,
      this.description,
      this.duration,
      this.productImage,
      this.profileImage,
      this.price,
      this.slotTime,
      this.onPressedCall,
      this.onPressedChat,
      super.key});

  final String? cornerText;
  final Color? cornerColor;
  final Widget? buttonChoice;
  final String? clientName;
  final String? productName;
  final String? date;
  final String? description;
  final String? duration;
  final String? profileImage;
  final String? productImage;
  final String? price;
  final String? slotTime;
  final VoidCallback? onPressedChat;
  final VoidCallback? onPressedCall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10.0),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0.0),
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
        height: 295.0,
        width: double.maxFinite,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 50, // Adjust width as needed
                                height: 50, // Adjust height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors
                                      .grey[100], // Optional background color
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    profileImage ?? "",
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.error),
                                  ),
                                ),
                              )),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              clientName ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          // IconButton(
                          //   onPressed: onPressedCall ?? () {},
                          //   icon: const Icon(Icons.phone),
                          // ),
                          // IconButton(
                          //   onPressed: onPressedChat ?? () {},
                          //   icon: const Icon(Icons.message),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          date ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Material(
                          color: cornerColor ?? Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Adjust the value as needed
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              cornerText ?? 'Status?',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(
                thickness: 1.0,
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Colors.white54,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 1.0,
                                left: 15.0,
                                right: 10.0,
                              ),
                              child: Container(
                                color: Colors.white54,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 3.0, bottom: 3.0),
                                  child: Text(
                                    description ?? "",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: buttonChoice ?? Container(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
