import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.partName});
  final String partName;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isLoading = true;
  List<ResultMdl> _results = [];

  @override
  void initState() {
    _fetchResults();
    super.initState();
  }

  Future<void> _fetchResults() async {
    final results = await FirebaseHelper.fetchResults(widget.partName);

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_results.isEmpty) {
      return const MyEmpty(
        title: 'Belum ada siswa yang mengerjakan materi kuis.',
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'lib/assets/background.jpg',
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Image.asset(
                    'lib/assets/trophy.png',
                    height: 360,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.deepPurpleAccent),
                          ),
                          child: Column(
                            children: _results.map((result) {
                              final score = result.scoreData
                                  .firstWhere(
                                      (score) =>
                                          score.partName == widget.partName,
                                      orElse: () => ScoreData(score: 0))
                                  .score;

                              final isWinner = score >= 80;

                              return _ResultItem(
                                name: result.name,
                                isWinner: isWinner,
                                score: score,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  const _ResultItem({
    required this.name,
    required this.isWinner,
    required this.score,
  });

  final String name;
  final bool isWinner;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:
            isWinner ? Colors.deepPurpleAccent : Colors.deepPurpleAccent[100],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            score.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          if (isWinner) const Icon(Icons.star, color: Colors.amber),
        ],
      ),
    );
  }
}
