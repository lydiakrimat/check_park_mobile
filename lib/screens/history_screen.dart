import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/access_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _filterStatus = 'Tous';
  String _query = '';

  static const _filters = ['Tous', 'Autorise', 'Refuse', 'Expire'];

  List<AccessEntry> get _filtered {
    return MockData.accessHistory.where((e) {
      final matchQ = _query.isEmpty ||
          e.displayName.toLowerCase().contains(_query.toLowerCase()) ||
          e.plate.toLowerCase().contains(_query.toLowerCase());
      final matchF = _filterStatus == 'Tous' || e.status == _filterStatus;
      return matchQ && matchF;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Barre de recherche + filtre ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Historique des Accès',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Employés et visiteurs — ${items.length} entrée(s)',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 14),

              // Recherche
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
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
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.muted),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
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

              // Filtres statut
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = _filters[i];
                    final active = _filterStatus == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filterStatus = f),
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

        // ── Liste ──
        Expanded(
          child: items.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (_, i) => AccessCard(entry: items[i]),
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
            'Aucune entrée trouvée',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
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
}
