import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/access_card.dart';

/// Écran de l'historique des accès (entrées/sorties).
///
/// Charge les données depuis Laravel via HistoryProvider.
/// Supporte la recherche par nom/plaque et les filtres par statut.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();

  static const _filters = ['Tous', 'Autorise', 'Refuse', 'Expire'];

  @override
  void initState() {
    super.initState();
    // Chargement initial des données depuis Laravel.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetch();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final histProv = context.watch<HistoryProvider>();
    final items = histProv.filteredRecords;
    final activeFilter = histProv.statusFilter ?? 'Tous';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barre de recherche + filtres
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historique des Acces',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                histProv.loading
                    ? 'Chargement...'
                    : '${items.length} entree(s)',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 14),

              // Champ de recherche
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => context.read<HistoryProvider>().setSearch(v),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom, matricule...',
                  filled: true,
                  fillColor: AppColors.white,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(13),
                    child: Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  suffixIcon: histProv.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.muted),
                          onPressed: () {
                            _searchCtrl.clear();
                            context.read<HistoryProvider>().setSearch('');
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.green, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 13, horizontal: 4),
                ),
              ),
              const SizedBox(height: 10),

              // Barre de filtres : chips de statut + bouton filtre par date
              Row(
                children: [
                  // Chips de statut dans une zone horizontale scrollable
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final f = _filters[i];
                          final active = activeFilter == f ||
                              (f == 'Tous' && histProv.statusFilter == null);
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<HistoryProvider>()
                                  .setStatusFilter(f == 'Tous' ? null : f);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                f,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      active ? Colors.white : AppColors.muted,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton de filtre par plage de dates
                  _dateFilterButton(histProv),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),

        // Liste ou état vide
        Expanded(
          child: histProv.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : histProv.errorMessage != null
                  ? _errorState(histProv.errorMessage!)
                  : items.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () =>
                              context.read<HistoryProvider>().fetch(),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (_, i) =>
                                AccessCard(entry: items[i]),
                          ),
                        ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  /// Ouvre le sélecteur de plage de dates Flutter natif (Material DateRangePicker).
  /// Applique le filtre dans HistoryProvider après la sélection.
  Future<void> _showDateRangePicker() async {
    final provider = context.read<HistoryProvider>();
    final initialRange = provider.dateFrom != null && provider.dateTo != null
        ? DateTimeRange(start: provider.dateFrom!, end: provider.dateTo!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: initialRange,
      builder: (bCtx, child) => Theme(
        data: Theme.of(bCtx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (!mounted) return;
    if (picked != null) {
      context.read<HistoryProvider>().setDateRange(picked.start, picked.end);
    }
  }

  /// Bouton de filtre par date — affiche la plage sélectionnée quand actif,
  /// avec un X pour réinitialiser le filtre.
  Widget _dateFilterButton(HistoryProvider provider) {
    final isActive = provider.dateFrom != null;

    return GestureDetector(
      onTap: _showDateRangePicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 14,
              color: isActive ? Colors.white : AppColors.muted,
            ),
            // Quand actif : affiche la plage et un bouton X pour supprimer le filtre
            if (isActive) ...[
              const SizedBox(width: 4),
              Text(
                '${_shortDate(provider.dateFrom!)} - ${_shortDate(provider.dateTo!)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () =>
                    context.read<HistoryProvider>().setDateRange(null, null),
                child: const Icon(Icons.close_rounded,
                    size: 13, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Formate une date en "dd/MM" pour l'affichage compact dans le chip de filtre.
  String _shortDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_toggle_off_rounded,
              size: 52, color: AppColors.border),
          const SizedBox(height: 14),
          Text(
            'Aucune entrée trouvée',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Modifiez les filtres ou la recherche',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.muted),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.read<HistoryProvider>().fetch(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
