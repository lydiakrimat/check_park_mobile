import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

/// Point d'entrée de l'arbre de widgets de l'application.
///
/// Écoute [AuthProvider] pour router automatiquement vers :
///   - [SplashScreen]  : au démarrage (vérification du token)
///   - [LoginScreen]   : si non connecté
///   - [HomeScreen]    : si connecté avec le rôle AgentSecurite
///
/// La navigation est réactive : si le token expire ou si l'agent se déconnecte,
/// l'app revient automatiquement sur LoginScreen sans action supplémentaire.
class ALPRApp extends StatelessWidget {
  const ALPRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALPR — Algérie Télécom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AppRouter(),
    );
  }
}

/// Widget qui route vers le bon écran selon l'état d'authentification.
class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  @override
  void initState() {
    super.initState();
    // Vérifie si un token est déjà stocké localement au démarrage.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().status;

    switch (authStatus) {
      case AuthStatus.checking:
        // Affiche le splash screen pendant la vérification du token.
        return const SplashScreen();
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
