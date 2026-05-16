import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';
import '../widgets/at_header.dart';
import '../widgets/notification_card.dart';

/// Ecran des notifications de securite.
///
/// Charge les notifications depuis Laravel via NotificationProvider.
/// Permet de marquer comme vu et de supprimer avec confirmation.
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

  /// Affiche un dialog de confirmation avant suppression.
  Future<void> _confirmDelete(BuildContext context, int id) async {
    final c = context.colors;
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        bool deleting = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: c.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icone
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Titre
                    Text(
                      l.supprimerAlerte,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Message
                    Text(
                      l.confirmerSupprAlerte,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: c.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Boutons
                    Row(
                      children: [
                        // Annuler
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(ctx).pop(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: c.border),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  l.annuler,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: c.text,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Confirmer
                        Expanded(
                          child: GestureDetector(
                            onTap: deleting
                                ? null
                                : () async {
                                    setDialogState(() => deleting = true);
                                    await context
                                        .read<NotificationProvider>()
                                        .delete(id);
                                    if (ctx.mounted) {
                                      Navigator.of(ctx).pop(true);
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: deleting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        l.confirmer,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    // Le dialog gère la suppression lui-même, pas besoin de traiter confirmed ici
    if (confirmed == true) return;
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
          // En-tete gradient
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
                      l.toutMarquerCommeLu,
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

          // Message d'erreur si le chargement a echoue
          if (notifProv.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                notifProv.errorMessage!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.danger,
                ),
              ),
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
                              onDelete: () => _confirmDelete(context, entry.id),
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
