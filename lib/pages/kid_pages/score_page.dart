import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class ScorePage extends StatelessWidget {
  const ScorePage({super.key, required this.score, required this.kidName});
  final int score;
  final String kidName;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('lib/assets/score.png'),
              IntrinsicHeight(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Halo $kidName,\nScore Kamu "$score"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          '\n"${_getScoreMessage(score)}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: MySelectionButton(
            title: 'Kembali',
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const WelcomePage(),
              ),
              (_) => false,
            ),
          ),
        ),
      ),
    );
  }
}

String _getScoreMessage(int score) {
  switch (score ~/ 10) {
    case 0:
    case 1:
    case 2:
    case 3:
      return 'Teruslah belajar, Kamu akan menjadi lebih baik!';
    case 4:
    case 5:
      return 'Kerja bagus! Kamu membaik!';
    case 6:
    case 7:
      return 'Kerja bagus! Kamu melakukan hal yang luar biasa!';
    case 8:
    case 9:
    case 10:
      return 'Wow! Kamu adalah seorang superstar!';
    default:
      return 'Lah kok ngebug';
  }
}
