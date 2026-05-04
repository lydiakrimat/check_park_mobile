/// Fonctions de validation pour les champs de formulaires.
class Validators {
  Validators._();

  /// Valide une adresse email.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est obligatoire';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Adresse email invalide';
    return null;
  }

  /// Valide un mot de passe (min 6 caractères, correspond au minimum Laravel).
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est obligatoire';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  /// Valide qu'un champ n'est pas vide.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est obligatoire';
    }
    return null;
  }

  /// Valide un numéro de plaque algérienne (non vide, longueur raisonnable).
  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Numéro de plaque obligatoire';
    if (value.trim().length < 3) return 'Plaque trop courte';
    return null;
  }
}
