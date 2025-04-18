import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'package:gridview_teste/views/auth/login_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimationDesc;
  late Animation<Offset> _slideAnimationDesc;
  late Animation<double> _fadeAnimationVideo;
  late Animation<Offset> _slideAnimationVideo;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4'),
    )..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });

    // Configuração das animações
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Animações para o título
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Animações para a descrição
    _fadeAnimationDesc = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    _slideAnimationDesc = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    ));

    // Animações para o vídeo
    _fadeAnimationVideo = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));

    _slideAnimationVideo = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    ));

    _animationController.forward();

    // Adiciona um listener para quando o vídeo terminar
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        setState(() {
          _controller.seekTo(Duration.zero);
          _controller.pause();
        });
      }
    });
  }

  void _navigateToLogin() {
    // Pausa o vídeo antes de navegar
    _controller.pause();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.login, color: Colors.white),
            onPressed: _navigateToLogin,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem de fundo desfocada
          Image.asset(
            'assets/images/splash_screen.png',
            fit: BoxFit.cover,
          ),
          // Efeito de desfoque
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Conteúdo
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: isLandscape ? 20 : 40),
                    // Título animado
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Bem-vindo ao Curso de Violão',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLandscape ? 28 : 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Texto descritivo animado
                    FadeTransition(
                      opacity: _fadeAnimationDesc,
                      child: SlideTransition(
                        position: _slideAnimationDesc,
                        child: Text(
                          'Aprenda violão do básico ao avançado com aulas práticas e didáticas.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isLandscape ? 18 : 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 16 : 32),
                    // Área do vídeo
                    if (_isInitialized)
                      FadeTransition(
                        opacity: _fadeAnimationVideo,
                        child: SlideTransition(
                          position: _slideAnimationVideo,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Center(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: isLandscape
                                      ? screenWidth * 0.5
                                      : screenWidth,
                                  maxHeight: isLandscape
                                      ? screenHeight * 0.45
                                      : screenHeight * 0.35,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                            blurRadius: 20,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (_controller.value.isPlaying) {
                                                _controller.pause();
                                              } else {
                                                _controller.play();
                                              }
                                            });
                                          },
                                          child: VideoPlayer(_controller),
                                        ),
                                      ),
                                    ),
                                    if (!_controller.value.isPlaying)
                                      Container(
                                        color: Colors.black.withOpacity(0.3),
                                        child: IconButton(
                                          iconSize: 64,
                                          icon: const Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _controller.play();
                                            });
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Adiciona um padding inferior para evitar que o conteúdo seja cortado
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}
