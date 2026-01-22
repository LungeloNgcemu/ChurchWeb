import 'package:flutter/material.dart';

class ForTextInput extends StatelessWidget {
  ForTextInput({
    this.label,
    this.text,
    this.con,
    this.onChanged,
    this.controller,
    this.keyboard,
    this.hasError = false,
    this.errorMessage,
    super.key,
  });

  final String? label;
  final String? text;
  final IconData? con;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboard;
  final bool hasError;
  final String? errorMessage;

  final _radius = const Radius.circular(30.0);

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(_radius),
      borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(_radius),
      borderSide:
          BorderSide(color: hasError ? Colors.red : Colors.blue, width: 2),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        keyboardType: keyboard ?? TextInputType.text,
        controller: controller,
        onChanged: onChanged ?? (_) {},
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(8),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 5.0),
            child: Icon(con ?? Icons.lock_open_sharp),
          ),
          labelText: label ?? 'Input',
          hintText: text ?? 'Enter',
          errorText: hasError ? errorMessage : null,
          border: border,
          enabledBorder: border,
          focusedBorder: focusedBorder,
        ),
      ),
    );
  }
}
