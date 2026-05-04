import 'package:flutter/foundation.dart';
import '../models/access_record.dart';
import '../services/statistics_service.dart';

/// Provider des statistiques d'accès.
///
/// Les statistiques sont calculées localement par [StatisticsService]
/// à partir de la liste d'accès fournie par [HistoryProvider].
/// Ce provider est rafraîchi chaque fois que l'historique change.
class StatisticsProvider extends ChangeNotifier {
  final StatisticsService _service;

  StatsData? _stats;

  StatisticsProvider(this._service);

  // ── Getters ────────────────────────────────────────────────────────────────

  StatsData? get stats => _stats;

  // ── Calcul ─────────────────────────────────────────────────────────────────

  /// Recalcule les statistiques à partir de la liste d'accès fournie.
  /// Appelé par l'écran Stats quand l'historique est mis à jour.
  void compute(List<AccessRecord> records) {
    _stats = _service.compute(records);
    notifyListeners();
  }
}
