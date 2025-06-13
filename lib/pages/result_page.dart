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
    setState(() {
      _isLoading = true;
      _results = [];
    });

    final results = await FirebaseHelper.fetchResults(widget.partName);

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  Future<void> _filterResults() async {
    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    );

    if (pickedDateRange != null) {
      final start = pickedDateRange.start;
      final end = pickedDateRange.end.add(const Duration(days: 1));

      setState(() {
        _isLoading = true;
        _results = [];
      });

      final results = await FirebaseHelper.fetchResults(
        widget.partName,
        startDate: start,
        endDate: end,
      );

      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_results.isEmpty) {
      return MyEmpty(
        title: 'Belum ada hasil kuis dari siswa pada periode ini.',
        child: MySelectionButton(
          title: 'Refresh',
          onTap: () => _fetchResults(),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/background.jpg',
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: _filterResults,
                        icon: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            size: 28,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _fetchResults(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/trophy.png',
                              height: 360,
                            ),
                            Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                                child: Column(
                                  children: _results.map((result) {
                                    final score = result.scoreData
                                        .firstWhere(
                                            (score) =>
                                                score.partName ==
                                                widget.partName,
                                            orElse: () => ScoreData(score: 0))
                                        .score;

                                    final isWinner = score >= 80;

                                    return _ResultItem(
                                      name: result.name,
                                      isWinner: isWinner,
                                      createdAt: CommonHelper.formatDateTime(
                                          result.createdAt),
                                      score: score,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  const _ResultItem({
    required this.name,
    this.createdAt,
    required this.isWinner,
    required this.score,
  });

  final String name;
  final String? createdAt;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (createdAt != null)
                  Text(
                    createdAt!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
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
