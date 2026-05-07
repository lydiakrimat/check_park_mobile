import 'package:shared_preferences/shared_preferences.dart';

/// Service de compteurs quotidiens (SharedPreferences).
///
/// Gere trois compteurs reinitialises chaque nouveau jour :
///   - totalScans    : captures camera + recherches manuelles
///   - autorises     : acces autorises (scan camera ou confirmation manuelle)
///   - refuses       : acces refuses par scan camera
///
/// Les trois compteurs partagent la meme cle de date.
/// Au premier acces de la journee, si la date stockee differ de la date
/// courante, les trois compteurs sont remis a zero simultanement.
class DailyCounterService {
  DailyCounterService._();

  static const _keyDate      = 'daily_counter_date';
  static const _keyScans     = 'daily_counter_scans';
  static const _keyAutorises = 'daily_counter_autorises';
  static const _keyRefuses   = 'daily_counter_refuses';

  // Cle de date au format YYYY-MM-DD pour comparaison quotidienne.
  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // Reinitialise les trois compteurs si la date stockee differe d'aujourd'hui.
  static Future<void> _checkAndReset(SharedPreferences prefs) async {
    final today = _todayKey();
    if (prefs.getString(_keyDate) != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyScans, 0);
      await prefs.setInt(_keyAutorises, 0);
      await prefs.setInt(_keyRefuses, 0);
    }
  }

  /// Incremente le compteur total de scans.
  /// Appele apres chaque capture camera ou recherche manuelle reussie.
  static Future<void> incrementScans() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndReset(prefs);
    await prefs.setInt(_keyScans, (prefs.getInt(_keyScans) ?? 0) + 1);
  }

  /// Incremente le compteur d'acces autorises.
  /// Appele quand un scan retourne Autorise ou quand l'agent confirme l'entree.
  static Future<void> incrementAutorises() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndReset(prefs);
    await prefs.setInt(
        _keyAutorises, (prefs.getInt(_keyAutorises) ?? 0) + 1);
  }

  /// Incremente le compteur d'acces refuses.
  /// Appele quand un scan camera retourne un statut Refuse.
  static Future<void> incrementRefuses() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndReset(prefs);
    await prefs.setInt(_keyRefuses, (prefs.getInt(_keyRefuses) ?? 0) + 1);
  }

  /// Retourne les trois compteurs apres verification/reinitialisation quotidienne.
  static Future<DailyCounters> getCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndReset(prefs);
    return DailyCounters(
      scans:     prefs.getInt(_keyScans)     ?? 0,
      autorises: prefs.getInt(_keyAutorises) ?? 0,
      refuses:   prefs.getInt(_keyRefuses)   ?? 0,
    );
  }
}

/// Conteneur des trois compteurs quotidiens.
class DailyCounters {
  final int scans;
  final int autorises;
  final int refuses;

  const DailyCounters({
    required this.scans,
    required this.autorises,
    required this.refuses,
  });
}
