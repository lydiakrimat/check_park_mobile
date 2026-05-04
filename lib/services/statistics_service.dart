import '../models/access_record.dart';

/// Service de calcul des statistiques d'accès.
///
/// Il n'existe pas d'endpoint /api/statistics dans le backend Laravel,
/// donc les statistiques sont calculées côté Flutter à partir des données
/// d'historique déjà chargées par [AccessService].
///
/// Cela évite un appel réseau supplémentaire et garde le backend simple.
class StatisticsService {
  /// Calcule les statistiques à partir d'une liste d'accès.
  ///
  /// Retourne une [StatsData] avec :
  ///   - Nombre total de scans
  ///   - Nombre d'accès autorisés
  ///   - Nombre d'accès refusés
  ///   - Nombre d'accès expirés
  ///   - Répartition par statut en pourcentage
  ///   - Scans des 7 derniers jours (pour le graphique en barres)
  StatsData compute(List<AccessRecord> records) {
    final total = records.length;
    final autorises = records.where((r) => r.statut == 'Autorise').length;
    final refuses = records.where((r) => r.statut == 'Refuse').length;
    final expires = records.where((r) => r.statut == 'Expire').length;

    // Pourcentages pour le PieChart (arrondi à l'entier).
    final double pctAutorise = total > 0 ? (autorises / total * 100) : 0;
    final double pctRefuse   = total > 0 ? ((refuses + expires) / total * 100) : 0;

    // Scans des 7 derniers jours — pour le graphique en barres.
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final count = records.where((r) {
        final d = r.dateHeureEntree;
        return d != null &&
            d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;
      }).length;
      return DayStat(
        day: day,
        count: count,
      );
    });

    return StatsData(
      total: total,
      autorises: autorises,
      refuses: refuses,
      expires: expires,
      pctAutorise: pctAutorise,
      pctRefuse: pctRefuse,
      last7Days: last7Days,
    );
  }
}

/// Conteneur des statistiques calculées.
class StatsData {
  final int total;
  final int autorises;
  final int refuses;
  final int expires;

  /// Pourcentage d'accès autorisés (0-100).
  final double pctAutorise;

  /// Pourcentage d'accès refusés ou expirés (0-100).
  final double pctRefuse;

  /// Scans jour par jour sur les 7 derniers jours.
  final List<DayStat> last7Days;

  const StatsData({
    required this.total,
    required this.autorises,
    required this.refuses,
    required this.expires,
    required this.pctAutorise,
    required this.pctRefuse,
    required this.last7Days,
  });
}

/// Nombre de scans pour un jour donné.
class DayStat {
  final DateTime day;
  final int count;

  const DayStat({required this.day, required this.count});

  /// Abréviation du jour pour l'affichage (ex: "Lun", "Mar").
  String get label {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    // weekday : 1=Lundi, 7=Dimanche
    return days[day.weekday - 1];
  }
}
