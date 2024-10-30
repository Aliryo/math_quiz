import 'package:flutter/material.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class ModulePage extends StatefulWidget {
  const ModulePage({
    super.key,
    required this.kidName,
    this.isStartQuiz = true,
  });
  final String kidName;
  final bool isStartQuiz;

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  List<ModuleMdl> _modules = [];
  bool _isLoading = true;

  Future<void> _fetchModules() async {
    final modules = await FirebaseHelper.fetchModules();

    setState(() {
      _modules = modules;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _fetchModules();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_modules.isEmpty) {
      return const MyEmpty(title: 'Belum ada modul yang ditambahkan.');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Modul Pembelajaran'),
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
                  _modules.length,
                  (index) {
                    final moduleName = _modules[index].moduleName;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MySelectionButton(
                        minWidth: double.infinity,
                        title: moduleName,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PartPage(
                              kidName: widget.kidName,
                              moduleName: moduleName,
                              isStartQuiz: widget.isStartQuiz,
                            ),
                          ),
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
