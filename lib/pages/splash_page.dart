import 'package:flutter/material.dart';
import 'package:math_quiz/pages/index.dart';

import '../helpers/index.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasUsername = false;

  Future<void> _checkUsername() async {
    final hasUsername = await LocalDataHelper.checkUsername();
    setState(() => _hasUsername = hasUsername);
  }

  @override
  void initState() {
    Future.microtask(() async {
      await _checkUsername();
      Future.delayed(
        const Duration(seconds: 2),
        () {
          if (_hasUsername) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const WelcomePage(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const UsernamePage(),
              ),
            );
          }
        },
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
