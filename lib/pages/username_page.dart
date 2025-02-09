import 'package:flutter/material.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

import '../helpers/index.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _controller = TextEditingController();
  bool _isError = false;

  Future<void> _saveUsername() async {
    if (_controller.text.length < 3) {
      setState(() => _isError = true);
      return;
    }

    setState(() => _isError = false);

    try {
      await Future.wait([
        LocalDataHelper.saveUsername(_controller.text),
        FirebaseHelper.addKidName(_controller.text),
      ]);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WelcomePage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        MySnackbar.failed(context,
            message: 'Gagal menyimpan, coba beberapa saat lagi');
      }
      setState(() => _isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 40),
            _WidgetTextField(
              label: 'Nama Lengkap',
              hintText: 'Masukkan Nama Lengkap Kamu',
              controller: _controller,
              isError: _isError,
            ),
            const SizedBox(height: 20),
            MySelectionButton(
              title: 'Simpan Nama',
              onTap: _saveUsername,
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
