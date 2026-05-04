# Check Park Mobile — Application Flutter ALPR

Application mobile de contrôle des immatriculations de véhicules pour les agents de sécurité d'Algérie Télécom.
Développée avec Flutter, elle communique avec deux backends : le **backend Laravel** (gestion des données) et le **AI Service FastAPI** (pipeline de reconnaissance de plaques).

---

## Stack technique

- **Framework** : Flutter (Dart)
- **State management** : Provider (`ChangeNotifier` / `ChangeNotifierProxyProvider`)
- **HTTP** : package `http` (REST + multipart)
- **Stockage local** : `shared_preferences` (token JWT)
- **Caméra** : package `camera` (capture photo native)
- **Polices** : Google Fonts — Plus Jakarta Sans

---

## Lancement

```bash
flutter pub get
flutter run                   # émulateur Android ou iPhone connecté
flutter run --release         # build de production
```

> Vérifier que `_host` dans `lib/config/api_config.dart` correspond à votre configuration :
> - Émulateur Android : `10.0.2.2` (alias de localhost de la machine hôte)
> - Vrai téléphone (même WiFi) : IP locale du PC (ex : `192.168.1.42`)

---

## Architecture

```
lib/
├── config/
│   ├── api_config.dart         URLs et timeouts (Laravel :8000, AI Service :8080)
│   └── app_constants.dart      Clés SharedPreferences, rôle AgentSecurite, seuils
├── models/
│   ├── user.dart               UserModel — miroir de la table utilisateurs
│   ├── employee.dart           Employee — miroir de la table employes
│   ├── vehicle.dart            Vehicle — avec relation employe eager-loaded
│   ├── access_record.dart      AccessRecord — miroir de la table acces
│   ├── notification_model.dart NotificationModel — miroir de la table notifications
│   └── scan_result.dart        ScanResult — réponse du AI Service (pas de table BDD)
├── services/
│   ├── api_service.dart        Client HTTP générique (injecte le token Bearer)
│   ├── auth_service.dart       Login / logout / stockage token (SharedPreferences)
│   ├── scan_service.dart       POST /scan (photo) et POST /verify (texte) → AI Service
│   ├── camera_service.dart     Initialisation caméra, capture photo (package camera)
│   ├── access_service.dart     GET /api/acces → Laravel
│   ├── notification_service.dart GET/PUT/DELETE /api/notifications → Laravel
│   └── statistics_service.dart Calcul des KPIs localement (pas d'appel réseau)
├── providers/
│   ├── auth_provider.dart      AuthStatus {checking, unauthenticated, authenticated}
│   ├── scan_provider.dart      ScanStatus {idle, capturing, sending, done, error}
│   ├── history_provider.dart   Liste + filtres (search, statut) des accès
│   ├── notification_provider.dart Liste + compteur non lus
│   └── statistics_provider.dart  KPIs calculés à partir de history_provider
├── screens/                    9 écrans (splash, login, home, scanner, search,
│                               history, notifications, stats, settings)
├── widgets/
│   ├── access_card.dart        Carte d'un enregistrement d'accès
│   └── notification_card.dart  Carte d'une notification
├── utils/
│   ├── validators.dart         Validation email, mot de passe, plaque
│   ├── date_formatter.dart     Formatage dates (date, datetime, time, relative)
│   └── plate_formatter.dart    Normalisation et affichage des plaques
├── theme/
│   └── app_colors.dart         Palette de couleurs
├── app.dart                    ALPRApp + _AppRouter (routing basé sur AuthStatus)
└── main.dart                   Point d'entrée — MultiProvider + orientations
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
    │  POST /api/login  →  Backend Laravel
    │  { "email": "...", "password": "..." }
    │
    │  ← { "token": "1|abc...", "user": { ... } }
    │
    ├─ Token stocké dans SharedPreferences (clé : auth_token)
    ├─ User stocké dans SharedPreferences (clé : auth_user, JSON)
    └─ AuthStatus passe à `authenticated`
           │
           ▼
    _AppRouter (app.dart) détecte le changement → navigue vers HomeScreen
```

### Filtre par rôle

Seuls les comptes avec `role == "AgentSecurite"` peuvent se connecter.
- Si le rôle est différent, le backend retourne **403** et l'`AuthService` lance une exception avec le message `"Accès réservé aux agents de sécurité."`
- Ce contrôle est effectué **côté backend** (Laravel) avant d'émettre le token

