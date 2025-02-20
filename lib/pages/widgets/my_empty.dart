import 'package:flutter/material.dart';

import '../index.dart';

import 'index.dart';

class MyEmpty extends StatelessWidget {
  const MyEmpty({
    super.key,
    required this.title,
    this.isBackFromQuizPage = false,
  });
  final String title;
  final bool isBackFromQuizPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/setting.png',
                  height: 400,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: MySelectionButton(
          title: 'Kembali',
          onTap: () => isBackFromQuizPage
              ? Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const WelcomePage(),
                  ),
                  (_) => false,
                )
              : Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
