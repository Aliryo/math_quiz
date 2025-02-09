import 'package:flutter/material.dart';

import '../../helpers/index.dart';

class WidgetTimer extends StatelessWidget {
  const WidgetTimer({
    super.key,
    required this.remainingTime,
    required this.currentQuestionIndex,
  });

  final int remainingTime;
  final int currentQuestionIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer,
                color: Colors.purpleAccent[100],
              ),
              const SizedBox(width: 5),
              Text(
                CommonHelper.formatTimer(remainingTime),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent[100],
                ),
              ),
            ],
          ),
        ),
        Text(
          '${currentQuestionIndex + 1}/10',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.purpleAccent[100],
          ),
        ),
      ],
    );
  }
}
