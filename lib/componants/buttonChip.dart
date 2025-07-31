import 'package:flutter/material.dart';
import 'package:master/classes/church_init.dart';
import 'package:provider/provider.dart';

import '../providers/url_provider.dart';

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

  ChurchInit churchStart = ChurchInit();
  
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
        side:   BorderSide(
          color:   Color(Provider.of<christProvider>(context, listen: false).myMap['Project']?['Color'] ?? '0xFF000000'),
          width: 2.0,
        ),
        
      ),
      child: Text(
        widget.inSideChip,
        style: TextStyle(color: isSelected ? Colors.black : Colors.black),
      ),
    );
  }}