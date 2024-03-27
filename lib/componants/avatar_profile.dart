import 'package:flutter/material.dart';

class AvatarProfile extends StatefulWidget {
  const AvatarProfile({super.key});

  @override
  State<AvatarProfile> createState() => _AvatarProfileState();
}

class _AvatarProfileState extends State<AvatarProfile> {
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding:  const EdgeInsets.symmetric(horizontal: 4.0,vertical:6.0 ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.red,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 27.0,
              child: CircleAvatar(
                backgroundColor: Colors.green,
                radius: 35.0,
              ),
            ),

          ),
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text("Name"),
          ),
        ],
      ),
    );
  }
}
