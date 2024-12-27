import 'package:flutter/material.dart';
import 'package:math_quiz/models/index.dart';

import '../../helpers/index.dart';
import '../widgets/index.dart';

class ListStudentPage extends StatefulWidget {
  const ListStudentPage({super.key});

  @override
  State<ListStudentPage> createState() => _ListStudentPageState();
}

class _ListStudentPageState extends State<ListStudentPage> {
  bool _isLoading = true;
  List<StudentsMdl> _students = [];
  String _newKidnName = '';

  Future<void> _fetchStudents() async {
    final students = await FirebaseHelper.fetchStudents();

    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _fetchStudents();
    super.initState();
  }

  void showSnackBar() {}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_students.isEmpty) {
      return const MyEmpty(title: 'Belum ada siswa yang terdaftar.');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Siswa Terdaftar'),
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
                  _students.length,
                  (index) {
                    final student = _students[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(student.kidName),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MyInputField(
                                        onChanged: (text) {
                                          setState(() => _newKidnName = text);
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      MySelectionButton(
                                        title: 'Ubah Nama Siswa',
                                        onTap: () async {
                                          if (_newKidnName.isNotEmpty ||
                                              _newKidnName.length < 3) {
                                            setState(() => _isLoading = true);
                                            await FirebaseHelper.editStudent(
                                                student.id, _newKidnName);
                                            await _fetchStudents();
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          } else {
                                            Navigator.pop(context);
                                            MySnackbar.failed(
                                              context,
                                              message:
                                                  'Nama siswa tidak valid.',
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  ));
                            },
                          );
                        },
                        trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              await FirebaseHelper.deleteStudent(student.id);
                              await _fetchStudents();
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
