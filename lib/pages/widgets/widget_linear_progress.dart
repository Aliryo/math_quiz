import 'package:flutter/material.dart';

class WidgetLinearProgress extends StatelessWidget {
  const WidgetLinearProgress({super.key, required this.progressValue});

  final double progressValue;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: const AlwaysStoppedAnimation(1.0),
      child: LinearProgressIndicator(
        borderRadius: BorderRadius.circular(6),
        value: progressValue,
        minHeight: 8,
        backgroundColor: Colors.deepPurple[100],
        valueColor: AlwaysStoppedAnimation<Color?>(Colors.purpleAccent[100]),
      ),
    );
  }
}
