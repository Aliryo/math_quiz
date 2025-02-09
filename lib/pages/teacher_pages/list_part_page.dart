import 'package:flutter/material.dart';
import 'package:math_quiz/models/index.dart';

import '../../helpers/index.dart';
import '../index.dart';
import '../widgets/index.dart';

class ListPartPage extends StatefulWidget {
  const ListPartPage({super.key, required this.moduleName});

  final String moduleName;

  @override
  State<ListPartPage> createState() => _ListPartPageState();
}

class _ListPartPageState extends State<ListPartPage> {
  bool _isLoading = true;
  List<PartMdl> _parts = [];

  Future<void> _fetchParts() async {
    final parts = await FirebaseHelper.fetchParts(widget.moduleName);

    setState(() {
      _parts = parts;
      _isLoading = false;
    });
  }

  Future<void> _addPart() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPartPage(
          moduleName: widget.moduleName,
        ),
      ),
    );

    if (result ?? false) {
      _fetchParts();
    }
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
      return MyEmpty(
        title: 'Belum ada Materi yang ditambahkan.',
        onTapTitle: 'Tambah Materi',
        onTap: () => _addPart(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Materi "${widget.moduleName}"'),
        centerTitle: true,
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepPurple,
        ),
        child: IconButton(
          onPressed: () => _addPart(),
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListQuestionPage(
                              moduleName: widget.moduleName,
                              partName: part.partName,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(left: 12),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu_book),
                              color: Colors.deepPurple,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddLessonPage(
                                    moduleName: widget.moduleName,
                                    partName: part.partName,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.green,
                              onPressed: () async {
                                final bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddPartPage(
                                      isEdit: true,
                                      partToEdit: part,
                                      moduleName: widget.moduleName,
                                    ),
                                  ),
                                );

                                if (result ?? false) {
                                  _fetchParts();
                                }
                              },
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () async {
                                  setState(() => _isLoading = true);
                                  await FirebaseHelper.deletePart(part.id);
                                  await _fetchParts();
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
