import 'package:flutter/material.dart';
import 'package:math_quiz/models/index.dart';

import '../../helpers/index.dart';
import '../index.dart';
import '../widgets/index.dart';

class ListPartPage extends StatefulWidget {
  const ListPartPage({super.key});

  @override
  State<ListPartPage> createState() => _ListPartPageState();
}

class _ListPartPageState extends State<ListPartPage> {
  bool _isLoading = true;
  List<PartMdl> _parts = [];

  Future<void> _fetchAllParts() async {
    final parts = await FirebaseHelper.fetchAllParts();

    setState(() {
      _parts = parts;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _fetchAllParts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_parts.isEmpty) {
      return const MyEmpty(
        title: 'Belum ada Materi yang ditambahkan.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Materi'),
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
                  _parts.length,
                  (index) {
                    final part = _parts[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(part.partName),
                        subtitle: Text(part.moduleName),
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddPartPage(
                              isEdit: true,
                              partToEdit: part,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              await FirebaseHelper.deletePart(part.id);
                              await _fetchAllParts();
                            }),
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
