import 'package:flutter/material.dart';
import 'package:math_quiz/models/index.dart';

import '../../helpers/index.dart';
import '../widgets/index.dart';

class AddModulePage extends StatefulWidget {
  const AddModulePage({super.key});

  @override
  State<AddModulePage> createState() => _AddModulePageState();
}

class _AddModulePageState extends State<AddModulePage> {
  bool _isLoading = false;
  String? _moduleName;

  Future<void> _submitModule() async {
    //? Validasi Semua Harus Diisi
    if (_moduleName == null || _moduleName!.isEmpty) {
      MySnackbar.failed(context, message: 'Semua form harus diisi.');

      return;
    }

    try {
      //? Mengirim Data Ke Firebase
      setState(() => _isLoading = true);
      final module = ModuleMdl(
        moduleName: _moduleName ?? '',
      );

      await FirebaseHelper.addModule(module);

      if (mounted) {
        MySnackbar.success(context, message: 'Modul berhasil ditambahkan.');
      }
      setState(() => _isLoading = false);
    } catch (e) {
      //? Jika Terdapat Kegagalan
      if (mounted) {
        MySnackbar.failed(context, message: e.toString());
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Modul Baru'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              MyInputField(
                label: 'Nama Modul',
                onChanged: (text) {
                  setState(() {
                    _moduleName = text;
                  });
                },
              ),
              const SizedBox(height: 20),
              MySelectionButton(
                title: 'Tambah Modul',
                onTap: _submitModule,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
