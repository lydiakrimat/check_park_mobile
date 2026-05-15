/// Represente une notification de securite dans le systeme ALPR.
///
/// Correspond a la table "notifications" dans MySQL et au Model Notification.php dans Laravel.
/// Les notifications sont creees automatiquement par le AI Service quand :
///   - Un acces est refuse (type = 'refus_acces')
///   - Un acces temporaire expire (type = 'duree_expiree')
class NotificationModel {
  final int id;

  /// Type de notification : 'refus_acces' ou 'duree_expiree'.
  /// Permet de choisir l'icone et la couleur d'affichage.
  final String type;

  /// Titre court de la notification.
  final String titre;

  /// Message detaille.
  final String message;

  /// Plaque concernee (nullable).
  final String? plateNumber;

  /// FK vers la table "acces" (ancien champ, garde pour compatibilite).
  final int? accesId;

  /// FK vers la table "vehicules_temporaires" (nullable).
  final int? vehiculeTemporaireId;

  /// Ancien champ de lecture unique (garde pour compatibilite).
  final bool lu;

  /// Statut de lecture pour l'admin du dashboard web.
  final bool vuAdmin;

  /// Statut de lecture pour l'agent mobile.
  final bool vuAgent;

  /// Date de creation de la notification.
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    this.plateNumber,
    this.accesId,
    this.vehiculeTemporaireId,
    required this.lu,
    required this.vuAdmin,
    required this.vuAgent,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'info',
      titre: json['titre'] as String? ?? '',
      message: json['message'] as String? ?? '',
      plateNumber: json['plate_number'] as String?,
      accesId: json['acces_id'] as int?,
      vehiculeTemporaireId: json['vehicule_temporaire_id'] as int?,
      lu: json['lu'] == true || json['lu'] == 1,
      vuAdmin: json['vu_admin'] == true || json['vu_admin'] == 1,
      vuAgent: json['vu_agent'] == true || json['vu_agent'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'titre': titre,
      'message': message,
      'plate_number': plateNumber,
      'acces_id': accesId,
      'vehicule_temporaire_id': vehiculeTemporaireId,
      'lu': lu,
      'vu_admin': vuAdmin,
      'vu_agent': vuAgent,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Retourne une copie avec vu_agent = true.
  NotificationModel copyWithVuAgent() {
    return NotificationModel(
      id: id,
      type: type,
      titre: titre,
      message: message,
      plateNumber: plateNumber,
      accesId: accesId,
      vehiculeTemporaireId: vehiculeTemporaireId,
      lu: lu,
      vuAdmin: vuAdmin,
      vuAgent: true,
      createdAt: createdAt,
    );
  }

  /// Retourne une copie avec lu = true (compatibilite ancien systeme).
  NotificationModel copyWithRead() {
    return NotificationModel(
      id: id,
      type: type,
      titre: titre,
      message: message,
      plateNumber: plateNumber,
      accesId: accesId,
      vehiculeTemporaireId: vehiculeTemporaireId,
      lu: true,
      vuAdmin: vuAdmin,
      vuAgent: vuAgent,
      createdAt: createdAt,
    );
  }
}
