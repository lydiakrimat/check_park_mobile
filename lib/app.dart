import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
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
/// Écoute [ThemeProvider] pour basculer entre mode clair/sombre.
/// Écoute [LocaleProvider] pour la langue et le sens RTL/LTR.
class ALPRApp extends StatelessWidget {
  const ALPRApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    final locale    = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      title: 'ALPR — Algérie Télécom',
      debugShowCheckedModeBanner: false,
      theme:      AppTheme.light,
      darkTheme:  AppTheme.dark,
      themeMode:  themeMode,
      locale:     locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Locales supportées — Flutter active RTL automatiquement pour 'ar'.
      supportedLocales: const [Locale('fr'), Locale('ar')],
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().status;

    switch (authStatus) {
      case AuthStatus.checking:
        return const SplashScreen();
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
