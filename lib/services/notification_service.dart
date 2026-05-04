import '../config/api_config.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

/// Service pour les notifications de sécurité.
///
/// Correspond à NotificationController.php dans Laravel.
class NotificationService {
  final ApiService _api;

  const NotificationService(this._api);

  /// Récupère toutes les notifications (max 50, triées par date décroissante).
  Future<List<NotificationModel>> fetchAll() async {
    final data = await _api.get(ApiConfig.notificationsUrl);
    final list = data as List<dynamic>;
    return list
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Récupère les notifications non lues avec leur compteur.
  /// Retourne une Map avec les clés 'count' (int) et 'notifications' (liste).
  Future<Map<String, dynamic>> fetchUnread() async {
    final data = await _api.get('${ApiConfig.notificationsUrl}/non-lues');
    final count = data['count'] as int? ?? 0;
    final list = (data['notifications'] as List<dynamic>? ?? [])
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return {'count': count, 'notifications': list};
  }

  /// Marque une notification comme lue.
  Future<void> markAsRead(int id) async {
    await _api.put('${ApiConfig.notificationsUrl}/$id/lire', {});
  }

  /// Marque toutes les notifications comme lues.
  Future<void> markAllAsRead() async {
    await _api.put('${ApiConfig.notificationsUrl}/lire-tout', {});
  }

  /// Supprime une notification.
  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.notificationsUrl}/$id');
  }
}
