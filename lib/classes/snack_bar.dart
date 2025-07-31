import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

class SnackBarNotice {
  
  snack(context, message) {
    return AnimatedSnackBar(
      builder: ((context) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(128, 0, 0, 0)!, // Shadow color
                  offset: Offset(0, 4), // Horizontal and vertical offset
                  blurRadius: 8, // Blur radius
                  spreadRadius: 2, // Optional: How much the shadow spreads
                ),
              ],
              borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.all(8),
          height: 50,
          child: Row(
            children: [
              Image.asset(
                "lib/images/clear.png",
                height: 100.0,
                width: 100.0,
              ),
              Text(message),
            ],
          ),
        );
      }),
    ).show(context);
  }
}
