# Check Park Mobile — Application Flutter ALPR

Application mobile de contrôle des immatriculations de véhicules pour les agents de sécurité d'Algérie Télécom.
Développée avec Flutter, elle communique avec deux backends : le **backend Laravel** (gestion des données) et le **AI Service FastAPI** (pipeline de reconnaissance de plaques).

---

## État actuel du projet (session 2026-05-08 / 09)

### Ce qui fonctionne
- Authentification JWT (login / logout / persistance du token)
- Dark mode + Light mode (ThemeProvider)
- Changement de langue français / arabe avec RTL (LocaleProvider)
- Écran Scanner : caméra, cadre dynamique, overlay de chargement, résultat OK/refusé/non détecté
- Recherche manuelle de plaque (POST /verify)
- Historique des accès avec filtres
- Notifications avec compteur non-lues
- Statistiques (graphiques fl_chart)
- Paramètres (profil agent, thème, langue)

### Testé et confirmé fonctionnel
- Émulateur Android AVD avec `_host = '10.0.2.2'`
- Serveur Laravel répond en 57ms (confirmé par curl)
- AI Service FastAPI répond correctement au POST /scan avec image JPEG

### Problème réseau téléphone physique (non bloquant)
Le téléphone physique ne peut pas atteindre le Mac via WiFi même avec la bonne IP (192.168.1.6).
Hypothèse : **AP Isolation** (isolation client) activée sur le routeur.
Solution : désactiver l'AP Isolation dans les paramètres du routeur, ou utiliser USB tethering.
Pour continuer à développer : utiliser l'émulateur AVD avec `10.0.2.2`.

---

## Stack technique

- **Framework** : Flutter (Dart), SDK ^3.8.1
- **State management** : Provider (`ChangeNotifier`)
- **HTTP** : package `http` (REST + multipart/form-data)
- **Stockage local** : `shared_preferences` (token JWT + préférences)
- **Caméra** : package `camera` (capture photo native)
- **Polices** : Google Fonts — Plus Jakarta Sans
- **Charts** : fl_chart (graphiques statistiques)
- **Localisation** : flutter_localizations (fr + ar, RTL auto)

---

## Configuration réseau — IMPORTANT

Fichier : `lib/config/api_config.dart`

```dart
// Pour émulateur Android (AVD) :
static const String _host = '10.0.2.2';

// Pour vrai téléphone physique (même réseau WiFi que le Mac) :
// static const String _host = '192.168.1.6';  // adapter selon ipconfig getifaddr en0
```

**Avant chaque session de développement :**
- Vérifier l'IP actuelle du Mac : `ipconfig getifaddr en0`
- Si tu testes sur émulateur : `_host = '10.0.2.2'`
- Si tu testes sur téléphone physique : `_host = '<IP du Mac>'`

**Les deux backends doivent écouter sur `0.0.0.0` (pas `127.0.0.1`) :**
```bash
# Laravel
php artisan serve --host=0.0.0.0 --port=8000

# AI Service FastAPI
uvicorn main:app --host 0.0.0.0 --port 8080
```

---

## Lancement

```bash
flutter pub get

# Émulateur Android (AVD) — s'assurer que _host = '10.0.2.2'
flutter run

# APK release pour téléphone physique
flutter build apk --release
# APK généré : build/app/outputs/flutter-apk/app-release.apk
# Transférer via câble USB ou airdrop, puis installer sur le téléphone
```

---

## Architecture des fichiers

