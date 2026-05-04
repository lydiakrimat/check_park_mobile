/// Représente un employé d'Algérie Télécom enregistré dans le système RH.
///
/// Correspond à la table "employes" dans MySQL et au Model Employe.php dans Laravel.
///
/// IMPORTANT : Cette table est distincte de "utilisateurs".
///   - "employes" = base RH (qui a un véhicule enregistré)
///   - "utilisateurs" = comptes de connexion (agents, admins)
/// Les véhicules et les accès référencent la table "employes" (via employee_id / employe_id).
class Employee {
  final int id;

  /// Nom de famille.
  final String nom;

  /// Prénom.
  final String prenom;

  /// Matricule professionnel unique (ex: "AT-2019-001").
  final String matriculeProfessionnel;

  /// Service/département de l'employé (ex: "Systèmes d'Information").
  final String service;

  /// Statut du contrat : 'Actif' ou 'Inactif'.
  final String statut;

  const Employee({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.matriculeProfessionnel,
    required this.service,
    required this.statut,
  });

  /// Nom complet (prénom + nom).
  String get fullName => '$prenom $nom';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      matriculeProfessionnel: json['matriculeProfessionnel'] as String? ?? '',
      service: json['service'] as String? ?? '',
      statut: json['statut'] as String? ?? 'Actif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'matriculeProfessionnel': matriculeProfessionnel,
      'service': service,
      'statut': statut,
    };
  }
}
