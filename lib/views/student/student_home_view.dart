import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gridview_teste/models/lesson.dart';
import 'package:gridview_teste/viewmodels/auth_viewmodel.dart';
import 'package:gridview_teste/viewmodels/lesson_viewmodel.dart';
import 'package:gridview_teste/views/auth/login_view.dart';
import 'package:gridview_teste/views/student/lesson_player_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LessonViewModel>().loadLessons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curso de Violão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo_clavedesol.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black26,
              BlendMode.darken,
            ),
          ),
        ),
        child: Consumer<LessonViewModel>(
          builder: (context, lessonViewModel, child) {
            if (lessonViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (lessonViewModel.lessons.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhuma aula disponível no momento.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            // Agrupar aulas por nível
            final basicLessons = lessonViewModel.lessons
                .where((l) => l.level == 'básico')
                .toList();
            final intermediateLessons = lessonViewModel.lessons
                .where((l) => l.level == 'intermediário')
                .toList();
            final advancedLessons = lessonViewModel.lessons
                .where((l) => l.level == 'avançado')
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLevelSection(
                      'Nível Básico', basicLessons, Colors.green),
                  _buildLevelSection('Nível Intermediário', intermediateLessons,
                      Colors.orange),
                  _buildLevelSection(
                      'Nível Avançado', advancedLessons, Colors.red),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelSection(String title, List<Lesson> lessons, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonPlayerView(lesson: lesson),
                    ),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            lesson.thumbnailUrl ?? '',
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/thumbCurso.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Duração: ${lesson.duration}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
