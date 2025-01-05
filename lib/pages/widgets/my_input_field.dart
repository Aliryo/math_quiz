import 'package:flutter/material.dart';

class MyInputField extends StatelessWidget {
  const MyInputField({
    super.key,
    this.onChanged,
    this.label,
    this.initialValue,
  });
  final Function(String)? onChanged;
  final String? label;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.deepPurple[50],
      ),
    );
  }
}
