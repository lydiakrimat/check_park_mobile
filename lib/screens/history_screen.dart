import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/history_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';
import '../widgets/access_card.dart';

/// Écran de l'historique des accès (entrées/sorties).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();

  // Valeurs internes des filtres (invariantes — utilisées par le provider).
  static const _filterKeys = ['Tous', 'Autorise', 'Refuse', 'Expire'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetch();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Retourne le label localisé d'un filtre.
  String _filterLabel(String key, AppLocalizations l) {
    switch (key) {
      case 'Autorise': return l.autorise;
      case 'Refuse':   return l.refuse;
      case 'Expire':   return l.expire;
      default:         return l.filtresTous;
    }
  }

  @override
  Widget build(BuildContext context) {
    final histProv     = context.watch<HistoryProvider>();
    final items        = histProv.filteredRecords;
    final activeFilter = histProv.statusFilter ?? 'Tous';
    final c            = context.colors;
    final l            = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.historiqueDesAcces,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                histProv.loading
                    ? l.chargement
                    : l.entrees(items.length),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: c.muted),
              ),
              const SizedBox(height: 14),

              // Champ de recherche
              TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    context.read<HistoryProvider>().setSearch(v),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: c.text),
                decoration: InputDecoration(
                  hintText: l.rechercheHint,
                  filled: true,
                  fillColor: c.white,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  suffixIcon: histProv.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              size: 18, color: c.muted),
                          onPressed: () {
                            _searchCtrl.clear();
                            context.read<HistoryProvider>().setSearch('');
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border, width: 1.5),
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

              // Barre de filtres
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterKeys.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final key    = _filterKeys[i];
                          final label  = _filterLabel(key, l);
                          final active = activeFilter == key ||
                              (key == 'Tous' &&
                                  histProv.statusFilter == null);
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<HistoryProvider>()
                                  .setStatusFilter(
                                      key == 'Tous' ? null : key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.primary
                                    : c.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? AppColors.primary
                                      : c.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : c.muted,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _dateFilterButton(histProv, c),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),

        Expanded(
          child: histProv.loading
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : histProv.errorMessage != null
                  ? _errorState(histProv.errorMessage!, c, l)
                  : items.isEmpty
                      ? _emptyState(c, l)
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () =>
                              context.read<HistoryProvider>().fetch(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            physics:
                                const AlwaysScrollableScrollPhysics(),
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

  Future<void> _showDateRangePicker() async {
    final provider = context.read<HistoryProvider>();
    final initialRange =
        provider.dateFrom != null && provider.dateTo != null
            ? DateTimeRange(
                start: provider.dateFrom!, end: provider.dateTo!)
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
      context
          .read<HistoryProvider>()
          .setDateRange(picked.start, picked.end);
    }
  }

  Widget _dateFilterButton(HistoryProvider provider, AppColorsScheme c) {
    final isActive = provider.dateFrom != null;

    return GestureDetector(
      onTap: _showDateRangePicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : c.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : c.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 14,
              color: isActive ? Colors.white : c.muted,
            ),
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
                onTap: () => context
                    .read<HistoryProvider>()
                    .setDateRange(null, null),
                child: const Icon(Icons.close_rounded,
                    size: 13, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _shortDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';

  Widget _emptyState(AppColorsScheme c, AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 52, color: c.border),
          const SizedBox(height: 14),
          Text(
            l.aucuneEntree,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.modifierFiltres,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: c.muted),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String message, AppColorsScheme c, AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: c.muted),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: c.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.read<HistoryProvider>().fetch(),
              child: Text(l.reessayer),
            ),
          ],
        ),
      ),
    );
  }
}
