import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/access_service.dart';
import 'services/notification_service.dart';
import 'services/scan_service.dart';
import 'services/camera_service.dart';
import 'services/statistics_service.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/history_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

/// Point d'entrée de l'application ALPR Mobile — Algérie Télécom.
///
/// Configure l'arbre de providers (state management) et injecte tous les services.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait uniquement.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialisation des services et providers persistants.
  final authService    = AuthService();
  final themeProvider  = ThemeProvider();
  final localeProvider = LocaleProvider();

  await Future.wait([
    authService.init(),
    themeProvider.init(),
    localeProvider.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider — premier car les autres dépendent du token.
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService),
        ),

        // ThemeProvider — mode clair/sombre avec persistence.
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),

        // LocaleProvider — langue fr/ar avec persistence.
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),

        // ScanProvider — caméra + AI Service.
        ChangeNotifierProvider<ScanProvider>(
          create: (_) => ScanProvider(ScanService(), CameraService()),
        ),

        // HistoryProvider — historique des accès depuis Laravel.
        ChangeNotifierProxyProvider<AuthProvider, HistoryProvider>(
          create: (ctx) => HistoryProvider(
            AccessService(ApiService(
              getToken: ctx.read<AuthProvider>().getToken,
            )),
          ),
          update: (_, auth, __) => HistoryProvider(
            AccessService(ApiService(getToken: auth.getToken)),
          ),
        ),

        // NotificationProvider — notifications depuis Laravel.
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (ctx) => NotificationProvider(
            NotificationService(ApiService(
              getToken: ctx.read<AuthProvider>().getToken,
            )),
          ),
          update: (_, auth, prev) => prev!..updateService(
            NotificationService(ApiService(getToken: auth.getToken)),
          ),
        ),

        // StatisticsProvider — calcul local à partir de l'historique.
        ChangeNotifierProvider<StatisticsProvider>(
          create: (_) => StatisticsProvider(StatisticsService()),
        ),
      ],
      child: const ALPRApp(),
    ),
  );
}
