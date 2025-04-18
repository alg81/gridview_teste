# Curso de Violão - Aplicativo Flutter

Um aplicativo móvel desenvolvido em Flutter para um curso de violão online, com área administrativa e área do aluno.

## Funcionalidades

- Autenticação de usuários (admin e aluno)
- GridView de aulas com thumbnails
- Player de vídeo integrado
- Gerenciamento de conteúdo (admin)
- Interface responsiva e moderna

## Requisitos

- Flutter SDK (versão 3.0.0 ou superior)
- Firebase account
- Android Studio / VS Code
- Emulador ou dispositivo físico para testes

## Configuração do Projeto

1. Clone o repositório
2. Execute `flutter pub get` para instalar as dependências
3. Configure o Firebase:
   - Crie um projeto no Firebase Console
   - Adicione os arquivos de configuração do Firebase
   - Configure as regras de segurança do Firestore

## Estrutura do Projeto

```
lib/
  ├── main.dart
  ├── models/
  ├── viewmodels/
  │   ├── auth_viewmodel.dart
  │   └── lesson_viewmodel.dart
  └── views/
      ├── login_view.dart
      ├── admin/
      │   └── admin_home_view.dart
      └── student/
          ├── student_home_view.dart
          └── lesson_player_view.dart
```

## Dependências Principais

- provider: Gerenciamento de estado
- firebase_core: Integração com Firebase
- firebase_auth: Autenticação
- cloud_firestore: Banco de dados
- video_player: Reprodução de vídeos

## Como Executar

1. Certifique-se de ter o Flutter instalado e configurado
2. Execute `flutter pub get`
3. Execute `flutter run`

## Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes. 