import 'package:flutter/material.dart';
import 'componants/text_input.dart';
import 'componants/extrabutton.dart';


class ImputPage extends StatelessWidget {
  ImputPage({@required this.word, this.hype, this.pressed,this.onChanged1,this.onChanged2,this.controller1,this.controller2});

  final Text? word;
  final Text? hype;
  final VoidCallback? pressed;
  final void Function(String)? onChanged1;
  final void Function(String)? onChanged2;
  final TextEditingController? controller1;
  final TextEditingController? controller2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 30.0,
              ),
              child: Container(width: 200.0, child: hype!),
            ),
            const SizedBox(
              height: 50.0,
            ),
            // const Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: TextField(
            //     decoration: InputDecoration(
            //       prefixIcon: Padding(
            //         padding: EdgeInsets.only(left: 18.0, right: 5.0),
            //         child: Icon(Icons.email_outlined),
            //       ),
            //       border: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(30.0))),
            //       labelText: 'Email',
            //       hintText: 'Email',
            //     ),
            //   ),
            // ),
            ForTextInput(
              onChanged: onChanged1 ?? (String value) {},
              con: Icons.mail_outline,
              label: 'Email',
              text: 'Email',
              controller: controller1,
            ),
            const SizedBox(
              height: 10.0,
            ),
            ForTextInput(
              controller: controller2,
                onChanged: onChanged2 ?? (String value) {},
              label: 'Password',
              text: 'Password',
            ),
            const SizedBox(
              height: 80.0,
            ),
            ExtraButton(
              skip: pressed ?? (){},
              writing2: word!,
            ),
          ],
        ),
      ),
    );
  }
}

