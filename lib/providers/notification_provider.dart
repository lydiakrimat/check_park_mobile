import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

/// Provider de l'etat des notifications de securite.
///
/// Charge la liste depuis Laravel et maintient le compteur de non-vues
/// pour le badge rouge dans l'AppBar.
class NotificationProvider extends ChangeNotifier {
  NotificationService _service;

  List<NotificationModel> _notifications = [];
  bool _loading = false;
  String? _errorMessage;

  NotificationProvider(this._service);

  /// Met a jour le service sans perdre l'etat des notifications.
  /// Appele par le ChangeNotifierProxyProvider quand le token change.
  void updateService(NotificationService service) {
    _service = service;
  }

  // -- Getters --

  List<NotificationModel> get notifications => _notifications;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  /// Nombre de notifications non vues par l'agent.
  int get unreadCount => _notifications.where((n) => !n.vuAgent).length;

  // -- Chargement --

  /// Charge toutes les notifications depuis le serveur.
  Future<void> fetch() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _service.fetchAll();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Erreur lors du chargement des notifications.';
    }

    _loading = false;
    notifyListeners();
  }

  // -- Actions --

  /// Marque une notification comme vue par l'agent (mise a jour locale + appel API).
  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      // Mise a jour optimiste de la liste locale pour une UI reactive.
      _notifications = _notifications.map((n) {
        return n.id == id ? n.copyWithVuAgent() : n;
      }).toList();
      notifyListeners();
    } on ApiException catch (_) {
      // Silencieux — la prochaine synchronisation corrigera l'etat.
    }
  }

  /// Marque toutes les notifications comme vues par l'agent.
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWithVuAgent()).toList();
      notifyListeners();
    } on ApiException catch (_) {}
  }

  /// Supprime une notification de la liste.
  Future<void> delete(int id) async {
    try {
      await _service.delete(id);
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } on ApiException catch (_) {}
  }
}
