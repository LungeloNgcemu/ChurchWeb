import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'text_input.dart';
import 'extrabutton.dart';

import '../screens/salon_screen.dart';
import '../screens/booking_screen.dart';

Color colour = Colors.white;


class NewButton extends StatefulWidget {
  final String inSideChip;
  final Color? tapColor;
  final VoidCallback? where;

  const NewButton({
    Key? key,
    required this.inSideChip,
    this.tapColor,
    this.where ,
  }) : super(key: key);

  @override
  _NewButtonState createState() => _NewButtonState();
}

class _NewButtonState extends State<NewButton> {
  bool isSelected = false;
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.where?? () {},
      style: OutlinedButton.styleFrom(
        elevation: 5.0,        
        foregroundColor: Colors.red.withOpacity(0.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        side:  const BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
        
      ),

      child: Text(
        widget.inSideChip,
        style: TextStyle(color: isSelected ? Colors.black : Colors.black),
      ),
    );
  }}