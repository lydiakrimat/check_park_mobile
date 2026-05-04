import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/access_record.dart';
import '../theme/app_colors.dart';
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
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
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPermanent ? 'Employe AT' : 'Visiteur',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              _typeBadge(isPermanent),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Ligne 2 : plaque + heure d'entrée + statut
          Row(
            children: [
              PlateBadge(plate: entry.displayPlate, fontSize: 11),
              const SizedBox(width: 8),
              const Icon(Icons.access_time_rounded,
                  size: 13, color: AppColors.muted),
              const SizedBox(width: 3),
              Text(
                DateFormatter.datetime(entry.dateHeureEntree),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
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

  Widget _typeBadge(bool isPermanent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPermanent ? AppColors.blueTint : AppColors.orangeTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPermanent ? 'Permanent' : 'Temporaire',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isPermanent ? AppColors.primary : AppColors.warning,
        ),
      ),
    );
  }
}
