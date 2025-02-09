import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.kidName, required this.partName});
  final String kidName;
  final String partName;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
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
    _audioPlayer.dispose();
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
      _playSound();
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

  Future<void> _playSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('quiz_audio.mp3'));
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
      return const MyEmpty(
        title: 'Belum ada pertanyaan.',
        isBackFromQuizPage: true,
      );
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
          child: Lottie.asset('assets/bubble.json'),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/quiz.png',
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
            WidgetLinearProgress(progressValue: progressValue),
            const SizedBox(height: 20),
            WidgetTimer(
              remainingTime: remainingTime,
              currentQuestionIndex: currentQuestionIndex,
            ),
            const SizedBox(height: 40),
            WidgetQuestion(question: question),
            const SizedBox(height: 40),
            WidgetGridAnswer(
              options: question.options,
              onOptionSelected: onAnswerSelected,
            ),
          ],
        ),
      ),
    );
  }
}
