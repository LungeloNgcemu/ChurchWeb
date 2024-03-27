import 'package:flutter/material.dart';
import 'package:master/databases/database.dart';
import 'package:master/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/componants/extrabutton.dart';
import 'code.dart';
//Appwrite is the cheaper option for the one time OTP
class RegisterAppwrite extends StatefulWidget {
  const RegisterAppwrite({super.key});

  @override
  State<RegisterAppwrite> createState() => _RegisterAppwriteState();
}

class _RegisterAppwriteState extends State<RegisterAppwrite> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {

    //signOut();
    // TODO: implement initState
    super.initState();
  }

  void activeSession() async {
    AppWriteDataBase connect = AppWriteDataBase();
    final session = await connect.account.listSessions();
    print(session.total);
    if(session != null){
      Navigator.pushNamed(context, '/salon');
    }

  }

  void signOut() async {
    AppWriteDataBase connect = AppWriteDataBase();
    await connect.account.deleteSessions();
    print("Session Refreshed");
  }

  AppWriteDataBase connect = AppWriteDataBase();
  String password = '';
  String email = '';
  String userName = '';
  String number = '';
  String code = '';

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerNumber = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerCode = TextEditingController();

// register user

  void createAccount(
    String name,
    String number,
    String email,
    String password,
  ) async {
    try {
      var uuid = Uuid();

      var userId = uuid.v6();
      var docId = uuid.v6();

      final user = await connect.account
          .create(userId: userId, email: email, password: password, name: name);

      final id = user.$id;

      final session = await connect.account.createEmailSession(
        email: email,
        password: password,
      );

      await connect.databases.createDocument(
          databaseId: '65c375bf12fca26c65db',
          collectionId: '65d1e705ceb53916f35a',
          documentId: docId,
          data: {
            'UserId': id,
            'Email': email,
            'UserName': name,
          });

      if (user != null) {
        Navigator.pushNamed(context, '/salon');
      }
    } catch (error) {
      print(error);
    }
  }

  void createPhoneAccount(String number, String name) async {
    try {
      var uuid = Uuid();
      var userId = uuid.v6();
      var docId = uuid.v6();




      final sessionToken = await connect.account.createPhoneSession(
        userId: userId,
        phone: '+27$number',
      );
      print('Here ${sessionToken.userId}');



      //Check if the number exist in the data base...
      final data = await supabase.from('Manager').select('PhoneNumber').eq('PhoneNumber', '+27$number').single();
      final data1 = data['PhoneNumber'];
      print(data1);

      if(data1 != '+27$number') {
        await supabase.from('Manager').insert({
          'ManagerName': name,
          'ManagerId': userId,
          'PhoneNumber': '+27$number',
        });
      }

      if (sessionToken != null) {
        Navigator.pushNamed(context, '/code');
      }
    } catch (error) {
      print(error);
    }
  }


  void createPhoneAccount1(String number, String name) async {
    try {
      final phoneNumber = '+27$number';

      // Check if the phone number exists in the database
      final existingUser = await supabase.from('Manager').select('ManagerId').eq('PhoneNumber', phoneNumber).single();
      final userId = existingUser != null ? existingUser['ManagerId'] : Uuid().v6();


      if (existingUser == null) {
        await supabase.from('Manager').insert({
          'ManagerName': name,
          'ManagerId': userId,
          'PhoneNumber': phoneNumber,
        });
      }

      // Create phone session
      final sessionToken = await connect.account.createPhoneSession(
        userId: userId,
        phone: phoneNumber,
      );
      print('Here ${sessionToken.userId}');
      context.read<tockenProvider>().updateTocken(newValue: sessionToken.userId);

      if (sessionToken != null) {
        Navigator.pushNamed(context, '/code');
      }
    } catch (error) {

      final phoneNumber = '+27$number';
      final userId =  Uuid().v6();

      final sessionToken = await connect.account.createPhoneSession(
        userId: userId,
        phone: phoneNumber,
      );

      await supabase.from('Manager').insert({
        'ManagerName': name,
        'ManagerId': userId,
        'PhoneNumber': phoneNumber,
      });

      context.read<tockenProvider>().updateTocken(newValue: sessionToken.userId);

      Navigator.pushNamed(context, '/code');
      print(error);
    }
  }
i

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: h * 0.9,
            //  color: Colors.grey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Register or Login To Account Now',
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
                      message: 'Enter Name',
                      controller: controllerName,
                      label: 'Name',
                      text: 'Name',
                      onChanged: (value) {
                        userName = value;
                      },
                    ),
                    InputAppwrite(
                      message: 'Enter Phone Number',
                      controller: controllerNumber,
                      label: 'Number',
                      text: 'Number',
                      onChanged: (value) {
                        number = value;
                      },
                    ),
                  ],
                ),
                // InputAppwrite(
                //   message: 'Enter Email',
                //   controller: controllerEmail,
                //   label: 'Email',
                //   text: 'Email',
                //   onChanged: (value) {
                //     email = value;
                //   },
                // ),
                // InputAppwrite(
                //   message: 'Enter Password',
                //   controller: controllerPassword,
                //   label: 'Password',
                //   text: 'Password',
                //   onChanged: (value) {
                //     password = value;
                //   },
                // ),
                ExtraButton(
                  skip: () {
                    createPhoneAccount1(number, userName);
                    //Navigator.pushNamed(context, '/code');
                  },
                  writing2: Text(
                    'Register or Login',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
                // InputAppwrite(
                //   message: 'Enter Code',
                //   controller: controllerCode,
                //   label: 'Code',
                //   text: 'Code',
                //   onChanged: (value) {
                //     code = controllerCode.text;
                //   },
                // ),
                //
                // ExtraButton(
                //   skip: () async {
                //     await connect.account.deleteSessions();
                //   },
                //   writing2: Text(
                //     'SignOut',
                //     style: TextStyle(color: Colors.white, fontSize: 20.0),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputAppwrite extends StatelessWidget {
  InputAppwrite(
      {this.controller,
      this.onChanged,
      this.text,
      this.label,
      this.message,
      super.key});

  TextEditingController? controller;
  Function(String)? onChanged;
  String? label;
  String? text;
  String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            message ?? '',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        ForTextInput(
          controller: controller,
          onChanged: onChanged ?? (String) {},
          label: label,
          text: text,
        ),
      ],
    );
  }
}
