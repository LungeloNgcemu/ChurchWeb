import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/providers/user_data_provider.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';

// import 'register_leader.dart';
import 'package:master/databases/database.dart';
import '../../profile/profile_screen.dart';

class CodeAppwrite extends StatefulWidget {
  const CodeAppwrite({super.key});

  @override
  State<CodeAppwrite> createState() => _CodeAppwriteState();
}

class _CodeAppwriteState extends State<CodeAppwrite> {
  Authenticate auth = Authenticate();

  bool isLoading = false;

  String code = '';
  TextEditingController controllerCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
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
                    keyboard: TextInputType.number,
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
                skip: () async {
                  setState(() {
                    isLoading = true;
                  });

                  await Authenticate.submitCode(context, code);

                  Future.delayed(const Duration(seconds: 3), () {
                    setState(() {
                      isLoading = false;
                    });
                  });
                },
                writing2: const Text(
                  'Submit Code',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            ],
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                // Semi-transparent overlay
                child: const Center(
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
