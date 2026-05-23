import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/scan_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';

/// Carte de résultat pour un véhicule temporaire (visiteur).
///
/// Affiche les informations du visiteur : nom, prénom, téléphone,
/// motif de visite, durée autorisée et matricule du véhicule.
/// Utilisée par SearchScreen lorsque le résultat est de type "temporaire".
class TemporaireResultCard extends StatelessWidget {
  final ScanResult result;

  const TemporaireResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final owner = result.owner;

    return Container(
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F2F5A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec badge "Visiteur temporaire"
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: c.orangeTint,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.warning,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        owner?.fullName ?? result.displayPlate,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                        ),
                      ),
                      Text(
                        l.visiteurTemporaire,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.warning),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l.autorise,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Détails du visiteur
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (result.displayPlate.isNotEmpty)
                  _row(l.matricule, result.displayPlate, c),
                if (owner != null)
                  _row(l.visiteur, owner.fullName, c),
                if (owner?.telephone != null &&
                    owner!.telephone!.isNotEmpty)
                  _row(l.telephone, owner.telephone!, c),
                if (owner?.motifVisite != null &&
                    owner!.motifVisite!.isNotEmpty)
                  _row(l.motifVisite, owner.motifVisite!, c),
                if (owner?.dureeAutorisee != null)
                  _row(l.dureeAutorisee,
                      l.dureeMinutes(owner!.dureeAutorisee!), c),
                if (result.similarityScore != null)
                  _row(l.similarite,
                      '${(result.similarityScore! * 100).toStringAsFixed(0)}%',
                      c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String key, String value, AppColorsScheme c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              key,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