### Persistance du token au redémarrage

Au démarrage de l'application (`_AppRouter.initState`), `AuthProvider.checkAuthStatus()` est appelé :
1. Lecture du token depuis `SharedPreferences`
2. Si token présent → `GET /api/me` pour valider que le token est toujours actif
3. Si valide → `AuthStatus.authenticated` → HomeScreen directement (pas de login)
4. Si invalide (token révoqué) → `AuthStatus.unauthenticated` → LoginScreen

### Déconnexion

```
AuthProvider.logout()
    │  POST /api/logout  →  Laravel (révoque le token en BDD)
    │  Header: Authorization: Bearer <token>
    │
    ├─ Token supprimé de SharedPreferences
    └─ AuthStatus passe à `unauthenticated` → LoginScreen
```

### Injection automatique du token

`ApiService` ajoute automatiquement le header `Authorization: Bearer <token>` sur toutes les requêtes vers Laravel (historique, notifications, etc.) :

```dart
// lib/services/api_service.dart
headers: {
  'Content-Type': 'application/json',
  if (token != null) 'Authorization': 'Bearer $token',
}
```

---

## Flux de scan — photo vers AI Service

La photo capturée est envoyée **directement au AI Service**, sans passer par Laravel.

```
[Écran Scanner]
    │  Bouton "Scanner"
    ▼
ScanProvider.captureAndScan()
    │
    ├─ CameraService.takePhoto()  →  Fichier image JPEG local
    │
    └─ ScanService.scanPhoto(file)
           │  POST /scan  →  AI Service FastAPI :8080
           │  multipart/form-data  { "image": <fichier JPEG> }
           │
           │  Pipeline IA :
           │    1. YOLOX      — détection bounding box de la plaque
           │    2. PaddleOCR  — lecture des caractères (crop de la plaque)
           │    3. Fuzzy matching — comparaison avec la BDD (seuil 80%)
           │    4. Laravel    — vérification des droits d'accès
           │
           │  ← ScanResult JSON
           │    { detected, plate_ocr, plate_matched, similarity_score,
           │      authorized, reason, confidence, bounding_box,
           │      vehicle: { ... }, owner: { ... } }
           ▼
    ScanProvider.result  →  Écran affiche le résultat
```

**Recherche manuelle (écran Recherche) :**
```
ScanService.verifyPlate(plateText)
    │  POST /verify  →  AI Service :8080
    │  { "plate_text": "ALG288" }
    └─ même format de réponse ScanResult
```

Le AI Service est le seul à interroger Laravel pour la vérification des droits. L'app mobile ne contacte pas directement Laravel pour les scans.

---

## Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`) :
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS** (`ios/Runner/Info.plist`) :
```xml
<key>NSCameraUsageDescription</key>
<string>L'accès à la caméra est nécessaire pour photographier et analyser les plaques d'immatriculation des véhicules.</string>
```

---

## Dépendances principales

```yaml
# pubspec.yaml
http: ^1.2.2                # Requêtes HTTP REST + multipart
shared_preferences: ^2.3.4  # Stockage local du token
camera: ^0.11.0+2           # Accès caméra native
provider: ^6.1.2            # State management
google_fonts: ^6.0.0        # Typographie Plus Jakarta Sans
```

---

## Endpoints consommés

| Service | Méthode | URL | Utilisé par |
|---|---|---|---|
| Laravel | POST | `/api/login` | AuthService.login() |
| Laravel | POST | `/api/logout` | AuthService.logout() |
| Laravel | GET | `/api/me` | AuthService.fetchCurrentUser() |
| Laravel | GET | `/api/acces` | AccessService.fetchAll() |
| Laravel | GET | `/api/notifications` | NotificationService.fetchAll() |
| Laravel | GET | `/api/notifications/non-lues` | NotificationService.fetchUnread() |
| Laravel | PUT | `/api/notifications/{id}/lire` | NotificationService.markAsRead() |
| Laravel | PUT | `/api/notifications/lire-tout` | NotificationService.markAllAsRead() |
| Laravel | DELETE | `/api/notifications/{id}` | NotificationService.delete() |
| AI Service | POST | `/scan` | ScanService.scanPhoto() |
| AI Service | POST | `/verify` | ScanService.verifyPlate() |
