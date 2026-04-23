import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/at_header.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Copie locale pour gérer les mutations UI
  late List<NotificationEntry> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(MockData.notifications);
  }

  int get _unread => _items.where((e) => !e.isRead).length;

  void _markRead(String id) {
    setState(() {
      final i = _items.indexWhere((e) => e.id == id);
      if (i != -1) _items[i].isRead = true;
    });
  }

  void _delete(String id) {
    setState(() => _items.removeWhere((e) => e.id == id));
  }

  void _markAll() {
    setState(() {
      for (final e in _items) {
        e.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── En-tête gradient ──
          ATHeader(
            title: 'Notifications',
            subtitle: '$_unread non lue(s)',
            showBack: true,
            actions: [
              if (_unread > 0)
                GestureDetector(
                  onTap: _markAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tout lire',
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

          // ── Liste ──
          Expanded(
            child: _items.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final entry = _items[i];
                      return NotificationCard(
                        entry: entry,
                        onMarkRead: () => _markRead(entry.id),
                        onDelete:   () => _delete(entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.notifications_off_outlined,
                size: 32, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Toutes les notifications ont été traitées',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
