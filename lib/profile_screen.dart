import 'package:flutter/material.dart';
import 'package:master/componants/extrabutton.dart';
import 'componants/text_input.dart';
import '';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50.0,
                        backgroundColor: Colors.red,
                      ),
                      Positioned(
                        top: 70.0,
                        left: 75.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.orange,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(1.0),
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ForTextInput(
                        label: 'Name',
                        text: 'Name',
                      ),
                      ForTextInput(
                        label: 'Surame',
                        text: 'Surame',
                      ),
                      ForTextInput(),
                      ForTextInput(),
                      ForTextInput(),
                      ForTextInput(),
                      ExtraButton(skip: (){Navigator.pushNamed(context, '/salon');},
                      writing2:const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ) ,
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
