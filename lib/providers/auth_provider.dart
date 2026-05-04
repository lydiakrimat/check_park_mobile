import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

/// État possible du processus d'authentification.
enum AuthStatus {
  /// Vérification en cours au démarrage de l'app (lecture du token local).
  checking,
  /// Aucun token valide — l'écran de login est affiché.
  unauthenticated,
  /// Token présent et valide — l'app principale est accessible.
  authenticated,
}

/// Provider de l'état d'authentification de l'agent.
///
/// C'est le provider central de l'application. Il est initialisé au démarrage
/// dans [main.dart] et écouté par [app.dart] pour router vers Login ou HomeScreen.
///
/// Toutes les modifications d'état passent par ce provider :
///   - login()  → transition unauthenticated → authenticated
///   - logout() → transition authenticated → unauthenticated
///
/// Accessible depuis n'importe quel écran via :
///   context.read() ou context.watch() sur AuthProvider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.checking;
  UserModel? _user;
  String? _errorMessage;

  AuthProvider(this._authService);

  // ── Getters publics ────────────────────────────────────────────────────────

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.checking;

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Vérifie au démarrage de l'app si un token est déjà stocké localement.
  /// Si oui, charge le user depuis le cache et passe à l'état [authenticated].
  Future<void> checkAuthStatus() async {
    await _authService.init();
    if (_authService.isLoggedIn) {
      _user = _authService.getCachedUser();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Tente de connecter l'agent avec ses credentials.
  ///
  /// Met à jour [status] et [errorMessage] en fonction du résultat.
  /// Retourne true si le login a réussi, false sinon.
  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Une erreur inattendue s\'est produite.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  /// Déconnecte l'agent et réinitialise l'état.
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Accès au token (pour les autres services) ──────────────────────────────

  /// Retourne le token JWT stocké — utilisé par [ApiService] comme callback getToken.
  String? getToken() => _authService.getStoredToken();
}
