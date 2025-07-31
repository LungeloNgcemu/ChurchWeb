import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/componants/image_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../componants/image_screen.dart';
import '../../componants/extrabutton.dart';
import 'package:master/databases/database.dart';

// Choose if your a member or leader

class CrossRoad extends StatefulWidget {
  const CrossRoad({super.key});

  @override
  State<CrossRoad> createState() => _CrossRoadState();
}

class _CrossRoadState extends State<CrossRoad> {

  Authenticate auth = Authenticate();
  SqlDatabase sql = SqlDatabase();

@override
  void initState() {
    auth.endSession();
    sql.deleteBase();
    // TODO: implement initState
    super.initState();
  }


  final Uri _url = Uri.parse('https://lungeloangcemu.github.io/Church-Connect-App-Site/');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImageScreen(
        picture: Image.asset(
          'lib/images/worship.jpg',
          fit: BoxFit.cover,
        ),
        message: const Text(
          "Welcome to Church",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        next: () {
          Navigator.pushNamed(context, '/RegisterLeader');
        },
        writing: const Text(
          'Leader',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        button: ExtraButton(
          skip: () {
            Navigator.pushNamed(context, '/RegisterMember');
          },
          writing2: const Text(
            'Member',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
        button2: ExtraButton(
          color: Colors.blue[900],
          skip: () {
            //setState
              Navigator.pushNamed(context, '/createAccount');
            // _launchUrl();
            //setState
          },
          writing2: const Text(
            'Create Free Account',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
