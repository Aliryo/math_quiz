import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:math_quiz/helpers/index.dart';
import 'package:math_quiz/models/index.dart';
import 'package:math_quiz/pages/widgets/index.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key, required this.partName});
  final String partName;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  LessonMdl _lesson = const LessonMdl();
  bool _isLoading = true;
  String _pdfFilePath = '';
  late YoutubePlayerController _youtubeController;

  Future<void> _fetchLesson() async {
    final lesson = await FirebaseHelper.fetchLesson(widget.partName);

    setState(() => _lesson = lesson);

    if (_lesson.lessonPath.contains('pdf')) {
      final pdfFilePath = await CommonHelper.temporaryPdf(_lesson.lessonPath);

      setState(() => _pdfFilePath = pdfFilePath);
    } else if (_lesson.lessonPath.isNotEmpty) {
      final initialVideoId = YoutubePlayer.convertUrlToId(_lesson.lessonPath)!;

      _youtubeController = YoutubePlayerController(
        initialVideoId: initialVideoId,
        flags: const YoutubePlayerFlags(autoPlay: false),
      )..addListener(() {
          if (_youtubeController.value.isFullScreen) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          } else {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          }
        });
    }

    setState(() => _isLoading = false);
  }

  @override
  void deactivate() {
    if (!_lesson.lessonPath.contains('pdf')) {
      _youtubeController.pause();
    }
    super.deactivate();
  }

  @override
  void initState() {
    _fetchLesson();
    super.initState();
  }

  @override
  void dispose() {
    if (!_lesson.lessonPath.contains('pdf')) {
      _youtubeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoading();
    }

    if (_lesson.lessonPath.isEmpty) {
      return const MyEmpty(title: 'Belum ada pembelajaran.');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pembelajaran ${widget.partName}'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: (_pdfFilePath.isNotEmpty || _pdfFilePath != '')
          ? PDFView(filePath: _pdfFilePath)
          : YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.deepPurple,
              ),
              builder: (context, player) {
                return Center(child: player);
              },
            ),
    );
  }
}