```
lib/
├── config/
│   ├── api_config.dart         URLs et timeouts (Laravel :8000, AI Service :8080)
│   └── app_constants.dart      Clés SharedPreferences, rôle AgentSecurite, seuils, messages d'erreur
├── models/
│   ├── user.dart               UserModel
│   ├── employee.dart           Employee
│   ├── vehicle.dart            Vehicle (avec relation employe)
│   ├── access_record.dart      AccessRecord
│   ├── notification_model.dart NotificationModel
│   └── scan_result.dart        ScanResult — réponse du AI Service
├── services/
│   ├── api_service.dart        Client HTTP générique (injecte le token Bearer, gère erreurs)
│   ├── auth_service.dart       Login / logout / stockage token (SharedPreferences)
│   ├── scan_service.dart       POST /scan (photo multipart) et POST /verify (texte JSON)
│   ├── camera_service.dart     Initialisation caméra, capture photo
│   ├── access_service.dart     GET /api/acces
│   ├── notification_service.dart GET/PUT/DELETE /api/notifications
│   ├── search_service.dart     Recherche via POST /verify
│   ├── statistics_service.dart Calcul KPIs localement
│   └── daily_counter_service.dart Compteurs journaliers (SharedPreferences)
├── providers/
│   ├── auth_provider.dart      AuthStatus {checking, unauthenticated, authenticated}
│   ├── scan_provider.dart      ScanStatus {idle, capturing, sending, done, error}
│   ├── history_provider.dart   Liste + filtres des accès
│   ├── notification_provider.dart Liste + compteur non lus
│   ├── statistics_provider.dart KPIs calculés depuis history_provider
│   ├── locale_provider.dart    Langue active (fr/ar) + Locale Flutter
│   └── theme_provider.dart     Mode clair/sombre (ThemeMode)
├── screens/
│   ├── splash_screen.dart      Écran de démarrage (logo AT, vérification token)
│   ├── login_screen.dart       Formulaire email + mot de passe
│   ├── home_screen.dart        Dashboard principal (4 onglets)
│   ├── scanner_screen.dart     Caméra + cadre véhicule + résultat scan
│   ├── search_screen.dart      Recherche manuelle de plaque
│   ├── history_screen.dart     Historique des accès avec filtres
│   ├── notifications_screen.dart Notifications + marquer comme lues
│   ├── stats_screen.dart       Graphiques fl_chart (pie, bar, line)
│   └── settings_screen.dart    Profil agent, thème, langue
├── widgets/
│   ├── access_card.dart        Carte d'un enregistrement d'accès
│   ├── notification_card.dart  Carte d'une notification
│   ├── error_banner.dart       Bannière d'erreur réutilisable (rouge, bouton retry optionnel)
│   ├── stat_card.dart          Carte KPI (chiffre + libellé)
│   ├── status_badge.dart       Badge coloré (Autorisé / Refusé / Expiré)
│   ├── plate_badge.dart        Badge plaque d'immatriculation
│   └── at_header.dart          En-tête Algérie Télécom
├── theme/
│   ├── app_colors.dart         Couleurs de marque (brand colors — fixes, pas de dark mode)
│   ├── app_colors_scheme.dart  ThemeExtension pour surface/text/border (adaptatif dark/light)
│   └── app_theme.dart          AppTheme.light et AppTheme.dark
├── l10n/
│   └── app_localizations.dart  Toutes les chaînes FR + AR + extension context.l10n
├── utils/
│   ├── validators.dart         Validation email, mot de passe, plaque
│   ├── date_formatter.dart     Formatage dates
│   └── plate_formatter.dart    Normalisation et affichage des plaques
├── app.dart                    ALPRApp + _AppRouter (routing basé sur AuthStatus)
└── main.dart                   Point d'entrée — MultiProvider + orientations
```

---

## Système de thème (dark mode)

### Deux couches de couleurs

**1. `AppColors` (lib/theme/app_colors.dart) — couleurs de marque fixes**
Ne changent JAMAIS avec le thème. Toujours accédées via `AppColors.xxx`.
```dart
AppColors.primary      // bleu AT
AppColors.danger       // rouge erreur
AppColors.success      // vert autorisé
AppColors.warning      // orange refusé/alerte
AppColors.okText / noText / expText   // textes badges statut
AppColors.okBg / noBg / expBg (dans AppColorsScheme) // fonds badges
```

**2. `AppColorsScheme` (lib/theme/app_colors_scheme.dart) — couleurs adaptatives**
ThemeExtension — changent entre light et dark. Accédées via `context.colors`.
```dart
final c = context.colors;
c.background   // fond principal
c.surface      // fond carte/conteneur
c.text         // texte principal
c.muted        // texte secondaire grisé
c.border       // bordures
c.white        // blanc (inversé en dark: surface sombre)
c.blueTint     // fond bleu très atténué
c.orangeTint   // fond orange très atténué
c.okBg / noBg / expBg   // fonds badges statut adaptatifs
```

