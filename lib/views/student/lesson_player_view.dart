import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:gridview_teste/models/lesson.dart';

class LessonPlayerView extends StatefulWidget {
  final Lesson lesson;

  const LessonPlayerView({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonPlayerView> createState() => _LessonPlayerViewState();
}

class _LessonPlayerViewState extends State<LessonPlayerView> {
  late YoutubePlayerController _controller;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _extractVideoId(widget.lesson.videoUrl),
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );
  }

  String _extractVideoId(String url) {
    if (url.contains('youtube.com/watch?v=')) {
      return url.split('watch?v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      return url.split('youtu.be/')[1].split('?')[0];
    }
    return '';
  }

  void _closePlayer() {
    debugPrint('Fechando o player...');
    try {
      _controller.close();
      debugPrint('Player fechado com sucesso');
    } catch (e) {
      debugPrint('Erro ao fechar o player: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('Dispose chamado');
    _closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _closePlayer();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _closePlayer();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            YoutubePlayer(
              controller: _controller,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
