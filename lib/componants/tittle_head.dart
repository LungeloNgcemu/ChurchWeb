import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart%20';
import 'package:provider/provider.dart';

import '../classes/church_init.dart';
import '../screens/post/post_screen.dart';
import '../providers/url_provider.dart';
import 'overview.dart';

class TittleHead extends StatelessWidget {
 TittleHead({this.title,this.image,super.key});

  String? title;
  String? image;

 ChurchInit churchStart = ChurchInit();

// xbuildStreamBuilder(context, "ProfileImage")

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 8.0,
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
                  child: xbuildStreamBuilder(context, "ProfileImage")
                ),
              ),
           Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  title ?? '',
                  style: TextStyle(
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
