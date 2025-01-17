import 'dart:io';

import 'package:flutter/material.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';

import '../index.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({
    super.key,
    this.questionToEdit,
    this.isEdit = false,
  });
  final QuestionMdl? questionToEdit;
  final bool isEdit;

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  List<String> _options = ['', '', '', ''];
  List<ModuleMdl> _modules = [];
  List<PartMdl> _parts = [];

  String? _selectedModuleName;
  String? _selectedPartName;
  String? _questionText;
  String? _correctAnswer;
  String? _imageUrl;

  File? _selectedFile;

  bool _isLoading = true;

  Future<void> _selectImage() async {
    final File? file = await CommonHelper.pickFile(
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (file != null) {
      setState(() => _selectedFile = file);
      setState(() => _imageUrl = null);
    }
  }

  Future<void> _uploadImage() async {
    //? Validasi Semua Harus Diisi
    if ((_selectedModuleName == null || _selectedPartName == null) ||
        (_questionText == null || _questionText!.isEmpty) &&
            (_selectedFile == null && _imageUrl!.isEmpty) ||
        _correctAnswer == null ||
        !_options.every((option) => option.isNotEmpty)) {
      setState(() => _isLoading = false);

      MySnackbar.failed(context, message: 'Semua form harus diisi.');

      return;
    }

    try {
      //? Mengirim Gambar Ke Firebase
      setState(() => _isLoading = true);

      final String? imageUrl = await FirebaseHelper.uploadFile(_selectedFile!);

      if (imageUrl != null) {
        setState(() => _imageUrl = imageUrl);

        await _submitQuestion();
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

  Future<void> _submitQuestion() async {
    //? Validasi Semua Harus Diisi
    if ((_selectedModuleName == null || _selectedPartName == null) ||
        (_questionText == null || _questionText!.isEmpty) &&
            (_selectedFile == null && _imageUrl!.isEmpty) ||
        _correctAnswer == null ||
        !_options.every((option) => option.isNotEmpty)) {
      setState(() => _isLoading = false);

      MySnackbar.failed(context, message: 'Semua form harus diisi.');

      return;
    }

    try {
      //? Mengirim Data Ke Firebase
      setState(() => _isLoading = true);

      final question = QuestionMdl(
        imageUrl: _imageUrl ?? '',
        questionText: _questionText ?? '',
        correctAnswer: _correctAnswer ?? '',
        partName: _selectedPartName ?? '',
        moduleName: _selectedModuleName ?? '',
        options: _options,
      );

      if (widget.isEdit) {
        await FirebaseHelper.editQuestion(widget.questionToEdit!.id, question);
      } else {
        await FirebaseHelper.addQuestion(question);
      }

      if (mounted) {
        MySnackbar.success(
          context,
          message: 'Pertanyaan berhasil ditambahkan.',
        );
      }
      setState(() {
        _selectedFile = null;
        _imageUrl = null;
        _questionText = null;
        _correctAnswer = null;
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
    if (widget.isEdit && widget.questionToEdit != null) {
      _correctAnswer = widget.questionToEdit!.correctAnswer;
      _imageUrl = widget.questionToEdit!.imageUrl;
      _questionText = widget.questionToEdit!.questionText;
      _options = widget.questionToEdit!.options;
      _selectedModuleName = widget.questionToEdit!.moduleName;
      _selectedPartName = widget.questionToEdit!.partName;

      _fetchParts(widget.questionToEdit!.moduleName);
    }

    _fetchModules();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const answerLabels = ['A', 'B', 'C', 'D'];

    if (_isLoading) {
      return const MyLoading();
    }

    if (_modules.isEmpty) {
      return const MyEmpty(title: 'Belum ada modul yang ditambahkan.');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Pertanyaan' : 'Tambah Pertanyaan Baru',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if ((_selectedFile != null || _imageUrl != null) &&
                (widget.questionToEdit?.questionText.isEmpty ?? false)) ...[
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
                          'Gambar Soal :',
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _selectedFile = null;
                            _imageUrl = null;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    (_imageUrl?.isNotEmpty ?? false)
                        ? Image.network(
                            _imageUrl!,
                            height: 200,
                          )
                        : Image.file(_selectedFile!, height: 200),
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
            const SizedBox(height: 20),
            MyDropdown<String>(
              label: 'Pilih Materi',
              value: _selectedPartName,
              items: _parts.isEmpty
                  ? [
                      const DropdownMenuItem(
                        child: Text('Pilih Modul Dulu'),
                      )
                    ]
                  : _parts.map((PartMdl parts) {
                      return DropdownMenuItem<String>(
                        value: parts.partName,
                        child: Text(parts.partName),
                      );
                    }).toList(),
              onChanged: (String? newValue) {
                setState(() => _selectedPartName = newValue);
              },
            ),
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
                label: 'Teks Pertanyaan',
                initialValue: _questionText,
                onChanged: (text) {
                  setState(() => _questionText = text);
                },
              ),
            ],
            for (int i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: MyInputField(
                  initialValue: _options[i],
                  label: 'Opsi ${answerLabels[i]}',
                  onChanged: (text) {
                    setState(() => _options[i] = text);
                  },
                ),
              ),
            const SizedBox(height: 20),
            MyDropdown<String>(
              label: 'Jawaban Benar',
              value: _correctAnswer,
              items: answerLabels.map((String answer) {
                return DropdownMenuItem<String>(
                  value: answer,
                  child: Text(answer),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() => _correctAnswer = newValue);
              },
            ),
            const SizedBox(height: 20),
            MySelectionButton(
              onTap: _selectedFile != null ? _uploadImage : _submitQuestion,
              title: widget.isEdit ? 'Ubah Pertanyaan' : 'Tambah Pertanyaan',
            ),
            const SizedBox(height: 20),
            MySelectionButton(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ListQuestionPage(),
                ),
              ),
              title: 'Daftar Pertanyaan',
            ),
          ],
        ),
      ),
    );
  }
}
