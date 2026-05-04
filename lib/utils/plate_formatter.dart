/// Utilitaires de formatage des numéros de plaque algérienne.
class PlateFormatter {
  PlateFormatter._();

  /// Normalise une plaque pour la comparer ou l'envoyer à l'API :
  /// supprime les espaces et met en majuscules.
  /// Ex: "alg 288" → "ALG288"
  static String normalize(String plate) {
    return plate.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  /// Formate une plaque pour l'affichage dans l'UI.
  /// Pour l'instant retourne la plaque telle quelle (déjà normalisée en BDD).
  static String display(String? plate) {
    if (plate == null || plate.isEmpty) return '--';
    return plate.toUpperCase();
  }
}
