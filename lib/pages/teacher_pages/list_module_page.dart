import 'package:flutter/material.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/index.dart';

import '../../helpers/index.dart';
import '../widgets/index.dart';

class ListModulePage extends StatefulWidget {
  const ListModulePage({super.key});

  @override
  State<ListModulePage> createState() => _ListModulePageState();
}

class _ListModulePageState extends State<ListModulePage> {
  bool _isLoading = true;
  List<ModuleMdl> _modules = [];
  String _newModuleName = '';

  Future<void> _fetchModules() async {
    final modules = await FirebaseHelper.fetchModules();

    setState(() {
      _modules = modules;
      _isLoading = false;
    });
  }

  void _addModule() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddModulePage()),
    );

    if (result ?? false) {
      _fetchModules();
    }
  }

  void _editModule(ModuleMdl module) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyInputField(
                  label: 'Masukkan Nama Baru',
                  onChanged: (text) {
                    setState(() => _newModuleName = text);
                  },
                ),
                const SizedBox(height: 12),
                MySelectionButton(
                  title: 'Ubah Nama Modul',
                  onTap: () async {
                    if (_newModuleName.isNotEmpty) {
                      setState(() => _isLoading = true);
                      await FirebaseHelper.editModule(
                          module.id, _newModuleName);
                      await _fetchModules();
                      if (context.mounted) {
                        Navigator.pop(context);
                        MySnackbar.success(context,
                            message: 'Modul berhasil diubah.');
                      }
                    } else {
                      Navigator.pop(context);
                      MySnackbar.failed(context,
                          message: 'Nama modul tidak valid.');
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
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
      return MyEmpty(
        title: 'Belum ada modul yang ditambahkan.',
        onTapTitle: 'Tambah Modul',
        onTap: () => _addModule(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Modul'),
        centerTitle: true,
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepPurple,
        ),
        child: IconButton(
          onPressed: () => _addModule(),
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
                  _modules.length,
                  (index) {
                    final module = _modules[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(module.moduleName),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListPartPage(
                              moduleName: module.moduleName,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(left: 12),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.green,
                              onPressed: () => _editModule(module),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () async {
                                setState(() => _isLoading = true);
                                await FirebaseHelper.deleteModule(module.id);
                                await _fetchModules();
                              },
                            ),
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
