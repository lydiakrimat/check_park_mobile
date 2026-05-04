import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

/// Provider de l'état des notifications de sécurité.
///
/// Charge la liste depuis Laravel et maintient le compteur de non-lues
/// pour le badge rouge dans la BottomNavigationBar.
class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  List<NotificationModel> _notifications = [];
  bool _loading = false;
  String? _errorMessage;

  NotificationProvider(this._service);

  // ── Getters ────────────────────────────────────────────────────────────────

  List<NotificationModel> get notifications => _notifications;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  /// Nombre de notifications non lues — affiché dans le badge de la cloche.
  int get unreadCount => _notifications.where((n) => !n.lu).length;

  // ── Chargement ─────────────────────────────────────────────────────────────

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

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Marque une notification comme lue (mise à jour locale + appel API).
  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      // Mise à jour optimiste de la liste locale pour une UI réactive.
      _notifications = _notifications.map((n) {
        return n.id == id ? n.copyWithRead() : n;
      }).toList();
      notifyListeners();
    } on ApiException catch (_) {
      // Silencieux — la prochaine synchronisation corrigera l'état.
    }
  }

  /// Marque toutes les notifications comme lues.
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWithRead()).toList();
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
