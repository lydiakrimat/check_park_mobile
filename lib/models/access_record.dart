import 'employee.dart';
import 'vehicle.dart';

/// Représente un enregistrement d'accès (entrée/sortie d'un véhicule).
///
/// Correspond à la table "acces" dans MySQL et au Model Acces.php dans Laravel.
///
/// Deux types d'accès :
///   - 'Permanent'  : employé avec son propre véhicule enregistré
///   - 'Temporaire' : visiteur externe, avec durée limitée et plaque saisie manuellement
///
/// Trois statuts possibles :
///   - 'Autorise' : accès accordé, toujours en cours ou terminé normalement
///   - 'Refuse'   : accès refusé (véhicule non autorisé)
///   - 'Expire'   : accès temporaire dont la durée a expiré
class AccessRecord {
  final int id;

  /// Type d'accès : 'Permanent' ou 'Temporaire'.
  final String typeAcces;

  /// FK vers la table "employes" — null pour les visiteurs.
  final int? employeId;

  /// FK vers la table "vehicles" — null pour les visiteurs.
  final int? vehicleId;

  // ── Champs visiteur (uniquement pour typeAcces = 'Temporaire') ─────────────
  final String? nomVisiteur;
  final String? prenomVisiteur;
  final String? telephoneVisiteur;

  /// Plaque du visiteur saisie manuellement (non référencée en BDD vehicles).
  final String? plateNumberVisiteur;

  /// Durée d'autorisation en minutes (ex: 60 = 1 heure). Null pour Permanent.
  final int? dureeAutorisee;

  // ── Dates ──────────────────────────────────────────────────────────────────
  /// Date et heure d'entrée sur le site.
  final DateTime? dateHeureEntree;

  /// Date et heure de sortie du site. Null si l'accès est encore actif.
  final DateTime? dateHeureSortie;

  /// Statut courant : 'Autorise', 'Refuse', ou 'Expire'.
  final String statut;

  // ── Relations chargées par Laravel (eager loading) ─────────────────────────
  /// Employé propriétaire du véhicule (si typeAcces = 'Permanent').
  final Employee? employe;

  /// Véhicule concerné (si typeAcces = 'Permanent').
  /// Inclut lui-même la relation employe (Vehicle::with('employe')).
  final Vehicle? vehicle;

  const AccessRecord({
    required this.id,
    required this.typeAcces,
    this.employeId,
    this.vehicleId,
    this.nomVisiteur,
    this.prenomVisiteur,
    this.telephoneVisiteur,
    this.plateNumberVisiteur,
    this.dureeAutorisee,
    this.dateHeureEntree,
    this.dateHeureSortie,
    required this.statut,
    this.employe,
    this.vehicle,
  });

  /// Numéro de plaque à afficher — prend le numéro BDD si Permanent,
  /// sinon la plaque saisie manuellement pour le visiteur.
  String get displayPlate {
    return vehicle?.plateNumber ?? plateNumberVisiteur ?? '';
  }

  /// Nom complet de la personne concernée — employé ou visiteur.
  String get displayName {
    if (employe != null) return employe!.fullName;
    if (vehicle?.employe != null) return vehicle!.employe!.fullName;
    final p = prenomVisiteur ?? '';
    final n = nomVisiteur ?? '';
    return '$p $n'.trim().isNotEmpty ? '$p $n'.trim() : 'Visiteur';
  }

  /// Initiales pour l'avatar.
  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory AccessRecord.fromJson(Map<String, dynamic> json) {
    return AccessRecord(
      id: json['id'] as int,
      typeAcces: json['type_acces'] as String? ?? 'Permanent',
      employeId: json['employe_id'] as int?,
      vehicleId: json['vehicle_id'] as int?,
      nomVisiteur: json['nom_visiteur'] as String?,
      prenomVisiteur: json['prenom_visiteur'] as String?,
      telephoneVisiteur: json['telephone_visiteur'] as String?,
      plateNumberVisiteur: json['plate_number_visiteur'] as String?,
      dureeAutorisee: json['duree_autorisee'] as int?,
      dateHeureEntree: json['dateHeureEntree'] != null
          ? DateTime.tryParse(json['dateHeureEntree'] as String)
          : null,
      dateHeureSortie: json['dateHeureSortie'] != null
          ? DateTime.tryParse(json['dateHeureSortie'] as String)
          : null,
      statut: json['statut'] as String? ?? 'Autorise',
      employe: json['employe'] != null
          ? Employee.fromJson(json['employe'] as Map<String, dynamic>)
          : null,
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_acces': typeAcces,
      'employe_id': employeId,
      'vehicle_id': vehicleId,
      'nom_visiteur': nomVisiteur,
      'prenom_visiteur': prenomVisiteur,
      'telephone_visiteur': telephoneVisiteur,
      'plate_number_visiteur': plateNumberVisiteur,
      'duree_autorisee': dureeAutorisee,
      'dateHeureEntree': dateHeureEntree?.toIso8601String(),
      'dateHeureSortie': dateHeureSortie?.toIso8601String(),
      'statut': statut,
    };
  }
}
