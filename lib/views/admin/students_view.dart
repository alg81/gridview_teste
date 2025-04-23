import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Buscar todos os usuários do Firestore
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        _students = querySnapshot.docs.map((doc) {
          final userData = doc.data() as Map<String, dynamic>;
          final enrollmentDate = userData['enrollmentDate'] as Timestamp?;

          // Se não houver data de inscrição, atualizar o documento com a data atual
          if (enrollmentDate == null) {
            final now = Timestamp.now();
            // Atualizar o documento em segundo plano
            FirebaseFirestore.instance
                .collection('users')
                .doc(doc.id)
                .update({'enrollmentDate': now});

            return {
              'id': doc.id,
              'name': userData['name'] ?? 'Nome não informado',
              'email': userData['email'] ?? 'Email não informado',
              'enrollmentDate': now,
              'role': userData['role'] ?? 'student',
            };
          }

          return {
            'id': doc.id,
            'name': userData['name'] ?? 'Nome não informado',
            'email': userData['email'] ?? 'Email não informado',
            'enrollmentDate': enrollmentDate,
            'role': userData['role'] ?? 'student',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar alunos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteStudent(String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .delete();
      setState(() {
        _students.removeWhere((student) => student['id'] == studentId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno removido com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover aluno: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos Inscritos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum aluno inscrito',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    final enrollmentDate =
                        student['enrollmentDate'] as Timestamp?;
                    final formattedDate = enrollmentDate != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(enrollmentDate.toDate())
                        : 'Não informado';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            student['name']?[0]?.toUpperCase() ?? '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(student['name'] ?? 'Nome não informado'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student['email'] ?? 'Email não informado'),
                            Text('Inscrito em: $formattedDate'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar exclusão'),
                                content: Text(
                                    'Deseja realmente remover ${student['name']}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteStudent(student['id']);
                                    },
                                    child: const Text(
                                      'Remover',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
