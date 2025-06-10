import 'package:flutter/material.dart';
import 'package:math_quiz/models/student_mdl.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

import '../helpers/index.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;

  Future<void> _loginUsername() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      MySnackbar.failed(context, message: 'Data harus diisi semua');
      return;
    }

    try {
      await Future.wait([
        FirebaseHelper.loginStudent(
          email: _emailController.text,
          password: _passwordController.text,
        ).then(
          (result) => LocalDataHelper.saveUsername(result.kidName),
        ),
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
            message: 'Gagal masuk, periksa email dan password');
      }
    }
  }

  Future<void> _saveUsername() async {
    if (_usernameController.text.length < 3 ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      MySnackbar.failed(context, message: 'Data harus diisi semua');
      return;
    }

    try {
      await Future.wait([
        FirebaseHelper.createStudent(StudentMdl(
          kidName: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        )).then(
          (_) => LocalDataHelper.saveUsername(_usernameController.text),
        ),
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
            message: 'Gagal menyimpan, siswa sudah terdaftar');
      }
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
            if (_isRegister)
              _WidgetTextField(
                label: 'Nama Lengkap',
                hintText: 'Masukkan Nama Lengkap Kamu',
                controller: _usernameController,
              ),
            _WidgetTextField(
              label: 'Email',
              hintText: 'Masukkan Email Kamu',
              controller: _emailController,
            ),
            _WidgetTextField(
              label: 'Password',
              hintText: 'Masukkan Password Kamu',
              controller: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            MySelectionButton(
              title: _isRegister ? 'Daftar' : 'Masuk',
              onTap: _isRegister ? _saveUsername : _loginUsername,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegister = !_isRegister;
                  _usernameController.clear();
                  _emailController.clear();
                  _passwordController.clear();
                });
              },
              child: Text(_isRegister
                  ? 'Sudah Punya Akun? Masuk'
                  : 'Belum Punya Akun? Daftar'),
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
  final bool isPassword;

  const _WidgetTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
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
                obscureText: widget.isPassword,
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
        const SizedBox(height: 8),
      ],
    );
  }
}
