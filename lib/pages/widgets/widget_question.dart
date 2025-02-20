import 'package:flutter/material.dart';

import '../../models/index.dart';

class WidgetQuestion extends StatelessWidget {
  const WidgetQuestion({
    super.key,
    required this.question,
    required this.score,
  });

  final QuestionMdl question;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Skor: $score',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.purpleAccent[100],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(
            question.imageUrl,
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.width / 2,
            errorBuilder: (_, __, ___) => Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              alignment: Alignment.center,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.questionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
