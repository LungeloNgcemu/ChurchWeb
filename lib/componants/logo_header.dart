import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master/constants/constants.dart';
import 'package:provider/provider.dart';

import '../classes/church_init.dart';
import '../screens/post/post_screen.dart';
import '../providers/url_provider.dart';
import 'overview.dart';

class LogoHeader extends StatelessWidget {
  LogoHeader({this.title, this.image, super.key});

  String? title;
  String? image;

  ChurchInit churchStart = ChurchInit();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  height: 50.0,
                  width: 50.0,
                  child: Container(
                    height: h * 0.3,
                    child: Image.network(image ?? Assets.placeholder),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  title ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
