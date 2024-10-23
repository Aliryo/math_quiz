import 'package:flutter/material.dart';

class MyDropdown<T> extends StatelessWidget {
  const MyDropdown({
    super.key,
    this.label,
    this.value,
    required this.items,
    this.onChanged,
  });

  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox();
    }

    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.deepPurple[50],
      ),
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
