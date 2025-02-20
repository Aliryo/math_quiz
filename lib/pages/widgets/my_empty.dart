import 'package:flutter/material.dart';

import 'index.dart';

class MyEmpty extends StatelessWidget {
  const MyEmpty({super.key, required this.title, this.onTapTitle, this.onTap});
  final String title;
  final String? onTapTitle;
  final VoidCallback? onTap;

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
            title: onTapTitle ?? 'Kembali',
            onTap: onTap ?? () => Navigator.of(context).pop()),
      ),
    );
  }
}
