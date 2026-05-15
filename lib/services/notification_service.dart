import '../config/api_config.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

/// Service pour les notifications de securite (agent mobile).
///
/// Utilise les endpoints /notifications/agent avec vu_agent.
class NotificationService {
  final ApiService _api;

  const NotificationService(this._api);

  /// Recupere toutes les notifications pour l'agent.
  Future<List<NotificationModel>> fetchAll() async {
    final data = await _api.get('${ApiConfig.notificationsUrl}/agent');
    final list = data as List<dynamic>;
    return list
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Marque une notification comme vue par l'agent.
  Future<void> markAsRead(int id) async {
    await _api.patch('${ApiConfig.notificationsUrl}/$id/vu-agent', {});
  }

  /// Marque toutes les notifications comme vues par l'agent.
  Future<void> markAllAsRead() async {
    await _api.patch('${ApiConfig.notificationsUrl}/tout-vu-agent', {});
  }

  /// Supprime une notification.
  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.notificationsUrl}/$id');
  }
}
