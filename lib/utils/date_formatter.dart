/// Utilitaires de formatage des dates et heures pour l'affichage dans l'app.
class DateFormatter {
  DateFormatter._();

  /// Formate une DateTime en "dd/MM/yyyy" — ex: "23/04/2026".
  static String date(DateTime? dt) {
    if (dt == null) return '--';
    return '${_pad(dt.day)}/${_pad(dt.month)}/${dt.year}';
  }

  /// Formate une DateTime en "dd/MM/yyyy HH:mm" — ex: "23/04/2026 14:35".
  static String datetime(DateTime? dt) {
    if (dt == null) return '--';
    return '${date(dt)} ${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  /// Formate une DateTime en "HH:mm" — ex: "14:35".
  static String time(DateTime? dt) {
    if (dt == null) return '--';
    return '${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  /// Retourne une description relative de la date (ex: "Il y a 5 min", "Hier").
  /// Utile pour l'affichage des notifications et de l'historique.
  static String relative(DateTime? dt) {
    if (dt == null) return '--';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return date(dt);
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
