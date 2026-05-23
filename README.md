# Check Park Mobile — Application Flutter ALPR

Application mobile de controle des immatriculations de vehicules pour les agents de securite d'Algerie Telecom.
Developpee avec Flutter, elle communique avec deux backends : le **backend Laravel** (gestion des donnees) et le **AI Service FastAPI** (pipeline de reconnaissance de plaques).

---

### Ce qui fonctionne
- Authentification JWT (login / logout / persistance du token)
- Dark mode + Light mode (ThemeProvider)
- Changement de langue francais / arabe avec RTL (LocaleProvider)
- Ecran Scanner : camera, cadre dynamique, overlay de chargement, resultat OK/refuse/non detecte/temporaire visiteur
- Recherche manuelle de plaque (POST /verify)
- Historique des acces avec filtres
- Notifications securite avec compteur non-lues (`vu_agent`), marquer lu, supprimer
- Statistiques (graphiques fl_chart)
- Parametres (profil agent, theme, langue)
- Layout responsive sur toutes les tailles d'ecran (360px a 430px+)
- Textes UI bilingues francais / arabe (traduction dynamique des messages serveur incluse)
- Widgets reutilisables extraits dans lib/widgets/ (InfoRow, StatCard, etc.)

### Teste et confirme fonctionnel
- Emulateur Android AVD avec `_host = '10.0.2.2'`
- Telephone physique Android via USB avec `_host = '192.168.1.3'`
- Serveur Laravel repond en 57ms (confirme par curl)
- AI Service FastAPI repond correctement au POST /scan avec image JPEG
- Les deux backends ecoutent sur `0.0.0.0` (accessible depuis le reseau local)

---

## Stack technique

- **Framework** : Flutter (Dart), SDK ^3.8.1
- **State management** : Provider (`ChangeNotifier`)
- **HTTP** : package `http` (REST + multipart/form-data)
- **Stockage local** : `shared_preferences` (token JWT + preferences)
- **Camera** : package `camera` (capture photo native)
- **Polices** : Google Fonts — Plus Jakarta Sans
- **Charts** : fl_chart (graphiques statistiques)
- **Localisation** : flutter_localizations (fr + ar, RTL auto)

---

## Configuration reseau — IMPORTANT

Fichier : `lib/config/api_config.dart`

```dart
// Pour emulateur Android (AVD) :
//static const String _host = '10.0.2.2';

// Pour vrai telephone physique (meme reseau WiFi que le Mac) :
static const String _host = '192.168.1.3';  // adapter selon ifconfig | grep inet
```

**Avant chaque session de developpement :**
- Verifier l'IP actuelle du Mac : `ifconfig | grep "inet " | grep -v 127`
- Si tu testes sur emulateur : `_host = '10.0.2.2'`
- Si tu testes sur telephone physique : `_host = '<IP du Mac>'`

**Les deux backends doivent ecouter sur `0.0.0.0` (pas `127.0.0.1`) :**
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

# Emulateur Android (AVD) — s'assurer que _host = '10.0.2.2'
flutter run

# Telephone physique USB — s'assurer que _host = '<IP du Mac>'
flutter run

