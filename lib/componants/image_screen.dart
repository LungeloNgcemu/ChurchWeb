import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({

    this.picture,
    this.message,
    this.next,
    this.skip,
    this.button,
    this.writing,
  });
  final Image? picture;
  final Text? message;
  final VoidCallback? next;
  final VoidCallback? skip;
  final Widget? button;
  final Text? writing;


  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 400.0,
            child: picture?? Container(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 45.0),
          child: message?? Container(),
        ),
        const SizedBox(
          height: 60.0,
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        color: Colors.black,
                        onPressed: next??(){},
                        child: writing ?? Container(),
                      ),
                    ),
                  ),
                ],
              ),
              button?? Container(),
            ],
          ),
        ),
      ],
    );
  }
}
//const Text(
//                         writing?? Container(),
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           color: Colors.white,
//ExtraButton(skip: skip)


//const Text(
//                         writing?? Container(),
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           color: Colors.white,
//ExtraButton(skip: skip)

