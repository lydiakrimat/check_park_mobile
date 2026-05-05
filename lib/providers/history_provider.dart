import 'package:flutter/foundation.dart';
import '../models/access_record.dart';
import '../services/access_service.dart';
import '../services/api_service.dart';

/// Provider de l'état de l'historique des accès.
///
/// Charge la liste depuis Laravel et applique les filtres localement
/// (recherche par plaque, filtre par statut).
class HistoryProvider extends ChangeNotifier {
  final AccessService _service;

  List<AccessRecord> _allRecords = [];
  bool _loading = false;
  String? _errorMessage;

  /// Texte de recherche courant (filtre sur la plaque ou le nom).
  String _searchQuery = '';

  /// Filtre de statut courant : null = tous, ou 'Autorise', 'Refuse', 'Expire'.
  String? _statusFilter;

  /// Filtre par plage de dates — bornes inclusive sur dateHeureEntree.
  /// Null = pas de filtre sur cette borne.
  DateTime? _dateFrom;
  DateTime? _dateTo;

  HistoryProvider(this._service);

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  DateTime? get dateFrom => _dateFrom;
  DateTime? get dateTo => _dateTo;

  /// Liste filtrée — utilisée directement par l'écran Historique.
  List<AccessRecord> get filteredRecords {
    return _allRecords.where((r) {
      // Filtre par statut.
      if (_statusFilter != null && r.statut != _statusFilter) return false;
      // Filtre par texte (plaque ou nom).
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final plate = r.displayPlate.toLowerCase();
        final name  = r.displayName.toLowerCase();
        if (!plate.contains(query) && !name.contains(query)) return false;
      }
      // Filtre par plage de dates sur dateHeureEntree (bornes inclusives).
      if (_dateFrom != null || _dateTo != null) {
        final entry = r.dateHeureEntree;
        if (entry == null) return false;
        // Comparaison au niveau du jour (sans l'heure).
        final entryDay = DateTime(entry.year, entry.month, entry.day);
        if (_dateFrom != null) {
          final fromDay = DateTime(_dateFrom!.year, _dateFrom!.month, _dateFrom!.day);
          if (entryDay.isBefore(fromDay)) return false;
        }
        if (_dateTo != null) {
          final toDay = DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day);
          if (entryDay.isAfter(toDay)) return false;
        }
      }
      return true;
    }).toList();
  }

  /// Tous les enregistrements bruts — utilisés par StatisticsService.
  List<AccessRecord> get allRecords => List.unmodifiable(_allRecords);

  // ── Chargement ─────────────────────────────────────────────────────────────

  /// Charge l'historique complet depuis Laravel.
  Future<void> fetch() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allRecords = await _service.fetchAll();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Erreur lors du chargement de l\'historique.';
    }

    _loading = false;
    notifyListeners();
  }

  // ── Filtres ────────────────────────────────────────────────────────────────

  /// Met à jour le texte de recherche et rafraîchit la liste filtrée.
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Définit le filtre de statut. Passer null pour afficher tous les statuts.
  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Définit la plage de dates pour filtrer sur dateHeureEntree.
  /// Passer null aux deux paramètres pour supprimer le filtre date.
  void setDateRange(DateTime? from, DateTime? to) {
    _dateFrom = from;
    _dateTo = to;
    notifyListeners();
  }

  /// Réinitialise tous les filtres (texte, statut et plage de dates).
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _dateFrom = null;
    _dateTo = null;
    notifyListeners();
  }
}
