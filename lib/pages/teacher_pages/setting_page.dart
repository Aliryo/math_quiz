import 'package:flutter/material.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/teacher_pages/add_part_page.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  var _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Kuis'),
        centerTitle: true,
      ),
      body: _isAuthenticated
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'lib/assets/setting.png',
                      height: 400,
                    ),
                    const SizedBox(height: 40),
                    MySelectionButton(
                      minWidth: double.infinity,
                      title: 'Tambah Modul',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddModulePage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MySelectionButton(
                      minWidth: double.infinity,
                      title: 'Tambah Materi',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPartPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MySelectionButton(
                      minWidth: double.infinity,
                      title: 'Tambah Pertanyaan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddQuestionPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MyInputField(
                  label: 'Masukan password',
                  onChanged: (text) {
                    setState(() {
                      if (text == 'admin123') _isAuthenticated = true;
                    });
                  },
                ),
              ),
            ),
    );
  }
}
