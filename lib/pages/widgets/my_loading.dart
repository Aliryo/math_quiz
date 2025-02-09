import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyLoading extends StatelessWidget {
  const MyLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/loading.json',
        ),
      ),
    );
  }
}
