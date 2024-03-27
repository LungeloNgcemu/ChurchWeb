import 'package:flutter/material.dart';
import 'package:master/componants/image_screen.dart';
import '../componants/image_screen.dart';
import '../componants/extrabutton.dart';
import 'package:master/databases/database.dart';
import 'package:appwrite/appwrite.dart';

class RegisterLoginScreen extends StatefulWidget {
  const RegisterLoginScreen({super.key});

  @override
  State<RegisterLoginScreen> createState() => _RegisterLoginScreenState();
}

class _RegisterLoginScreenState extends State<RegisterLoginScreen> {

  @override
  void initState() {
    activeSession();
    // TODO: implement initState
    super.initState();
  }
  // void signOut() async {
  //   AppWriteDataBase connect = AppWriteDataBase();
  //   await connect.account.deleteSessions();
  //   print("Session Refreshed");
  // }

  void activeSession() async {
    AppWriteDataBase connect = AppWriteDataBase();
    final session = await connect.account.listSessions();
    print(session.total);
    if(session != null){
      Navigator.pushNamed(context, '/salon');
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImageScreen(
        picture: Image.asset(
          'lib/images/views.jpg',
          fit: BoxFit.cover,
        ),
        message: const Text(
          "Login or Register",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        next: () {
          Navigator.pushNamed(context, '/RegisterAppwrite');
        },
        writing: const Text(
          'Register',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        button: ExtraButton(
          skip: () {
            Navigator.pushNamed(context, '/loginAppwrite');
          },
          writing2: const Text(
            'Login',
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
