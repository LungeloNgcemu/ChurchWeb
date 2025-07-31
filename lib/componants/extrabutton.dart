import 'package:flutter/material.dart';

class ExtraButton extends StatelessWidget {
ExtraButton({
    super.key,
    required this.skip,
    this.writing2,
  this.color,
  });

  final VoidCallback? skip;
  final Text? writing2;
  Color? color;

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
              color: color ?? Colors.black,
              onPressed: skip??(){},
              child:writing2?? Container(),
            ),
          ),
        ),
      ],
    );
  }
}
