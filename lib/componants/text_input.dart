import 'package:flutter/material.dart';

class ForTextInput extends StatelessWidget {
  ForTextInput({
    this.label,this.text,this.con,this.onChanged,this.controller,
  });

   final String? label;
   final String? text;
   final IconData? con;
   Function(String)? onChanged;
   final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller, 
        onChanged: onChanged?? (String){},
        decoration: InputDecoration(
          prefixIcon:Padding(
            padding: EdgeInsets.only(left: 18.0, right: 5.0),
            child: Icon(con ?? Icons.lock_open_sharp),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          labelText: label ?? 'Input',
          hintText: text ?? 'Input',
        ),
      ),
    );
  }
}
