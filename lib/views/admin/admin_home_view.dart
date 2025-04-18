import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gridview_teste/models/lesson.dart';
import '../../viewmodels/lesson_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login_view.dart';
import 'students_view.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonViewModel>().loadLessons();
    });
  }

  Future<void> _addLesson() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final videoUrlController = TextEditingController();
    final durationController = TextEditingController();
    String selectedLevel = 'básico'; // Valor padrão

    await showDialog<Lesson>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Aula'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(labelText: 'URL do Vídeo'),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duração'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Nível',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'básico',
                    child: Text('Básico'),
                  ),
                  DropdownMenuItem(
                    value: 'intermediário',
                    child: Text('Intermediário'),
                  ),
                  DropdownMenuItem(
                    value: 'avançado',
                    child: Text('Avançado'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedLevel = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  videoUrlController.text.isEmpty ||
                  durationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Preencha todos os campos obrigatórios')));
                return;
              }

              final lesson = Lesson(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descriptionController.text,
                videoUrl: videoUrlController.text,
                duration: durationController.text,
                order: context.read<LessonViewModel>().lessons.length,
                level: selectedLevel,
              );

              context.read<LessonViewModel>().addLesson(lesson);
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editLesson(Lesson lesson) async {
    final titleController = TextEditingController(text: lesson.title);
    final descriptionController =
        TextEditingController(text: lesson.description);
    final videoUrlController = TextEditingController(text: lesson.videoUrl);
    final durationController = TextEditingController(text: lesson.duration);
    String selectedLevel = lesson.level; // Usar o nível atual

    await showDialog<Lesson>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Aula'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(labelText: 'URL do Vídeo'),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duração'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Nível',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'básico',
                    child: Text('Básico'),
                  ),
                  DropdownMenuItem(
                    value: 'intermediário',
                    child: Text('Intermediário'),
                  ),
                  DropdownMenuItem(
                    value: 'avançado',
                    child: Text('Avançado'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedLevel = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  videoUrlController.text.isEmpty ||
                  durationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Preencha todos os campos obrigatórios')));
                return;
              }

              final updatedLesson = Lesson(
                id: lesson.id,
                title: titleController.text,
                description: descriptionController.text,
                videoUrl: videoUrlController.text,
                duration: durationController.text,
                order: lesson.order,
                level: selectedLevel,
              );

              context.read<LessonViewModel>().updateLesson(updatedLesson);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content:
            Text('Tem certeza que deseja excluir a aula "${lesson.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<LessonViewModel>().deleteLesson(lesson.id);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Aulas'),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Painel Administrativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Gerenciar Aulas'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Alunos Inscritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentsView()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
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
      ),
      body: Consumer<LessonViewModel>(
        builder: (context, lessonViewModel, child) {
          if (lessonViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lessonViewModel.lessons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nenhuma aula cadastrada',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addLesson,
                    child: const Text('Adicionar Aula'),
                  ),
                ],
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
                _buildLevelSection('Nível Básico', basicLessons, Colors.green),
                _buildLevelSection(
                    'Nível Intermediário', intermediateLessons, Colors.orange),
                _buildLevelSection(
                    'Nível Avançado', advancedLessons, Colors.red),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLesson,
        child: const Icon(Icons.add),
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
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.network(
                      lesson.thumbnailUrl ??
                          'https://img.youtube.com/vi/${_getVideoId(lesson.videoUrl)}/maxresdefault.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/thumbCurso.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.duration,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getLevelColor(lesson.level),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lesson.level,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editLesson(lesson),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteLesson(lesson),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _getVideoId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    }
    return '';
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'básico':
        return Colors.green;
      case 'intermediário':
        return Colors.orange;
      case 'avançado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
