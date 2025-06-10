import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:math_quiz/pages/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyByICWiNbld05U3q8MUxQO4gm_4vt7BAZo',
      appId: '1:496415477718:android:1149aa516e8f08fe6a9e77',
      messagingSenderId: '496415477718',
      projectId: 'math-quiz-7a9ba',
      storageBucket: 'math-quiz-7a9ba.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child ?? const SizedBox(),
          ),
        );
      },
      color: Colors.white,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
