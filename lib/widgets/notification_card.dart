import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_model.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';

/// Carte de notification avec actions (marquer lu / supprimer).
class NotificationCard extends StatelessWidget {
  final NotificationModel entry;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.entry,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Détermine la couleur selon le type de notification.
    final isWarning = entry.type == 'acces_expire';
    final accentColor = isWarning ? AppColors.warning : AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: entry.lu ? AppColors.border : accentColor,
            width: entry.lu ? 1 : 3,
          ),
          top: BorderSide(color: AppColors.border, width: 1),
          right: BorderSide(color: AppColors.border, width: 1),
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: entry.lu
            ? null
            : [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isWarning
                    ? Icons.access_time_rounded
                    : Icons.cancel_rounded,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.titre,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: entry.lu
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      if (!entry.lu)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        DateFormatter.relative(entry.createdAt),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                      const Spacer(),
                      // Bouton marquer lu
                      if (!entry.lu)
                        GestureDetector(
                          onTap: onMarkRead,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.okBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.check_rounded,
                                size: 14, color: AppColors.okText),
                          ),
                        ),
                      const SizedBox(width: 6),
                      // Bouton supprimer
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.noBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: AppColors.noText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
