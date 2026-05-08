import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';
import '../widgets/at_header.dart';
import '../widgets/notification_card.dart';

/// Écran des notifications de sécurité.
///
/// Charge les notifications depuis Laravel via NotificationProvider.
/// Permet de marquer comme lu et de supprimer.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotificationProvider>();
    final unread    = notifProv.unreadCount;
    final c         = context.colors;
    final l         = context.l10n;

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          // En-tête gradient
          ATHeader(
            title: l.notifications,
            subtitle: l.nonLues(unread),
            showBack: true,
            actions: [
              if (unread > 0)
                GestureDetector(
                  onTap: () => notifProv.markAllAsRead(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l.toutLire,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Contenu
          Expanded(
            child: notifProv.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : notifProv.notifications.isEmpty
                    ? _emptyState(c, l)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => notifProv.fetch(),
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: notifProv.notifications.length,
                          itemBuilder: (_, i) {
                            final entry = notifProv.notifications[i];
                            return NotificationCard(
                              entry: entry,
                              onMarkRead: () => notifProv.markAsRead(entry.id),
                              onDelete: () => notifProv.delete(entry.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(AppColorsScheme c, AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.background,
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            child: Icon(Icons.notifications_off_outlined,
                size: 32, color: c.muted),
          ),
          const SizedBox(height: 16),
          Text(
            l.aucuneNotification,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.notifTraitees,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: c.muted),
          ),
        ],
      ),
    );
  }
}
