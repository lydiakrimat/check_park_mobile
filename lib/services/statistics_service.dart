import '../models/access_record.dart';

/// Service de calcul des statistiques d'acces.
///
/// Toutes les agregations sont calculees cote Flutter a partir de la liste
/// d'acces chargee par [AccessService]. Un seul appel API suffit pour
/// alimenter tous les charts de l'ecran statistiques.
class StatisticsService {
  /// Calcule l'ensemble des statistiques a partir d'une liste d'acces.
  StatsData compute(List<AccessRecord> records) {
    final total     = records.length;
    final autorises = records.where((r) => r.statut == 'Autorise').length;
    final refuses   = records.where((r) => r.statut == 'Refuse').length;
    final expires   = records.where((r) => r.statut == 'Expire').length;

    // Pourcentages globaux (toutes periodes) pour retro-compatibilite.
    final double pctAutorise =
        total > 0 ? (autorises / total * 100) : 0;
    final double pctRefuse =
        total > 0 ? ((refuses + expires) / total * 100) : 0;

    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ── Compteurs d'aujourd'hui (pour le PieChart journalier) ──────────────
    final todayRecords = records.where((r) {
      final d = r.dateHeureEntree;
      return d != null &&
          DateTime(d.year, d.month, d.day) == today;
    }).toList();

    final todayAutorise =
        todayRecords.where((r) => r.statut == 'Autorise').length;
    final todayRefuse   = todayRecords
        .where((r) => r.statut == 'Refuse' || r.statut == 'Expire')
        .length;

    // ── Scans des 7 derniers jours — total par jour (chart en barres) ───────
    final last7Days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final count = records.where((r) {
        final d = r.dateHeureEntree;
        return d != null &&
            d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;
      }).length;
      return DayStat(day: day, count: count);
    });

    // ── Distribution horaire sur les 7 derniers jours ───────────────────────
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    final records7 = records.where((r) {
      final d = r.dateHeureEntree;
      return d != null &&
          !DateTime(d.year, d.month, d.day).isBefore(sevenDaysAgo);
    }).toList();

    final hourlyDistribution = List<int>.filled(24, 0);
    for (final r in records7) {
      if (r.dateHeureEntree != null) {
        hourlyDistribution[r.dateHeureEntree!.hour]++;
      }
    }

    // ── Top 5 vehicules les plus frequents (tous enregistrements) ───────────
    final Map<String, int> plateCounts = {};
    for (final r in records) {
      final plate = r.displayPlate;
      if (plate.isNotEmpty) {
        plateCounts[plate] = (plateCounts[plate] ?? 0) + 1;
      }
    }
    final sortedPlates = plateCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Vehicles = sortedPlates
        .take(5)
        .map((e) => VehicleStat(plate: e.key, count: e.value))
        .toList();

    // ── Autorises vs Refuses par jour (7 derniers jours) ────────────────────
    final last7DaysStatus = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayRecords = records.where((r) {
        final d = r.dateHeureEntree;
        return d != null &&
            d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;
      }).toList();
      return DayStatByStatus(
        day: day,
        autorises:
            dayRecords.where((r) => r.statut == 'Autorise').length,
        refuses: dayRecords
            .where((r) => r.statut == 'Refuse' || r.statut == 'Expire')
            .length,
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
      todayAutorise: todayAutorise,
      todayRefuse: todayRefuse,
      hourlyDistribution: hourlyDistribution,
      top5Vehicles: top5Vehicles,
      last7DaysStatus: last7DaysStatus,
    );
  }
}

/// Conteneur de toutes les statistiques calculees.
class StatsData {
  // Totaux globaux (toutes periodes).
  final int total;
  final int autorises;
  final int refuses;
  final int expires;

  /// Pourcentage global d'acces autorises (0-100).
  final double pctAutorise;

  /// Pourcentage global d'acces refuses/expires (0-100).
  final double pctRefuse;

  /// Totaux par jour sur les 7 derniers jours.
  final List<DayStat> last7Days;

  // ── Donnees pour aujourd'hui (depuis l'API) — PieChart journalier ──────────
  final int todayAutorise;
  final int todayRefuse;

  // ── Distribution horaire sur les 7 derniers jours — 24 tranches ────────────
  final List<int> hourlyDistribution;

  // ── Top 5 vehicules les plus frequents ─────────────────────────────────────
  final List<VehicleStat> top5Vehicles;

  // ── Autorises vs Refuses par jour (7 jours) — grouped bar chart ────────────
  final List<DayStatByStatus> last7DaysStatus;

  const StatsData({
    required this.total,
    required this.autorises,
    required this.refuses,
    required this.expires,
    required this.pctAutorise,
    required this.pctRefuse,
    required this.last7Days,
    required this.todayAutorise,
    required this.todayRefuse,
    required this.hourlyDistribution,
    required this.top5Vehicles,
    required this.last7DaysStatus,
  });
}

/// Nombre total d'acces pour un jour donne.
class DayStat {
  final DateTime day;
  final int count;

  const DayStat({required this.day, required this.count});

  /// Abreviation du jour en francais (ex: "Lun", "Mar").
  String get label {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[day.weekday - 1];
  }
}

/// Acces autorises et refuses pour un jour donne.
class DayStatByStatus {
  final DateTime day;
  final int autorises;
  final int refuses;

  const DayStatByStatus({
    required this.day,
    required this.autorises,
    required this.refuses,
  });

  String get label {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[day.weekday - 1];
  }
}

/// Vehicule avec son nombre d'acces enregistres.
class VehicleStat {
  final String plate;
  final int count;

  const VehicleStat({required this.plate, required this.count});
}
