import 'dart:io';

import 'package:flutter/material.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

class AddLessonPage extends StatefulWidget {
  const AddLessonPage({super.key});

  @override
  State<AddLessonPage> createState() => _AddLessonPageState();
}

class _AddLessonPageState extends State<AddLessonPage> {
  List<ModuleMdl> _modules = [];
  List<PartMdl> _parts = [];

  String? _selectedModuleName;
  String? _selectedPartName;
  String? _videoUrl;
  String? _pdfUrl;

  File? _selectedFile;

  bool _isLoading = true;

  Future<void> _selectImage() async {
    final File? file = await CommonHelper.pickFile(allowedExtensions: ['pdf']);

    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _uploadPdf() async {
    //? Validasi Semua Harus Diisi
    if ((_selectedModuleName == null || _selectedPartName == null) ||
        (_videoUrl == null || _videoUrl!.isEmpty) && _selectedFile == null) {
      setState(() => _isLoading = false);

      MySnackbar.failed(context, message: 'Semua form harus diisi.');

      return;
    }

    try {
      //? Mengirim File Ke Firebase
      setState(() => _isLoading = true);

      final String? pdfUrl = await FirebaseHelper.uploadFile(_selectedFile!);

      if (pdfUrl != null) {
        setState(() => _pdfUrl = pdfUrl);

        await _submitLesson();
      } else {
        if (mounted) {
          if (mounted) {
            MySnackbar.failed(context, message: 'Gagal mengupload file.');
          }
        }
      }
    } catch (e) {
      //? Jika Terdapat Kegagalan
      if (mounted) {
        MySnackbar.failed(context, message: 'Failed to upload file: $e');
      }
    }
  }

  Future<void> _submitLesson() async {
    //? Validasi Semua Harus Diisi
    if ((_selectedModuleName == null || _selectedPartName == null) ||
        (_videoUrl == null || _videoUrl!.isEmpty) && _selectedFile == null) {
      setState(() => _isLoading = false);

      MySnackbar.failed(context, message: 'Semua form harus diisi.');

      return;
    }

    try {
      //? Mengirim Data Ke Firebase
      setState(() => _isLoading = true);

      final lesson = LessonMdl(
        partName: _selectedPartName ?? '',
        moduleName: _selectedModuleName ?? '',
        lessonPath:
            (_pdfUrl?.isNotEmpty ?? false) ? _pdfUrl ?? '' : _videoUrl ?? '',
      );

      await FirebaseHelper.addLesson(lesson);

      if (mounted) {
        MySnackbar.success(
          context,
          message: 'Pembelajaran berhasil ditambahkan.',
        );
      }
      setState(() {
        _selectedFile = null;
        _pdfUrl = null;
        _videoUrl = null;
        _isLoading = false;
      });
    } catch (e) {
      //? Jika Terdapat Kegagalan
      if (mounted) {
        MySnackbar.failed(context, message: e.toString());
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchModules() async {
    final modules = await FirebaseHelper.fetchModules();

    setState(() {
      _modules = modules;
      _isLoading = false;
    });
  }

  Future<void> _fetchParts(String moduleName) async {
    final parts = await FirebaseHelper.fetchParts(moduleName);

    setState(() {
      _parts = parts;
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
        title: const Text('Tambah Pembelajaran Baru'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedFile != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'File Materi :',
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _selectedFile = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFile?.path.split('/').last ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
            MyDropdown<String>(
              label: 'Pilih Modul',
              value: _selectedModuleName,
              items: _modules.map((ModuleMdl module) {
                return DropdownMenuItem<String>(
                  value: module.moduleName,
                  child: Text(module.moduleName),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedModuleName = newValue;
                  _parts = [];
                  _selectedPartName = null;
                  _isLoading = true;
                });

                _fetchParts(newValue ?? '');
              },
            ),
            if (_parts.isNotEmpty) ...[
              const SizedBox(height: 20),
              MyDropdown<String>(
                label: 'Pilih Materi',
                value: _selectedPartName,
                items: _parts.map((PartMdl parts) {
                  return DropdownMenuItem<String>(
                    value: parts.partName,
                    child: Text(parts.partName),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedPartName = newValue);
                },
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Upload Gambar Pertanyaan',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.upload),
                  ],
                ),
              ),
            ),
            if (_selectedFile == null) ...[
              const SizedBox(height: 20),
              MyInputField(
                label: 'Link Video Pembelajaran',
                onChanged: (text) {
                  setState(() => _videoUrl = text);
                },
              ),
            ],
            const SizedBox(height: 20),
            MySelectionButton(
              onTap: _selectedFile != null ? _uploadPdf : _submitLesson,
              title: 'Tambah Pembelajaran',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
