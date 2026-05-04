import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../config/app_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Service d'authentification JWT via Laravel Sanctum.
///
/// Gère le cycle de vie complet de la session de l'agent :
///   - Login : envoie les credentials, reçoit le token, le stocke localement
///   - Logout : révoque le token côté serveur, supprime le stockage local
///   - Persistance : recharge le token et le user au redémarrage de l'app
///
/// RÈGLE MÉTIER : Seuls les utilisateurs avec role == 'AgentSecurite' peuvent
/// se connecter à l'application mobile. Tout autre rôle est rejeté côté client.
///
/// NOTE BACKEND : Ce service requiert que le backend Laravel expose :
///   POST /api/login  → { email, password } → { token, user }
///   POST /api/logout → (auth:sanctum) → 200 OK
///   GET  /api/me     → (auth:sanctum) → { user }
class AuthService {
  SharedPreferences? _prefs;

  /// Initialise SharedPreferences (à appeler une seule fois au démarrage).
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ── Accès au token stocké ──────────────────────────────────────────────────

  /// Retourne le token JWT stocké, ou null si non connecté.
  /// Cette méthode est passée à [ApiService] comme callback [getToken].
  String? getStoredToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  /// Retourne true si un token est présent en local (session active).
  bool get isLoggedIn => getStoredToken() != null;

  // ── User en cache ──────────────────────────────────────────────────────────

  /// Retourne l'utilisateur connecté depuis le cache local (SharedPreferences).
  /// Null si non connecté ou si le cache est vide.
  UserModel? getCachedUser() {
    final json = _prefs?.getString(AppConstants.userKey);
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Authentifie l'agent avec son email et mot de passe.
  ///
  /// Étapes :
  ///   1. POST /api/login avec { email, password }
  ///   2. Vérifie que le rôle retourné est bien 'AgentSecurite'
  ///   3. Stocke le token et le user dans SharedPreferences
  ///   4. Retourne le [UserModel] de l'agent connecté
  ///
  /// Lance une [ApiException] si les credentials sont invalides, le serveur
  /// inaccessible, ou si le rôle n'est pas 'AgentSecurite'.
  Future<UserModel> login(String email, String password) async {
    await init();

    // On crée un ApiService sans token pour l'appel de login (pas encore connecté).
    final api = ApiService(getToken: () => null);

    final dynamic rawResponse;
    try {
      rawResponse = await api.post(ApiConfig.loginUrl, {
        'email': email.trim(),
        'password': password,
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        throw const ApiException('Email ou mot de passe incorrect.');
      }
      if (e.statusCode == 403) {
        throw const ApiException(
          'Acces reserve aux agents de securite.\n'
          'Veuillez contacter votre administrateur.',
        );
      }
      // Erreur reseau, timeout, 500... on remonte telle quelle.
      rethrow;
    }

    final response = rawResponse;

    // Le backend retourne { "token": "...", "user": { ... } }
    final token = response['token'] as String?;
    final userData = response['user'] as Map<String, dynamic>?;

    if (token == null || userData == null) {
      throw const ApiException('Réponse du serveur invalide.');
    }

    final user = UserModel.fromJson(userData);

    // RÈGLE MÉTIER : vérification du rôle côté client en double sécurité.
    // Le backend devrait déjà refuser, mais on vérifie aussi côté app.
    if (user.role != AppConstants.agentRole) {
      throw const ApiException(
        'Accès réservé aux agents de sécurité.\n'
        'Veuillez contacter votre administrateur.',
      );
    }

    // Persistance locale du token et des infos user.
    await _prefs!.setString(AppConstants.tokenKey, token);
    await _prefs!.setString(AppConstants.userKey, jsonEncode(user.toJson()));

    return user;
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  /// Déconnecte l'agent : révoque le token côté serveur et supprime le cache local.
  ///
  /// Si le serveur est inaccessible, on supprime quand même le cache local
  /// (l'agent sera déconnecté de l'app même sans confirmation serveur).
  Future<void> logout() async {
    await init();
    final token = getStoredToken();

    if (token != null) {
      try {
        // On tente de révoquer le token côté Laravel.
        final api = ApiService(getToken: getStoredToken);
        await api.post(ApiConfig.logoutUrl, {});
      } catch (_) {
        // Si le serveur est injoignable, on ignore l'erreur et on supprime quand même en local.
      }
    }

    // Nettoyage local dans tous les cas.
    await _prefs!.remove(AppConstants.tokenKey);
    await _prefs!.remove(AppConstants.userKey);
  }

  // ── Récupération du user depuis le serveur ─────────────────────────────────

  /// Récupère les infos à jour de l'utilisateur connecté depuis le serveur.
  /// Met à jour le cache local avec les nouvelles données.
  Future<UserModel?> fetchCurrentUser() async {
    await init();
    if (!isLoggedIn) return null;

    try {
      final api = ApiService(getToken: getStoredToken);
      final data = await api.get(ApiConfig.meUrl);
      final user = UserModel.fromJson(data as Map<String, dynamic>);
      await _prefs!.setString(AppConstants.userKey, jsonEncode(user.toJson()));
      return user;
    } catch (_) {
      // En cas d'erreur, retourner le cache local.
      return getCachedUser();
    }
  }
}
