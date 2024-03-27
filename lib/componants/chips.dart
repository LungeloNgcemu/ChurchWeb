import 'package:flutter/material.dart';
import '../screens/salon_screen.dart';

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
        selectedColor: Colors.red,
        side: const BorderSide(
          color: Colors.red,
          width: 3.0,
        ),
      ),
    );
  }
}