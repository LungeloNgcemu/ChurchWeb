import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:master/classes/church_init.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/constants/constants.dart';
import 'package:master/databases/database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ChurchInit churchStart;
  SqlDatabase sql = SqlDatabase();

  @override
  void initState() {
    // _initChurch();
    // sql.initializeDatabase();
    super.initState();
  }

  Future<void> _initChurch() async {
    churchStart = ChurchInit();
    await churchStart.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterSplashScreen.fadeIn(
        // animationDuration: Duration(milliseconds: 2000),
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
          child: Image.asset("lib/images/clear.png"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"),
        asyncNavigationCallback: () async {
          try {
            await Future.delayed(const Duration(seconds: 5));

            AppWriteDataBase connect = AppWriteDataBase();
            SqlDatabase sql = SqlDatabase();

            String church = await sql.getChurchName();

            // final session = await connect.account.get();

            if (church.isNotEmpty && context.mounted) {
              await _initChurch();

              Navigator.of(context).pushNamedAndRemoveUntil(
                RoutePaths.church,
                (Route<dynamic> route) => false,
              );
            } else if (context.mounted) {
              Navigator.pushNamed(context, RoutePaths.crossRoad);
            }
          } catch (error) {
            if (context.mounted) {
              Navigator.pushNamed(context, RoutePaths.crossRoad);
            }
          }
        },
      ),
    );
  }
}
