// Constantes globales de l'application mobile
// Regroupe les seuils, durées et valeurs fixes utilisés
// à plusieurs endroits dans l'application.

class AppConstants {
  AppConstants._();

  // ── Authentification ───────────────────────────────────────────────────────
  // Clé sous laquelle le token JWT est stocké dans SharedPreferences.
  static const String tokenKey    = 'auth_token';
  // Clé sous laquelle les données du user connecté sont stockées (JSON string).
  static const String userKey     = 'auth_user';
  // Seul ce rôle peut se connecter sur l'application mobile.
  static const String agentRole   = 'AgentSecurite';

  // ── Scanner ────────────────────────────────────────────────────────────────
  // Seuil minimal de score de confiance YOLOX pour qu'une détection soit
  // considérée comme valide (ex: 0.5 = 50% de certitude minimum).
  static const double minConfidence      = 0.5;
  // Seuil de similarité fuzzy matching (0.0 à 1.0).
  // Si le score est >= 0.8, on considère que la plaque a bien été reconnue.
  static const double minSimilarityScore = 0.8;

  // ── Pagination ─────────────────────────────────────────────────────────────
  // Nombre d'entrées chargées par page dans l'historique.
  static const int historyPageSize = 20;

  // ── Formats d'affichage ────────────────────────────────────────────────────
  static const String dateDisplayFormat    = 'dd/MM/yyyy';
  static const String datetimeDisplayFormat = 'dd/MM/yyyy HH:mm';

  // ── Messages d'erreur communs ──────────────────────────────────────────────
  static const String erreurReseau   = 'Impossible de joindre le serveur. Verifiez votre connexion.';
  static const String erreurTimeout  = 'Le serveur met trop de temps a repondre. Reessayez.';
  static const String erreurServeur  = 'Une erreur s\'est produite cote serveur.';
  static const String erreurInconnu  = 'Une erreur inattendue s\'est produite.';
  // Specifique au AI Service — different du backend Laravel.
  static const String erreurServiceIA =
      'Impossible de joindre le service IA. '
      'Verifiez que FastAPI est demarre sur le Mac (port 8080) '
      'et que le telephone est sur le meme reseau Wi-Fi.';
}
