/// Représente une notification de sécurité dans le système ALPR.
///
/// Correspond à la table "notifications" dans MySQL et au Model Notification.php dans Laravel.
/// Les notifications sont créées automatiquement par le backend Laravel quand :
///   - Un accès temporaire expire (type = 'acces_expire')
///   - Un accès est refusé (type = 'acces_refuse')
class NotificationModel {
  final int id;

  /// Type de notification (ex: 'acces_expire', 'acces_refuse').
  /// Permet de choisir l'icône et la couleur d'affichage.
  final String type;

  /// Titre court de la notification (ex: "Accès expiré").
  final String titre;

  /// Message détaillé (ex: "L'accès du véhicule ALG288 a expiré.").
  final String message;

  /// FK vers la table "acces" — permet de naviguer vers l'accès concerné.
  final int? accesId;

  /// false = non lue (badge rouge dans l'app), true = déjà consultée.
  final bool lu;

  /// Date de création de la notification.
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    this.accesId,
    required this.lu,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'info',
      titre: json['titre'] as String? ?? '',
      message: json['message'] as String? ?? '',
      accesId: json['acces_id'] as int?,
      lu: json['lu'] == true || json['lu'] == 1,
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
      'acces_id': accesId,
      'lu': lu,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Retourne une copie de l'objet avec [lu] = true.
  NotificationModel copyWithRead() {
    return NotificationModel(
      id: id,
      type: type,
      titre: titre,
      message: message,
      accesId: accesId,
      lu: true,
      createdAt: createdAt,
    );
  }
}
