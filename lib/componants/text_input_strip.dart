import 'package:flutter/material.dart';
import 'package:master/componants/text_input.dart';

class TextInputStrip extends StatefulWidget {
  const TextInputStrip({this.title,this.con, this.controller, this.keyboard, this.label, super.key});

  final String? title;
  final String? label;
  final IconData? con;
  final TextEditingController? controller;
  final TextInputType? keyboard;

  @override
  State<TextInputStrip> createState() => _TextInputStripState();
}

class _TextInputStripState extends State<TextInputStrip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(102, 158, 158, 158),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.0, bottom: 10.0),
                child: Text(
                  widget.title ?? "",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ],
          ),
          ForTextInput(
            label: widget.label,
            con: widget.con,
            controller: widget.controller,
            keyboard: widget.keyboard,
          ),
        ],
      ),
    );
  }
}
