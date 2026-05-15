import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';
import '../utils/date_formatter.dart';

/// Carte de notification avec actions (marquer vu / supprimer).
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
    final isExpiration = entry.type == 'duree_expiree';
    final accentColor = isExpiration ? AppColors.warning : AppColors.danger;
    final c = context.colors;
    final isRead = entry.vuAgent;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: c.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? c.border : accentColor,
          width: isRead ? 1 : 2,
        ),
      ),
      elevation: isRead ? 0 : 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: icone + badge type + indicateur non-lu
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isExpiration
                        ? Icons.access_time_rounded
                        : Icons.cancel_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isExpiration ? 'Duree expiree' : 'Acces refuse',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (!isRead)
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
            const SizedBox(height: 10),

            // Row 2: message
            Text(
              entry.message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                color: c.text,
              ),
            ),

            // Row 3: plaque (si presente)
            if (entry.plateNumber != null && entry.plateNumber!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Plaque : ${entry.plateNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),

            // Row 4: date + boutons actions
            Row(
              children: [
                Text(
                  DateFormatter.relative(entry.createdAt),
                  style: TextStyle(fontSize: 10, color: c.muted),
                ),
                const Spacer(),
                if (!isRead)
                  GestureDetector(
                    onTap: onMarkRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.okBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded,
                              size: 12, color: AppColors.okText),
                          const SizedBox(width: 4),
                          Text('Lu',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.okText)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: c.noBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 14, color: AppColors.noText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
