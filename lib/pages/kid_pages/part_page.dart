import 'package:flutter/material.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/kid_pages/lesson_page.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class PartPage extends StatefulWidget {
  const PartPage({
    super.key,
    required this.kidName,
    required this.moduleName,
    this.isStartQuiz = true,
  });

  final String kidName;
  final String moduleName;
  final bool isStartQuiz;

  @override
  State<PartPage> createState() => _PartPageState();
}

class _PartPageState extends State<PartPage> {
  List<PartMdl> _parts = [];
  bool _isLoading = true;

  @override
  void initState() {
    _fetchParts();
    super.initState();
  }

  Future<void> _fetchParts() async {
    final parts = await FirebaseHelper.fetchParts(widget.moduleName);
    setState(() {
      _parts = parts;
      _isLoading = false;
    });
  }

  void _onPartSelected(String partName) {
    if (widget.isStartQuiz) {
      _showOptionDialog(partName);
    } else {
      _navigateToLessonPage(partName);
    }
  }

  void _showOptionDialog(String partName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _OptionDialog(
          onTapQuiz: () {
            Navigator.of(context).pop();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => QuizPage(
                  kidName: widget.kidName,
                  partName: partName,
                ),
              ),
              (_) => false,
            );
          },
          onTapResult: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultPage(partName: partName),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToLessonPage(String partName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPage(partName: partName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_parts.isEmpty) {
      return const MyEmpty(title: 'Belum ada materi yang ditambahkan.');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Materi Pembelajaran'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'lib/assets/math.png',
                height: 320,
              ),
              const SizedBox(height: 40),
              Column(
                children: _parts.map((part) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MySelectionButton(
                      minWidth: double.infinity,
                      title: part.partName,
                      onTap: () => _onPartSelected(part.partName),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionDialog extends StatelessWidget {
  const _OptionDialog({
    required this.onTapQuiz,
    required this.onTapResult,
  });
  final VoidCallback onTapQuiz;
  final VoidCallback onTapResult;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Apa yang ingin kamu lakukan saat ini?'),
      content: const Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ingat, jika kamu memulai kuis, kamu tidak bisa kembali!',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onTapResult,
          child: const Text(
            'Lihat Hasil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple,
            ),
          ),
        ),
        MySelectionButton(
          title: 'Mulai Kuis',
          onTap: onTapQuiz,
        ),
      ],
    );
  }
}
