import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, student }

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  UserRole _userRole = UserRole.student;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isAdmin = false;

  // Lista de emails de administradores
  final List<String> _adminEmails = [
    'admin@cursoviolao.com',
    'alexandreaugustolg@gmail.com',
  ];

  User? get user => _user;
  UserRole get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;

  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Iniciando processo de login para: $email');

      // Verifica se o email é de um administrador
      if (_adminEmails.contains(email.trim())) {
        _userRole = UserRole.admin;
        _isAdmin = true;
        debugPrint('Usuário identificado como administrador');
      } else {
        _userRole = UserRole.student;
        _isAdmin = false;
        debugPrint('Usuário identificado como estudante');
      }

      // Tenta fazer login com email e senha
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        debugPrint('Login falhou: userCredential.user é nulo');
        return false;
      }

      _user = userCredential.user;
      _isAuthenticated = true;
      debugPrint('Login bem sucedido para: ${_user?.email}');

      // Se for admin, atualiza o token com a claim de admin
      if (_userRole == UserRole.admin) {
        await _user?.getIdToken(true); // Força atualização do token
        debugPrint('Token atualizado com claim de admin');
      }

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('FirebaseAuthException durante o login:');
      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Erro inesperado durante o login:');
      debugPrint('Erro: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('Iniciando processo de logout');
      await _auth.signOut();
      _user = null;
      _userRole = UserRole.student;
      _isAuthenticated = false;
      _isAdmin = false;
      debugPrint('Logout realizado com sucesso');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Erro ao fazer logout:');
      debugPrint('Erro: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Erro ao fazer login: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Criar usuário no Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvar informações adicionais no Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'enrollmentDate': FieldValue.serverTimestamp(),
        'role': 'student',
      });
    } catch (e) {
      debugPrint('Erro ao registrar usuário: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
