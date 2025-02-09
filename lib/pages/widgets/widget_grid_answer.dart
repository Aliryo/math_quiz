import 'package:flutter/material.dart';

import 'index.dart';

class WidgetGridAnswer extends StatelessWidget {
  const WidgetGridAnswer({
    super.key,
    required this.options,
    required this.onOptionSelected,
  });

  final List<String> options;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    const labels = ['A', 'B', 'C', 'D'];

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return WidgetAnswer(
            answer: options[index],
            label: labels[index],
            onTap: () => onOptionSelected(labels[index]),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
      ),
    );
  }
}
