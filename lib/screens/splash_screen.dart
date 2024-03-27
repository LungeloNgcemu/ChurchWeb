import 'package:flutter/material.dart ';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:master/screens/load_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../databases/database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> activeSession() async {
    AppWriteDataBase connect = AppWriteDataBase();
    final session = await connect.account.listSessions();
    print('Sessions : ${session.total}');
    if (session != null) {
      Navigator.pushNamed(context, '/salon');
    } else {
      Navigator.pushNamed(context, '/RegisterAppwrite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterSplashScreen.fadeIn(
        //animationDuration: Duration(milliseconds: 2000),
        backgroundColor: Colors.white,
        onInit: () {
          debugPrint("On Init");
        },
        onEnd: () {
          debugPrint("On End");
        },
        childWidget: SizedBox(
          height: 200,
          width: 200,
          child: Image.asset("lib/images/splashPic.jpg"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"),
        //nextScreen: const LoadingScreen(),
        asyncNavigationCallback: () async {
          try {
            await Future.delayed(const Duration(seconds: 3));
            AppWriteDataBase connect = AppWriteDataBase();
            final session = await connect.account.get();
            print(session.phone);
            if (session.phone != null && context.mounted) {
              Navigator.pushNamed(context, '/salon');
            } else if (context.mounted) {
              Navigator.pushNamed(context, '/RegisterAppwrite');
            }
          } catch (error) {
            Navigator.pushNamed(context, '/RegisterAppwrite');
            // return Alert(
            //   context: context,
            //   type: AlertType.error,
            //   title: "ALERT",
            //   desc: '$error',
            //   buttons: [
            //     DialogButton(
            //       child: Text(
            //         "Close",
            //         style: TextStyle(color: Colors.white, fontSize: 20),
            //       ),
            //       onPressed: () => Navigator.pop(context),
            //       width: 120,
            //     )
            //   ],
            // ).show();
          }
        },
      ),
    );
  }
}