# APK release pour telephone physique
flutter build apk --release
# APK genere : build/app/outputs/flutter-apk/app-release.apk
# Transferer via cable USB ou airdrop, puis installer sur le telephone
```

---

## Architecture des fichiers

```
lib/
├── config/
│   ├── api_config.dart         URLs et timeouts (Laravel :8000, AI Service :8080)
│   └── app_constants.dart      Cles SharedPreferences, role AgentSecurite, seuils, messages d'erreur
├── models/
│   ├── user.dart               UserModel
│   ├── employee.dart           Employee
│   ├── vehicle.dart            Vehicle (avec relation employe)
│   ├── access_record.dart      AccessRecord
│   ├── notification_model.dart NotificationModel
│   └── scan_result.dart        ScanResult — reponse du AI Service
├── services/
│   ├── api_service.dart        Client HTTP generique (injecte le token Bearer, gere erreurs)
│   ├── auth_service.dart       Login / logout / stockage token (SharedPreferences)
│   ├── scan_service.dart       POST /scan (photo multipart) et POST /verify (texte JSON)
│   ├── camera_service.dart     Initialisation camera, capture photo
│   ├── access_service.dart     GET /api/acces
│   ├── notification_service.dart GET /notifications/agent, PATCH vu-agent, DELETE
│   ├── search_service.dart     Recherche via POST /verify
│   ├── statistics_service.dart Calcul KPIs localement
│   └── daily_counter_service.dart Compteurs journaliers (SharedPreferences)
├── providers/
│   ├── auth_provider.dart      AuthStatus {checking, unauthenticated, authenticated}
│   ├── scan_provider.dart      ScanStatus {idle, capturing, sending, done, error}
│   ├── history_provider.dart   Liste + filtres des acces
│   ├── notification_provider.dart Liste + compteur non lus
│   ├── statistics_provider.dart KPIs calcules depuis history_provider
│   ├── locale_provider.dart    Langue active (fr/ar) + Locale Flutter
│   └── theme_provider.dart     Mode clair/sombre (ThemeMode)
├── screens/
│   ├── splash_screen.dart      Ecran de demarrage (logo AT, verification token)
│   ├── login_screen.dart       Formulaire email + mot de passe
│   ├── home_screen.dart        Dashboard principal (4 onglets)
│   ├── scanner_screen.dart     Camera + cadre vehicule + resultat scan
│   ├── search_screen.dart      Recherche manuelle de plaque
│   ├── history_screen.dart     Historique des acces avec filtres
│   ├── notifications_screen.dart Notifications + marquer comme lues
│   ├── stats_screen.dart       Graphiques fl_chart (pie, bar, line)
│   └── settings_screen.dart    Profil agent, theme, langue
├── widgets/
│   ├── access_card.dart        Carte d'un enregistrement d'acces (gestion debordement texte)
│   ├── notification_card.dart  Carte d'une notification (bilingue fr/ar)
│   ├── error_banner.dart       Banniere d'erreur reutilisable (rouge, bouton retry optionnel)
│   ├── stat_card_widget.dart   Carte KPI (hauteur fixe, taille uniforme entre cartes)
│   ├── info_row_widget.dart    Ligne label/valeur reutilisable (gestion debordement)
│   ├── temporaire_result_card.dart Carte resultat visiteur temporaire (scan + recherche)
│   ├── status_badge.dart       Badge colore (Autorise / Refuse / Expire)
│   ├── plate_badge.dart        Badge plaque d'immatriculation
│   └── at_header.dart          En-tete Algerie Telecom (logo contraint a 32px)
├── theme/
│   ├── app_colors.dart         Couleurs de marque (brand colors — fixes, pas de dark mode)
│   ├── app_colors_scheme.dart  ThemeExtension pour surface/text/border (adaptatif dark/light)
│   └── app_theme.dart          AppTheme.light et AppTheme.dark
├── l10n/
│   └── app_localizations.dart  Toutes les chaines FR + AR + extension context.l10n
│                               + traduction dynamique des messages serveur (traduireMessageNotif, traduireTitreNotif)
├── utils/
│   ├── responsive.dart         Helper responsive : Responsive.rw(), Responsive.rh()
│   ├── validators.dart         Validation email, mot de passe, plaque
│   ├── date_formatter.dart     Formatage dates
│   └── plate_formatter.dart    Normalisation et affichage des plaques
├── app.dart                    ALPRApp + _AppRouter (routing base sur AuthStatus)
└── main.dart                   Point d'entree — MultiProvider + orientations
```

---

## Systeme responsive

Helper : `lib/utils/responsive.dart`

```dart
// Largeur proportionnelle (reference : 390px)
Responsive.rw(context, 100)  // 100 sur 390px, ~92 sur 360px