### Règle d'utilisation
- Couleurs de surface/texte/bordures → `context.colors` (adaptatif)
- Couleurs de marque/statut → `AppColors.xxx` (fixe)

---

## Système de localisation (FR / AR)

### Architecture
- `AppLocalizations(bool _ar)` dans `lib/l10n/app_localizations.dart`
- Accès via extension : `context.l10n` (retourne l'instance correspondant à la locale active)
- `LocaleProvider` stocke la `Locale` active et notifie l'arbre

### Règle CRITIQUE
Dans `AppL10nX` (l'extension `context.l10n`) :
```dart
// TOUJOURS listen: false — sinon crash depuis les event handlers
Provider.of<LocaleProvider>(this, listen: false)
```

### Localisation Flutter (Material widgets)
Dans `app.dart`, `MaterialApp` doit avoir :
```dart
import 'package:flutter_localizations/flutter_localizations.dart';

localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,   // TextField, DatePicker, etc.
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [Locale('fr'), Locale('ar')],
```
Sans ça, les widgets Material (TextField, showModalBottomSheet) crashent avec
"No MaterialLocalizations found".

---

## Flux de scan — photo vers AI Service

```
[Écran Scanner]
    │  Bouton capture
    ▼
ScanProvider.captureAndScan()
    │
    ├─ CameraService.takePhoto()  →  Fichier JPEG temporaire local
    │
    └─ ScanService.scanPhoto(file)
           │  POST /scan  →  AI Service FastAPI :8080
           │  multipart/form-data  { "image": <fichier JPEG> }
           │  Content-Type forcé : image/jpeg  (évite HTTP 415)
           │
           │  Pipeline IA :
           │    1. YOLOX      — détection bounding box plaque
           │    2. PaddleOCR  — lecture des caractères
           │    3. Fuzzy matching — comparaison BDD (seuil 80%)
           │    4. Laravel    — vérification droits d'accès
           │
           │  ← ScanResult JSON
           │    { detected, plate_ocr, plate_matched, similarity_score,
           │      authorized, reason, confidence, bounding_box,
           │      vehicle: {...}, owner: {...} }
           ▼
    ScanProvider.result  →  Écran affiche résultat (autorisé / refusé / non détecté)
```

### Résultats possibles du scan
| Cas | Condition | Affichage |
|-----|-----------|-----------|
| Plaque autorisée | `detected && authorized` | Panel vert |
| Plaque refusée | `detected && !authorized` | Panel rouge |
| Plaque non détectée | `!detected` | Panel orange (aucunePlaqueMsg) |

---

## Bugs résolus dans cette session

### 1. HTTP 415 lors de l'envoi d'une photo au AI Service
**Cause :** `http.MultipartFile.fromPath` ne définit pas le Content-Type de la partie fichier
quand l'extension du fichier temporaire Android n'est pas reconnue. FastAPI rejette alors la requête.

**Fix dans `scan_service.dart` :**
```dart
import 'package:http_parser/http_parser.dart';

request.files.add(
  await http.MultipartFile.fromPath(
    'image',
    imageFile.path,
    filename: 'scan.jpg',
    contentType: MediaType('image', 'jpeg'),  // force Content-Type: image/jpeg
  ),
);
```
`http_parser` doit être déclaré explicitement dans `pubspec.yaml` même si c'est une dépendance transitive de `http`.

### 2. "No MaterialLocalizations found" (crash sur 3 écrans)
**Cause :** `flutter_localizations` manquait dans `pubspec.yaml` et les delegates n'étaient
pas déclarés dans `MaterialApp`.

**Fix :**
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```
```dart
// app.dart — dans MaterialApp
localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

### 3. Crash Provider dans dialog de confirmation (search_screen)
**Cause :** `AppL10nX.l10n` utilisait `Provider.of<LocaleProvider>(this)` avec `listen: true`
(défaut). Quand appelé depuis un event handler ou un dialog, Flutter lève une exception
car on essaie d'écouter en dehors de l'arbre de widgets actif.

**Fix :** `Provider.of<LocaleProvider>(this, listen: false)`

### 4. Bug dispose() dans scanner_screen
**Cause :** `context.read<ScanProvider>()` dans `dispose()` est unsafe après déactivation du widget.

**Fix :** Cacher la référence en `initState` :
```dart
ScanProvider? _scanProv;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scanProv = context.read<ScanProvider>();
    // ...
  });
}

@override
void dispose() {
  _scanProv?.stopCamera();
  super.dispose();
}
```

### 5. Timeout login sur APK release (téléphone physique)
**Cause :** Android 9+ bloque le trafic HTTP cleartext dans les APK release par défaut.
Le mode debug (`flutter run`) autorise le cleartext automatiquement — c'est pourquoi
le login fonctionnait en debug mais pas en release.

**Fix dans `android/app/src/main/AndroidManifest.xml` :**
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

---

## Authentification — Sanctum

### Flux de connexion
```
[Écran Login]
    │  email + password
    ▼
AuthProvider.login()
    │
AuthService.login()
    │  POST /api/login/mobile  →  Backend Laravel
    │  { "email": "...", "password": "..." }
    │
    │  ← { "token": "6|abc...", "user": { id, nom, prenom, role, ... } }
    │
    ├─ Vérifie role == "AgentSecurite" (double contrôle client)
    ├─ Token stocké dans SharedPreferences (clé : auth_token)
    ├─ User stocké dans SharedPreferences (clé : auth_user, JSON)
    └─ AuthStatus → authenticated → HomeScreen
```

### Persistance au redémarrage
`_AppRouter.initState` → `AuthProvider.checkAuthStatus()` :
1. Lecture token depuis SharedPreferences
2. Si token présent → charge user depuis cache → HomeScreen directement
3. Si absent → LoginScreen

---

## Endpoints consommés

| Service | Méthode | URL | Utilisé par |
|---|---|---|---|
| Laravel | POST | `/api/login/mobile` | AuthService.login() |
| Laravel | POST | `/api/logout` | AuthService.logout() |
| Laravel | GET | `/api/me` | AuthService.fetchCurrentUser() |
| Laravel | GET | `/api/acces` | AccessService |
| Laravel | GET | `/api/notifications` | NotificationService |
| Laravel | PUT | `/api/notifications/{id}/lire` | NotificationService |
| Laravel | PUT | `/api/notifications/lire-tout` | NotificationService |
| Laravel | DELETE | `/api/notifications/{id}` | NotificationService |
| Laravel | PUT | `/api/utilisateurs/{id}` | AuthService.updateProfile() |
| AI Service | POST | `/scan` | ScanService.scanPhoto() |
| AI Service | POST | `/verify` | ScanService.verifyPlate() |

---

## Dépendances principales

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  http: ^1.2.2                # REST + multipart
  http_parser: ^4.0.2         # MediaType pour forcer Content-Type image/jpeg (fix 415)
  shared_preferences: ^2.3.4  # Token JWT local
  camera: ^0.11.0+2           # Caméra native
  provider: ^6.1.2            # State management
  google_fonts: ^6.0.0        # Plus Jakarta Sans
  fl_chart: ^0.70.0           # Graphiques statistiques
  font_awesome_flutter: ^10.0.0

dev_dependencies:
  flutter_lints: ^5.0.0
```

---

## Permissions Android

`android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<application
    android:usesCleartextTraffic="true"   <!-- REQUIS pour HTTP en release -->
    ...>
```

---

## Commandes utiles

```bash
# Vérifier les devices connectés
flutter devices

# Lancer sur émulateur avec logs
flutter run

# Lancer en release sur device USB (avec logs)
flutter run --release

# Générer APK release
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# IP actuelle du Mac sur le réseau local
ipconfig getifaddr en0

# Vérifier que le backend Laravel est joignable
curl http://192.168.1.6:8000/api/login/mobile \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"votre@email.com","password":"motdepasse"}'

# NDK version requise (dans build.gradle.kts)
# ndkVersion = "27.0.12077973"
```
