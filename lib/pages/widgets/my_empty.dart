import 'package:flutter/material.dart';

import '../index.dart';

import 'index.dart';

class MyEmpty extends StatelessWidget {
  const MyEmpty({
    super.key,
    required this.title,
    this.isBackFromScorePage = false,
  });
  final String title;
  final bool isBackFromScorePage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/setting.png',
              height: 400,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: MySelectionButton(
          title: 'Kembali',
          onTap: () => isBackFromScorePage
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
