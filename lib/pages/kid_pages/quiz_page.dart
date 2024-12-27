import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class QuizPage extends StatefulWidget {
  // TODO(Aliryo): shuffle answer index
  const QuizPage({super.key, required this.kidName, required this.partName});
  final String kidName;
  final String partName;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _isLoading = true;

  //? Parameter Untuk Kuis
  static const _maxQuestionsToShow = 10;
  List<QuestionMdl> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;

  //? Parameter Untuk Timer
  static const _totalTime = 2700;
  int _remainingTime = 2700;
  double _progressValue = 1.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    final questions =
        await FirebaseHelper.fetchAndShuffleQuestions(widget.partName);

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _questions = questions.take(_maxQuestionsToShow).toList();
      _isLoading = false;
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remainingTime--;
        _progressValue -= 1 / _totalTime;

        if (_progressValue <= 0) {
          _timer?.cancel();
          _progressValue = 0;
          _submitResult();
        }
      });
    });
  }

  void _addScore(String answer) {
    if (_questions[_currentQuestionIndex].correctAnswer == answer) {
      setState(() => _score += 10);
    }
  }

  Future<void> _handleAnswer(String answer) async {
    _addScore(answer);

    if (_currentQuestionIndex < _maxQuestionsToShow - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      await _submitResult();
    }
  }

  Future<void> _submitResult() async {
    setState(() => _isLoading = true);
    final scoreData = ScoreData(
      partName: widget.partName,
      score: _score,
    );

    final result = ResultMdl(
      name: widget.kidName,
      scoreData: [scoreData],
    );

    await FirebaseHelper.addResult(result);

    _navigateToScorePage();
    setState(() => _isLoading = false);
  }

  void _navigateToScorePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScorePage(
          kidName: widget.kidName,
          score: _score,
        ),
      ),
    );
  }

  //? Tampilan Halaman Kuis
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_questions.length < _maxQuestionsToShow) {
      return const MyEmpty(title: 'Belum ada pertanyaan.');
    }

    return _ViewQuiz(
      question: _questions[_currentQuestionIndex],
      onAnswerSelected: _handleAnswer,
      progressValue: _progressValue,
      remainingTime: _remainingTime,
      currentQuestionIndex: _currentQuestionIndex,
    );
  }
}

class _ViewQuiz extends StatelessWidget {
  const _ViewQuiz({
    required this.question,
    required this.onAnswerSelected,
    required this.progressValue,
    required this.remainingTime,
    required this.currentQuestionIndex,
  });

  final QuestionMdl question;
  final ValueChanged<String> onAnswerSelected;
  final double progressValue;
  final int remainingTime;
  final int currentQuestionIndex;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: false,
        onPopInvoked: (_) => MySnackbar.failed(
          context,
          message: 'Nilai kamu akan "0" jika kamu keluar.',
        ),
        child: Scaffold(
          body: Stack(
            children: [
              const _ViewBackground(),
              _ViewForeground(
                progressValue: progressValue,
                remainingTime: remainingTime,
                question: question,
                onAnswerSelected: onAnswerSelected,
                currentQuestionIndex: currentQuestionIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewBackground extends StatelessWidget {
  const _ViewBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple,
                Colors.deepPurpleAccent,
                Colors.purple,
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -300,
          left: -10,
          right: -10,
          child: Lottie.asset('lib/assets/bubble.json'),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Image.asset(
            'lib/assets/quiz.png',
            height: 180,
          ),
        ),
      ],
    );
  }
}

class _ViewForeground extends StatelessWidget {
  const _ViewForeground({
    required this.progressValue,
    required this.remainingTime,
    required this.question,
    required this.onAnswerSelected,
    required this.currentQuestionIndex,
  });

  final double progressValue;
  final int remainingTime;
  final QuestionMdl question;
  final ValueChanged<String> onAnswerSelected;
  final int currentQuestionIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            _WidgetLinearProgress(progressValue: progressValue),
            const SizedBox(height: 20),
            _WidgetTimer(
              remainingTime: remainingTime,
              currentQuestionIndex: currentQuestionIndex,
            ),
            const SizedBox(height: 40),
            _WidgetQuestion(question: question),
            const SizedBox(height: 40),
            _WidgetGridAnswer(
              options: question.options,
              onOptionSelected: onAnswerSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetLinearProgress extends StatelessWidget {
  const _WidgetLinearProgress({required this.progressValue});

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

class _WidgetTimer extends StatelessWidget {
  const _WidgetTimer({
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

class _WidgetQuestion extends StatelessWidget {
  const _WidgetQuestion({required this.question});

  final QuestionMdl question;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
    );
  }
}

class _WidgetGridAnswer extends StatelessWidget {
  const _WidgetGridAnswer({
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
          return _WidgetAnswer(
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

class _WidgetAnswer extends StatefulWidget {
  const _WidgetAnswer({
    required this.answer,
    required this.onTap,
    required this.label,
  });

  final String answer;
  final String label;

  final VoidCallback onTap;

  @override
  State<_WidgetAnswer> createState() => _WidgetAnswerState();
}

class _WidgetAnswerState extends State<_WidgetAnswer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.deepPurpleAccent[100]?.withOpacity(0.4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              '${widget.label}. ${widget.answer}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Futura',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
