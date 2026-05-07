import 'package:flutter/foundation.dart';
import '../models/access_record.dart';
import '../services/daily_counter_service.dart';
import '../services/statistics_service.dart';

/// Provider des statistiques d'acces.
///
/// Combine deux sources de donnees :
///   1. Compteurs quotidiens depuis SharedPreferences ([DailyCounterService])
///      → affiches dans les 3 cartes KPI de l'ecran Statistiques
///   2. Statistiques calculees a partir des enregistrements d'historique
///      → alimentent tous les charts (PieChart, BarCharts, Top 5, etc.)
class StatisticsProvider extends ChangeNotifier {
  final StatisticsService _service;

  StatsData? _stats;
  int _dailyScans     = 0;
  int _dailyAutorises = 0;
  int _dailyRefuses   = 0;

  StatisticsProvider(this._service);

  // ── Getters ────────────────────────────────────────────────────────────────

  StatsData? get stats         => _stats;

  /// Nombre total de scans camera + recherches manuelles du jour.
  int get dailyScans           => _dailyScans;

  /// Nombre d'acces autorises enregistres aujourd'hui.
  int get dailyAutorises       => _dailyAutorises;

  /// Nombre d'acces refuses enregistres aujourd'hui.
  int get dailyRefuses         => _dailyRefuses;

  // ── Compteurs quotidiens ───────────────────────────────────────────────────

  /// Charge les compteurs quotidiens depuis SharedPreferences.
  /// A appeler dans initState de l'ecran Statistiques.
  Future<void> loadCounters() async {
    final c = await DailyCounterService.getCounters();
    _dailyScans     = c.scans;
    _dailyAutorises = c.autorises;
    _dailyRefuses   = c.refuses;
    notifyListeners();
  }

  // ── Calcul des statistiques depuis l'historique ────────────────────────────

  /// Recalcule toutes les statistiques a partir de la liste d'acces fournie.
  /// Appele par l'ecran Statistiques apres le chargement de l'historique.
  void compute(List<AccessRecord> records) {
    _stats = _service.compute(records);
    notifyListeners();
  }
}
