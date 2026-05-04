/// Représente un utilisateur du système ALPR.
///
/// Correspond à la table "utilisateurs" dans MySQL et au Model Utilisateur.php dans Laravel.
/// Seuls les utilisateurs avec le role [role] == 'AgentSecurite' peuvent
/// se connecter à l'application mobile.
///
/// Roles possibles (définis dans la migration Laravel) :
///   - 'Admin'         → accès au dashboard web uniquement
///   - 'AgentSecurite' → accès à l'application mobile
///   - 'Employe'       → pas d'accès à l'app
class UserModel {
  final int id;

  /// Nom de famille (ex: "Hamidi").
  final String nom;

  /// Prénom (ex: "Yacine").
  final String prenom;

  /// Adresse email — utilisée comme identifiant de connexion.
  final String? email;

  /// Numéro de téléphone (optionnel).
  final String? telephone;

  /// Rôle de l'utilisateur : 'Admin', 'AgentSecurite', ou 'Employe'.
  final String role;

  /// Matricule professionnel (uniquement pour les Employés, null pour les agents/admins).
  final String? matriculeProfessionnel;

  /// Service/département (uniquement pour les Employés).
  final String? service;

  /// Statut du compte : 'Actif' ou 'Inactif'.
  final String statut;

  const UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.telephone,
    required this.role,
    this.matriculeProfessionnel,
    this.service,
    required this.statut,
  });

  /// Nom complet affiché dans l'interface (prénom + nom).
  String get fullName => '$prenom $nom';

  /// Initiales pour l'avatar (ex: "HY" pour "Hamidi Yacine").
  String get initials {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  /// Désérialise la réponse JSON de l'API Laravel vers un objet Dart.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      role: json['role'] as String? ?? '',
      matriculeProfessionnel: json['matriculeProfessionnel'] as String?,
      service: json['service'] as String?,
      statut: json['statut'] as String? ?? 'Actif',
    );
  }

  /// Sérialise vers JSON (utile pour mettre en cache dans SharedPreferences).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'matriculeProfessionnel': matriculeProfessionnel,
      'service': service,
      'statut': statut,
    };
  }
}
