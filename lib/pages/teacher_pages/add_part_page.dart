import 'package:flutter/material.dart';

import '../../helpers/index.dart';
import '../../models/index.dart';
import '../widgets/index.dart';

class AddPartPage extends StatefulWidget {
  const AddPartPage({
    super.key,
    required this.moduleName,
    this.partToEdit,
    this.isEdit = false,
  });
  final PartMdl? partToEdit;
  final bool isEdit;
  final String moduleName;

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  bool _isLoading = false;
  String? _partName;

  Future<void> _submitPart() async {
    //? Validasi Semua Harus Diisi
    if (_partName == null || _partName!.isEmpty) {
      MySnackbar.failed(context, message: 'Semua form harus diisi.');

      return;
    }

    try {
      //? Mengirim Data Ke Firebase
      setState(() => _isLoading = true);

      final part = PartMdl(
        moduleName: widget.moduleName,
        partName: _partName ?? '',
      );

      if (widget.isEdit) {
        await FirebaseHelper.editPart(widget.partToEdit!.id, part);

        if (mounted) {
          Navigator.of(context).pop(true);
          MySnackbar.success(context, message: 'Materi berhasil diubah.');
        }
      } else {
        await FirebaseHelper.addPart(part);

        if (mounted) {
          Navigator.of(context).pop(true);
          MySnackbar.success(context, message: 'Materi berhasil ditambahkan.');
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

  @override
  void initState() {
    if (widget.isEdit && widget.partToEdit != null) {
      _partName = widget.partToEdit!.partName;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
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
            ],
          ),
        ),
      ),
    );
  }
}
