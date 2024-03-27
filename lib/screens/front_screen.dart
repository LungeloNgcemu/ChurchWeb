import 'package:flutter/material.dart';
import 'dart:ui';

class FrontScreen extends StatelessWidget {
  const FrontScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Image.asset(
        'lib/images/new.jpg',
        width: window.physicalSize.width,
        height: window.physicalSize.height,
        fit: BoxFit.cover,
      ),
      const Positioned(
        top: 400.0,
        left: 40.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Boss',
              style: TextStyle(
                color: Colors.white,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                'The best Salon to make you look and \n feel beautiful in the palm of your hand',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: 600,
        left: 50,
        child: MaterialButton(
          minWidth: 300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          color: Colors.black,
          onPressed: () {
            Navigator.pushNamed(context, '/appWriteLogin');
          },
          child: const Text(
            "Continue",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ]));
  }
}
