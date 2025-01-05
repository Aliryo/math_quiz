import 'package:flutter/material.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/index.dart';

import '../../helpers/index.dart';
import '../widgets/index.dart';

class ListQuestionPage extends StatefulWidget {
  const ListQuestionPage({super.key});

  @override
  State<ListQuestionPage> createState() => _ListQuestionPageState();
}

class _ListQuestionPageState extends State<ListQuestionPage> {
  bool _isLoading = true;
  List<QuestionMdl> _questions = [];

  Future<void> _fetchAllQuestion() async {
    final questions = await FirebaseHelper.fetchAllQuestions();

    setState(() {
      _questions = questions;
      _isLoading = false;
    });
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
      return const MyEmpty(
        title: 'Belum ada Pertanyaan yang ditambahkan.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pertanyaan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'lib/assets/quiz.png',
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
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddQuestionPage(
                              isEdit: true,
                              questionToEdit: question,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              await FirebaseHelper.deleteQuestion(question.id);
                              await _fetchAllQuestion();
                            }),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