// Hauteur proportionnelle (reference : 844px)
Responsive.rh(context, 200)  // 200 sur 844px, adapte sur d'autres ecrans
```

Utilise dans : login_screen, splash_screen, home_screen, stats_screen, scanner_screen.
Toutes les dimensions fixes importantes (containers, charts, logos) utilisent ce helper.

---

## Systeme de theme (dark mode)

### Deux couches de couleurs

**1. `AppColors` (lib/theme/app_colors.dart) — couleurs de marque fixes**
Ne changent JAMAIS avec le theme. Toujours accedees via `AppColors.xxx`.
```dart
AppColors.primary      // bleu AT
AppColors.danger       // rouge erreur
AppColors.success      // vert autorise
AppColors.warning      // orange refuse/alerte
AppColors.okText / noText / expText   // textes badges statut
AppColors.okBg / noBg / expBg (dans AppColorsScheme) // fonds badges
```

**2. `AppColorsScheme` (lib/theme/app_colors_scheme.dart) — couleurs adaptatives**
ThemeExtension — changent entre light et dark. Accedees via `context.colors`.
```dart
final c = context.colors;
c.background   // fond principal
c.surface      // fond carte/conteneur
c.text         // texte principal
c.muted        // texte secondaire grise
c.border       // bordures
c.white        // blanc (inverse en dark: surface sombre)
c.blueTint     // fond bleu tres attenue
c.orangeTint   // fond orange tres attenue
c.okBg / noBg / expBg   // fonds badges statut adaptatifs
```

### Regle d'utilisation
- Couleurs de surface/texte/bordures → `context.colors` (adaptatif)
- Couleurs de marque/statut → `AppColors.xxx` (fixe)

---

## Systeme de localisation (FR / AR)

### Architecture
- `AppLocalizations(bool _ar)` dans `lib/l10n/app_localizations.dart`
- Acces via extension : `context.l10n` (retourne l'instance correspondant a la locale active)
- `LocaleProvider` stocke la `Locale` active et notifie l'arbre
- RTL automatique via Flutter quand `locale = Locale('ar')`

### Traduction des messages serveur
Les notifications sont stockees en francais dans la BDD Laravel.
Cote mobile, `AppLocalizations` fournit deux methodes de traduction dynamique :
- `traduireMessageNotif(String message)` : detecte les patterns connus (regex) et retourne la traduction arabe
- `traduireTitreNotif(String titre)` : mappe les titres connus vers leur traduction arabe

En francais ces methodes retournent le texte original sans modification.

### Regle CRITIQUE
Dans `AppL10nX` (l'extension `context.l10n`) :
```dart
// TOUJOURS listen: false — sinon crash depuis les event handlers
Provider.of<LocaleProvider>(this, listen: false)
```

### Regle — aucune chaine hardcodee
Toute chaine affichee a l'utilisateur doit passer par `app_localizations.dart`.
Chaque cle a obligatoirement une version FR et une version AR.
Les accents francais doivent etre preserves (Autorise, Entree, etc.).

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
Sans ca, les widgets Material (TextField, showModalBottomSheet) crashent avec
"No MaterialLocalizations found".

---

## Flux de scan — photo vers AI Service

```
[Ecran Scanner]
    │  Bouton capture
    ▼
ScanProvider.captureAndScan()
    │
    ├─ CameraService.takePhoto()  →  Fichier JPEG temporaire local
    │
    └─ ScanService.scanPhoto(file)
           │  POST /scan  →  AI Service FastAPI :8080
           │  multipart/form-data  { "image": <fichier JPEG> }
           │  Content-Type force : image/jpeg  (evite HTTP 415)
           │
           │  Pipeline IA :
           │    1. YOLOX      — detection bounding box plaque
           │    2. PaddleOCR  — lecture des caracteres
           │    3. Fuzzy matching — comparaison BDD (seuil 80%)
           │    4. Laravel    — verification droits d'acces
           │
           │  ← ScanResult JSON
           │    { detected, plate_ocr, plate_matched, similarity_score,
           │      authorized, type, reason, confidence, bounding_box,
           │      vehicle: {...}, owner: {...} }
           │    Pour les temporaires : type="temporaire",
           │      owner: {nom, prenom, telephone, motif_visite, duree_autorisee}
           ▼
    ScanProvider.result  →  Ecran affiche resultat (autorise / refuse / non detecte)
