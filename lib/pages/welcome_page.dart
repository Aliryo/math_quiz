import 'package:flutter/material.dart';
import 'package:math_quiz/pages/index.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _controller = TextEditingController();
  bool _isError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingPage(),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              'lib/assets/menu.png',
              width: double.infinity,
              height: 400,
            ),
            const SizedBox(height: 40),
            _WidgetTextField(
              label: 'Nama Lengkap',
              hintText: 'Masukkan Nama Lengkap Kamu',
              controller: _controller,
              isError: _isError,
            ),
            const SizedBox(height: 20),
            _WidgetGameButton(
              onPressed: () => Future.delayed(const Duration(seconds: 1), () {
                setState(() => _isError = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModulePage(
                      kidName: _controller.text,
                      isStartQuiz: false,
                    ),
                  ),
                );
              }),
              label: 'Mulai Belajar',
            ),
            const SizedBox(height: 20),
            _WidgetGameButton(
              onPressed: () => _controller.text.length > 3
                  ? Future.delayed(const Duration(seconds: 1), () {
                      setState(() => _isError = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ModulePage(
                            kidName: _controller.text,
                          ),
                        ),
                      );
                    })
                  : setState(() => _isError = true),
              label: 'Mulai Kuis',
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool isError;

  const _WidgetTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.isError,
  });

  @override
  State<_WidgetTextField> createState() => _WidgetTextFieldState();
}

class _WidgetTextFieldState extends State<_WidgetTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(
          CurveTween(curve: Curves.elasticIn),
        )
        .animate(_controller);
  }

  void _validateInput() {
    setState(() => _isValid = widget.controller.text.length > 3);
    if (!_isValid) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_isValid ? 0 : _shakeAnimation.value, 0),
              child: TextField(
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
                controller: widget.controller,
                onChanged: (value) => _validateInput(),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.deepPurple[100],
                    fontStyle: FontStyle.italic,
                  ),
                  filled: true,
                  fillColor: Colors.pink[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  suffixIcon: widget.controller.text.isNotEmpty
                      ? Icon(
                          _isValid ? Icons.check_circle : Icons.error,
                          color: _isValid ? Colors.green : Colors.red,
                        )
                      : null,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        if (!_isValid || widget.isError)
          const Text(
            'Oops! Kamu harus isi nama dulu.',
            style: TextStyle(color: Colors.redAccent),
          ),
      ],
    );
  }
}

class _WidgetGameButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _WidgetGameButton({required this.label, required this.onPressed});

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
            const Icon(Icons.play_arrow, size: 28, color: Colors.white),
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
