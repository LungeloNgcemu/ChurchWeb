import 'package:flutter/material.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/url_provider.dart';
import 'package:provider/provider.dart';
import 'register_appwrite.dart';
import 'package:appwrite/appwrite.dart';
import 'package:master/databases/database.dart';

class CodeAppwrite extends StatefulWidget {
  const CodeAppwrite({super.key});

  @override
  State<CodeAppwrite> createState() => _CodeAppwriteState();
}

class _CodeAppwriteState extends State<CodeAppwrite> {

  AppWriteDataBase connect = AppWriteDataBase();


  void submitCode(String code) async {
    print('Hello');
    // final user = await connect.account.get();
    // print(user.$id);


    final session = await connect.account.updatePhoneSession(
        userId:'${Provider.of<tockenProvider>(context, listen: false).tocken}' ,
        secret:code
    );

    if(session != null ){}
    Navigator.pushNamed(context, '/salon');
  }

String code = '';
TextEditingController controllerCode = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Enter The Code Sent to your number via Sms',
              style: TextStyle(
                color: Colors.black,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            children: [
              InputAppwrite(
                message: 'Enter Code',
                controller: controllerCode,
                label: 'Code',
                text: 'Code',
                onChanged: (value) {
                  code = value;
                },
              ),
            ],
          ),

          ExtraButton(
            skip: ()  {
             submitCode(code);
            },
            writing2: Text(
              'Submit Code',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ),

        ],
      ),
    );
  }
}
