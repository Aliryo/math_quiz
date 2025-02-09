import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isLoading = true;
  String _kidNameLocal = '';

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getUsername();
    super.initState();
  }

  Future<void> _getUsername() async {
    final kidName = await LocalDataHelper.getUsername();

    setState(() {
      _kidNameLocal = kidName;
      _isLoading = false;
    });
  }

  void _navigateToModulePage(String kidName, {bool isStartQuiz = false}) async {
    await _audioPlayer.play(AssetSource('play_click.mp3'));
    Future.delayed(
      const Duration(seconds: 1),
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModulePage(
              kidName: kidName,
              isStartQuiz: isStartQuiz,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              'assets/menu.png',
              width: double.infinity,
              height: 400,
            ),
            Text(
              'Halo, $_kidNameLocal',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            _WidgetGameButton(
              icon: Icons.menu_book,
              onPressed: () => _navigateToModulePage(_kidNameLocal),
              label: 'Mulai Belajar',
            ),
            const SizedBox(height: 20),
            _WidgetGameButton(
              onPressed: () =>
                  _navigateToModulePage(_kidNameLocal, isStartQuiz: true),
              label: 'Mulai Kuis',
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetGameButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const _WidgetGameButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  State<_WidgetGameButton> createState() => _WidgetGameButtonState();
}

class _WidgetGameButtonState extends State<_WidgetGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _animateButton() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: MaterialButton(
        onPressed: _animateButton,
        color: Colors.deepPurpleAccent,
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 30.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon ?? Icons.play_arrow,
              size: 28,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