```

### Resultats possibles du scan
| Cas | Condition | Affichage |
|-----|-----------|-----------|
| Visiteur temporaire | `detected && isTemporaire` | TemporaireResultCard (nom, telephone, motif, duree) |
| Plaque autorisee | `detected && authorized` | Panel vert |
| Plaque refusee | `detected && !authorized` | Panel rouge |
| Plaque non detectee | `!detected` | Panel orange (aucunePlaqueMsg) |

---

## Systeme de notifications (agent mobile)

L'application mobile utilise le systeme `vu_agent` — independant du `vu_admin` du dashboard web.

### Endpoints utilises

| Methode | Route | Description |
|---------|-------|-------------|
| GET | `/api/notifications/agent` | Toutes les notifications |
| PATCH | `/api/notifications/{id}/vu-agent` | Marquer une notification vue |
| PATCH | `/api/notifications/tout-vu-agent` | Marquer toutes vues |
| DELETE | `/api/notifications/{id}` | Supprimer une notification |

### Architecture

- **`NotificationService`** : client HTTP vers les endpoints agent
- **`NotificationProvider`** (ChangeNotifier) : gere la liste locale, le compteur non-lues, et les mises a jour optimistes
- **`NotificationCard`** (widget) : affiche une notification avec icone par type, badge, date, boutons actions
- **`ChangeNotifierProxyProvider`** dans `main.dart` : preserve l'etat du provider quand le token change via `prev!..updateService(...)`

### Types de notifications affiches

| Type | Badge | Couleur |
|------|-------|---------|
| `refus_acces` | "Refus" | Rouge |
| `duree_expiree` | "Expire" | Orange |

### Fonctionnalites

- Compteur de notifications non lues (`vu_agent == false`) dans le badge de l'onglet
- Marquer comme lu (individuel via `marquerCommeLu` ou tout d'un coup via `toutMarquerCommeLu`)
- Suppression avec dialog de confirmation (localise fr/ar)
- Traduction dynamique des messages serveur en arabe (via `traduireMessageNotif`)
- Badges type localises : `dureeExpiree` / `refusAcces`
- Support dark mode et RTL

---

## Bugs resolus

### 1. HTTP 415 lors de l'envoi d'une photo au AI Service
**Cause :** `http.MultipartFile.fromPath` ne definit pas le Content-Type de la partie fichier
quand l'extension du fichier temporaire Android n'est pas reconnue. FastAPI rejette alors la requete.

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
`http_parser` doit etre declare explicitement dans `pubspec.yaml` meme si c'est une dependance transitive de `http`.

### 2. "No MaterialLocalizations found" (crash sur 3 ecrans)
**Cause :** `flutter_localizations` manquait dans `pubspec.yaml` et les delegates n'etaient
pas declares dans `MaterialApp`.

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
(defaut). Quand appele depuis un event handler ou un dialog, Flutter leve une exception
car on essaie d'ecouter en dehors de l'arbre de widgets actif.

**Fix :** `Provider.of<LocaleProvider>(this, listen: false)`

### 4. Bug dispose() dans scanner_screen
**Cause :** `context.read<ScanProvider>()` dans `dispose()` est unsafe apres desactivation du widget.

**Fix :** Cacher la reference en `initState` :
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

### 5. Timeout login sur APK release (telephone physique)
**Cause :** Android 9+ bloque le trafic HTTP cleartext dans les APK release par defaut.
Le mode debug (`flutter run`) autorise le cleartext automatiquement — c'est pourquoi
le login fonctionnait en debug mais pas en release.

**Fix dans `android/app/src/main/AndroidManifest.xml` :**
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### 6. Logo overflow dans AppBar (session 2026-05-12)
**Cause :** Le widget `Image` du logo AT dans `at_header.dart` n'avait aucune contrainte de taille.
Sur certains ecrans, l'image debordait du header.

**Fix :** Envelopper l'`Image` dans un `SizedBox(height: 32)` dans `at_header.dart`.

### 7. Accents manquants dans toute l'UI (session 2026-05-12)
**Cause :** ~50 chaines utilisateur dans `app_localizations.dart`, `app_constants.dart` et
`mock_data.dart` etaient ecrites sans accents francais (ex: "Autorise" au lieu de "Autorise").

**Fix :** Correction de toutes les chaines FR avec accents corrects dans les 3 fichiers.

### 9. Scan camera : affichage incomplet pour vehicules temporaires (session 2026-05-23)
**Cause :** Trois problemes dans le pipeline scan camera pour les vehicules temporaires :
1. `_handle_temporaire()` (AI Service) retournait `"owner": None` — les champs visiteur existaient dans le cache mais n'etaient pas mappes vers `owner`.
2. Le WebSocket `/ws/detect` (AI Service) ne transmettait pas le champ `"type"` a Flutter.
3. `scanner_screen.dart` utilisait un widget generique sans distinction permanent/temporaire.

**Fix :**
- `backend.py` : construction de l'objet `owner` avec les champs visiteur du cache
- `main.py` : ajout de `"type": check.get("type")` dans le dict WebSocket
- `scanner_screen.dart` : branchement `if (r.isTemporaire)` → `TemporaireResultCard`

### 8. Layout non responsive (session 2026-05-12)
**Cause :** Dimensions fixes (width: 260, height: 200, etc.) dans les ecrans login, splash,
home, stats et scanner causaient des problemes sur petits ecrans (360px).

**Fix :** Creation de `lib/utils/responsive.dart` avec `Responsive.rw()` / `Responsive.rh()`
et remplacement de toutes les dimensions fixes critiques par des valeurs proportionnelles.

---

## Authentification — Sanctum

### Flux de connexion
```
[Ecran Login]
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
    ├─ Verifie role == "AgentSecurite" (double controle client)
    ├─ Token stocke dans SharedPreferences (cle : auth_token)
    ├─ User stocke dans SharedPreferences (cle : auth_user, JSON)
    └─ AuthStatus → authenticated → HomeScreen
