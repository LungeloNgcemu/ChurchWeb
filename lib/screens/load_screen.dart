import 'package:flutter/material.dart';

import '../databases/database.dart';


class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    passing();
    // TODO: implement initState
    super.initState();
  }

  void passing() async {
    AppWriteDataBase connect = AppWriteDataBase();

      final session = await connect.account.listSessions();
      print(session.total);
    print('Sessions : ${session.total}');
      if( session != null && context.mounted){
        Navigator.pushNamed(context, '/salon');
      }else if(context.mounted){
        Navigator.pushNamed(context, '/RegisterAppwrite');
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
