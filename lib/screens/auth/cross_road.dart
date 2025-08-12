import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/install_pwa/install_pwa.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/componants/image_screen.dart';
import 'package:master/util/alerts.dart';
import '../../componants/extrabutton.dart';

class CrossRoad extends StatefulWidget {
  const CrossRoad({super.key});

  @override
  State<CrossRoad> createState() => _CrossRoadState();
}

class _CrossRoadState extends State<CrossRoad> {
  Authenticate auth = Authenticate();
  SqlDatabase sql = SqlDatabase();
  InstallPwa installPwa = InstallPwa();

  @override
  void initState() {
    auth.endSession();
    sql.deleteBase();
    checkInstall(context);
    super.initState();
  }

  Future<void> checkInstall(BuildContext context) async {
    bool isInstalled = await InstallPwa.isInstalled();
    print('isInstalled $isInstalled');
    
    if (!isInstalled) {
      String platform = InstallPwa.platform();
      print('platform $platform');
      if (platform == 'ios') {
        await alertIos(
            context,
            "To install this app on iOS:\n\n"
            "1. Tap the Share button (bottom center in Safari).\n"
            "2. Select 'Add to Home Screen'.\n\n"
            "This will install the app on your device for the best experience.",
            () async {
          await InstallPwa.setInstalled();
        });
      } else {
        alertInstall(context, "Install the app to get the best experience",
            () async {
          await InstallPwa.setInstalled();
          InstallPwa.showInstallPrompt();
        });
      }
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
            Navigator.pushNamed(context, '/createAccount');
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
