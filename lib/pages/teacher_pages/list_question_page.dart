import 'package:flutter/material.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/index.dart';

import '../../helpers/index.dart';
import '../widgets/index.dart';

class ListQuestionPage extends StatefulWidget {
  const ListQuestionPage({
    super.key,
    required this.partName,
    required this.moduleName,
  });
  final String moduleName;
  final String partName;

  @override
  State<ListQuestionPage> createState() => _ListQuestionPageState();
}

class _ListQuestionPageState extends State<ListQuestionPage> {
  bool _isLoading = true;
  List<QuestionMdl> _questions = [];

  Future<void> _fetchAllQuestion() async {
    final questions = await FirebaseHelper.fetchQuestions(widget.partName);

    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  Future<void> _addQuestion() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuestionPage(
          moduleName: widget.moduleName,
          partName: widget.partName,
        ),
      ),
    );

    if (result ?? false) {
      _fetchAllQuestion();
    }
  }

  @override
  void initState() {
    _fetchAllQuestion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_questions.isEmpty) {
      return MyEmpty(
        title: 'Belum ada Pertanyaan yang ditambahkan.',
        onTapTitle: 'Tambah Soal',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddQuestionPage(
              moduleName: widget.moduleName,
              partName: widget.partName,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pertanyaan'),
        centerTitle: true,
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepPurple,
        ),
        child: IconButton(
          onPressed: () => _addQuestion(),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'assets/quiz.png',
                height: 320,
              ),
              const SizedBox(height: 40),
              Column(
                children: List.generate(
                  _questions.length,
                  (index) {
                    final question = _questions[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Image.network(
                          question.imageUrl,
                          fit: BoxFit.fill,
                          height: MediaQuery.of(context).size.width / 2,
                          errorBuilder: (_, __, ___) => Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                            alignment: Alignment.center,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              question.questionText,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        subtitle: Text(
                            'Modul: ${question.moduleName}\nMateri: ${question.partName}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.green,
                              onPressed: () async {
                                final bool? result =
                                    await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddQuestionPage(
                                      isEdit: true,
                                      questionToEdit: question,
                                      moduleName: widget.moduleName,
                                      partName: widget.partName,
                                    ),
                                  ),
                                );

                                if (result ?? false) {
                                  _fetchAllQuestion();
                                }
                              },
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () async {
                                  setState(() => _isLoading = true);
                                  await FirebaseHelper.deleteQuestion(
                                      question.id);
                                  await _fetchAllQuestion();
                                }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
