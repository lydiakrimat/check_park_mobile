import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/access_record.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';
import '../utils/date_formatter.dart';
import 'plate_badge.dart';
import 'status_badge.dart';

/// Carte d'historique d'accès — affiche les infos d'un AccessRecord.
class AccessCard extends StatelessWidget {
  final AccessRecord entry;

  const AccessCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isPermanent = entry.typeAcces == 'Permanent';
    final c           = context.colors;
    final l           = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F2F5A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne 1 : avatar + nom + badge type
          Row(
            children: [
              _avatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPermanent ? l.employeAT : l.visiteur,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              _typeBadge(isPermanent, c, l),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Ligne 2 : plaque + dates d'entree/sortie + statut
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlateBadge(plate: entry.displayPlate, fontSize: 11),
              const SizedBox(width: 8),
              // Colonne des dates : entree obligatoire, sortie nullable
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date et heure d'entree sur le site
                    Row(
                      children: [
                        Icon(Icons.login_rounded, size: 12, color: c.muted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${l.entreePrefix}${DateFormatter.datetime(entry.dateHeureEntree)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: c.muted,
                            ),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Date et heure de sortie — ou badge "Toujours sur site" si encore présent
                    Row(
                      children: [
                        Icon(
                          entry.dateHeureSortie != null
                              ? Icons.logout_rounded
                              : Icons.location_on_rounded,
                          size: 12,
                          color: entry.dateHeureSortie != null
                              ? c.muted
                              : const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: entry.dateHeureSortie != null
                              ? Text(
                                  '${l.sortiePrefix}${DateFormatter.datetime(entry.dateHeureSortie)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: c.muted,
                                  ),
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l.toujoursSurSite,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(status: entry.statut),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          entry.initials,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _typeBadge(bool isPermanent, AppColorsScheme c, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPermanent ? c.blueTint : c.orangeTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPermanent ? l.permanent : l.temporaire,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isPermanent ? AppColors.primary : AppColors.warning,
        ),
      ),
    );
  }
}
