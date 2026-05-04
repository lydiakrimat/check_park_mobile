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

              // Chips de filtre par statut
              SizedBox(
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
                          color: active ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : AppColors.muted,
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
      ],
    );
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
            'Aucune entree trouvee',
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
              child: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
