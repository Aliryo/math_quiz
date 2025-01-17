import 'package:flutter/material.dart';

import '../../helpers/index.dart';
import '../../models/index.dart';
import '../index.dart';
import '../widgets/index.dart';

class AddPartPage extends StatefulWidget {
  const AddPartPage({
    super.key,
    this.partToEdit,
    this.isEdit = false,
  });
  final PartMdl? partToEdit;
  final bool isEdit;

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  List<ModuleMdl> _modules = [];

  bool _isLoading = true;

  String? _selectedModuleName;
  String? _partName;

  Future<void> _submitPart() async {
    //? Validasi Semua Harus Diisi
    if (_selectedModuleName == null ||
        _partName == null ||
        _partName!.isEmpty) {
      MySnackbar.failed(context, message: 'Semua form harus diisi.');

      return;
    }

    try {
      //? Mengirim Data Ke Firebase
      setState(() => _isLoading = true);

      final part = PartMdl(
        moduleName: _selectedModuleName ?? '',
        partName: _partName ?? '',
      );

      if (widget.isEdit) {
        await FirebaseHelper.editPart(widget.partToEdit!.id, part);
        if (mounted) {
          MySnackbar.success(context, message: 'Materi berhasil diubah.');
        }
      } else {
        await FirebaseHelper.addPart(part);

        if (mounted) {
          Navigator.of(context).pop();
          MySnackbar.success(context,
              message: widget.isEdit
                  ? 'Materi berhasil diubah'
                  : 'Materi berhasil ditambahkan.');
        }
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

  Future<void> _fetchModules() async {
    final modules = await FirebaseHelper.fetchModules();

    setState(() {
      _modules = modules;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.isEdit && widget.partToEdit != null) {
      _selectedModuleName = widget.partToEdit!.moduleName;
      _partName = widget.partToEdit!.partName;
    }

    _fetchModules();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_modules.isEmpty) {
      return const MyEmpty(title: 'Belum modul yang ditambahkan.');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Materi' : 'Tambah Materi Baru'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                  });
                },
              ),
              const SizedBox(height: 20),
              MyInputField(
                label: 'Nama Materi',
                initialValue: _partName,
                onChanged: (text) {
                  setState(() => _partName = text);
                },
              ),
              const SizedBox(height: 20),
              MySelectionButton(
                onTap: _submitPart,
                title: widget.isEdit ? 'Ubah Materi' : 'Tambah Materi',
              ),
              const SizedBox(height: 20),
              MySelectionButton(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListPartPage(),
                  ),
                ),
                title: 'Daftar Materi',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
