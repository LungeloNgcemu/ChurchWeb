import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/church_init.dart';
import '../providers/url_provider.dart';
//TOdo change color
class Chips extends StatefulWidget {
  const Chips({this.inchip, this.isSelected, this.onSelected,this.stretch, super.key});

  final String? inchip;
  final bool? isSelected;
  final VoidCallback? onSelected;
  final double? stretch;

  @override
  State<Chips> createState() => _ChipsState();
}

class _ChipsState extends State<Chips> {
  String? selectedOption;

  ChurchInit churchStart = ChurchInit();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, right: 10.0),
      child: ChoiceChip(
        label: SizedBox(

          width:  widget.stretch?? 60.0,
          height: 25.0,
          child: Center(
            child: FittedBox(
              child: Text(
                widget.inchip ?? '',
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        selected: widget.isSelected?? false,
        onSelected: (value) {
          if (value) {
            widget.onSelected!();
          }
        },
        disabledColor: Colors.white,
        selectedColor: Color(0xFFA9A9A9)      ,
        side: BorderSide(
          color:Color(0xFFA9A9A9) ,
          width: 3.0,
        ),
      ),
    );
  }
}