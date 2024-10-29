import 'package:flutter/material.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class PartPage extends StatefulWidget {
  const PartPage({super.key, required this.kidName, required this.moduleName});
  final String kidName;
  final String moduleName;

  @override
  State<PartPage> createState() => _PartPageState();
}

class _PartPageState extends State<PartPage> {
  List<PartMdl> _parts = [];
  bool _isLoading = true;

  Future<void> _fetchParts() async {
    final parts = await FirebaseHelper.fetchParts(widget.moduleName);

    setState(() {
      _parts = parts;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _fetchParts();
    super.initState();
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
                children: List.generate(
                  _parts.length,
                  (index) {
                    final partName = _parts[index].partName;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MySelectionButton(
                        minWidth: double.infinity,
                        title: partName,
                        onTap: () => showDialog(
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
                                    builder: (_) => ResultPage(
                                      partName: partName,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
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
