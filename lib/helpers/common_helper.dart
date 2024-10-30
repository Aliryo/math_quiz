import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CommonHelper {
  const CommonHelper();

  //? Knuth Shuffle Menggunakan Bahasa Dart
  static void knuthShuffle(List list) {
    final Random random = Random();
    for (int i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  //? Mengubah Timer Detik Menjadi Format 00:00
  static String formatTimer(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  //? Memilih Gambar Dari File Handphone
  static Future<File?> pickFile({
    required List<String>? allowedExtensions,
  }) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  //? Download PDF Pembelajaran
  static Future<String> downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/temp_pdf.pdf');

    await file.writeAsBytes(bytes);

    return file.path;
  }
}