```

### Persistance au redemarrage
`_AppRouter.initState` → `AuthProvider.checkAuthStatus()` :
1. Lecture token depuis SharedPreferences
2. Si token present → charge user depuis cache → HomeScreen directement
3. Si absent → LoginScreen

---

## Endpoints consommes

| Service | Methode | URL | Utilise par |
|---|---|---|---|
| Laravel | POST | `/api/login/mobile` | AuthService.login() |
| Laravel | POST | `/api/logout` | AuthService.logout() |
| Laravel | GET | `/api/me` | AuthService.fetchCurrentUser() |
| Laravel | GET | `/api/acces` | AccessService |
| Laravel | GET | `/api/notifications/agent` | NotificationService.fetchAll() |
| Laravel | PATCH | `/api/notifications/{id}/vu-agent` | NotificationService.markAsRead() |
| Laravel | PATCH | `/api/notifications/tout-vu-agent` | NotificationService.markAllAsRead() |
| Laravel | DELETE | `/api/notifications/{id}` | NotificationService.delete() |
| Laravel | PUT | `/api/utilisateurs/{id}` | AuthService.updateProfile() |
| AI Service | POST | `/scan` | ScanService.scanPhoto() |
| AI Service | POST | `/verify` | ScanService.verifyPlate() |
| AI Service | POST | `/verify-lookup` | SearchService (recherche sans enregistrement) |

---

## Dependances principales

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  http: ^1.2.2                # REST + multipart
  http_parser: ^4.0.2         # MediaType pour forcer Content-Type image/jpeg (fix 415)
  shared_preferences: ^2.3.4  # Token JWT local
  camera: ^0.11.0+2           # Camera native
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
# Verifier les devices connectes
flutter devices

# Lancer sur emulateur avec logs
flutter run

# Lancer en release sur device USB (avec logs)
flutter run --release

# Generer APK release
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# IP actuelle du Mac sur le reseau local
ifconfig | grep "inet " | grep -v 127

# Verifier que le backend Laravel est joignable
curl http://192.168.1.3:8000/api/login/mobile \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"votre@email.com","password":"motdepasse"}'

# NDK version requise (dans build.gradle.kts)
# ndkVersion = "27.0.12077973"
```
