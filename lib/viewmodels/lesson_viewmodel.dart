import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gridview_teste/models/lesson.dart';

class LessonViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Lesson> _lessons = [];
  bool _isLoading = false;

  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;

  Future<void> loadLessons() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore.collection('lessons').orderBy('order').get();

      _lessons = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['level'] = data['level'] ?? 'básico'; // Valor padrão para level
        return Lesson.fromMap(data);
      }).toList();

      for (var lesson in _lessons) {
        debugPrint('Aula carregada: ${lesson.title}');
        debugPrint('URL do vídeo: ${lesson.videoUrl}');
        debugPrint('URL da thumbnail: ${lesson.thumbnailUrl}');
      }
    } catch (e) {
      debugPrint('Erro ao carregar aulas: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLesson(Lesson lesson) async {
    try {
      debugPrint('Adicionando aula: ${lesson.title}');
      debugPrint('URL do vídeo: ${lesson.videoUrl}');
      debugPrint('URL da thumbnail: ${lesson.thumbnailUrl}');

      await _firestore.collection('lessons').add(lesson.toMap());
      await loadLessons();
    } catch (e) {
      debugPrint('Erro ao adicionar aula: $e');
    }
  }

  Future<void> updateLesson(Lesson lesson) async {
    try {
      debugPrint('Atualizando aula: ${lesson.title}');
      debugPrint('URL do vídeo: ${lesson.videoUrl}');
      debugPrint('URL da thumbnail: ${lesson.thumbnailUrl}');

      await _firestore
          .collection('lessons')
          .doc(lesson.id)
          .update(lesson.toMap());
      await loadLessons();
    } catch (e) {
      debugPrint('Erro ao atualizar aula: $e');
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).delete();
      await loadLessons();
    } catch (e) {
      debugPrint('Erro ao deletar aula: $e');
    }
  }
}
