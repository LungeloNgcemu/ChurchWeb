import 'package:flutter/material.dart';

class ExtraButton extends StatelessWidget {
  const ExtraButton({
    super.key,
    required this.skip,
    this.writing2,
  });

  final VoidCallback? skip;
  final Text? writing2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: Colors.black,
              onPressed: skip??(){},
              child:writing2?? Container(),
            ),
          ),
        ),
      ],
    );
  }
}
