import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/history_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/statistics_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';
import '../utils/responsive.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'scanner_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

// ─────────────────────────────────────────────
//  Shell principal avec BottomAppBar + FAB centre
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIdx = 2;

  final List<Widget> _pages = const [
    SearchScreen(),
    HistoryScreen(),
    _HomeTab(),
    StatsScreen(),
    SettingsScreen(),
  ];

  void _onNavTap(int idx) {
    if (idx == 3 && _currentIdx != 3) {
      context.read<StatisticsProvider>().loadCounters();
      context.read<HistoryProvider>().fetch();
    }
    setState(() => _currentIdx = idx);
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  int get _unread => context.watch<NotificationProvider>().unreadCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;

    // Titres des onglets dans la langue courante.
    final titles = [
      l.rechercher,
      l.historique,
      l.controleAcces,
      l.statistiques,
      l.parametres,
    ];

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      extendBody: true,
      backgroundColor: c.background,
      appBar: _buildAppBar(titles[_currentIdx], c, l),
      body: IndexedStack(index: _currentIdx, children: _pages),
      floatingActionButton: _ScannerFab(
        isActive: _currentIdx == 2,
        onTap: () {
          if (_currentIdx == 2) {
            _openScanner();
          } else {
            _onNavTap(2);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(c, l),
    );
  }

  PreferredSizeWidget _buildAppBar(
      String title, AppColorsScheme c, AppLocalizations l) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image(
                    image: const AssetImage('lib/assets/logo_AT.png'),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      'AT',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Algérie Télécom',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.greenTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.actif,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: _openNotifications,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    if (_unread > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$_unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
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
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppColorsScheme c, AppLocalizations l) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: c.white,
      elevation: 8,
      shadowColor: const Color(0x200F2F5A),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(child: _navItem(0, Icons.search_rounded,    l.rechercher, c)),
            Expanded(child: _navItem(1, Icons.history_rounded,   l.historique, c)),
            const Expanded(child: SizedBox()),
            Expanded(child: _navItem(3, Icons.bar_chart_rounded, l.statsNav,   c)),
            Expanded(child: _navItem(4, Icons.settings_rounded,  l.paramsNav,  c)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label, AppColorsScheme c) {
    final active = _currentIdx == idx;
    return GestureDetector(
      onTap: () => _onNavTap(idx),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: active ? AppColors.primary : c.muted,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.primary : c.muted,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 16 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FAB central Scanner
// ─────────────────────────────────────────────
class _ScannerFab extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _ScannerFab({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.greenLight, AppColors.green],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Onglet Home — illustration + 2 boutons
// ─────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: c.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x120F2F5A),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: Responsive.rw(context, 110),
                    height: Responsive.rw(context, 110),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: c.border, width: 1.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 54,
                          color: AppColors.primary,
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Text(
                            '?',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.warning,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Text(
                            '?',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primaryLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.controleTitre,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.controleSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: c.muted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _actionButton(
              context: context,
              icon: Icons.camera_alt_rounded,
              label: l.scannerUnePlaque,
              sublabel: l.utiliserCamera,
              color: AppColors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _actionButton(
              context: context,
              icon: Icons.keyboard_rounded,
              label: l.saisirUnePlaque,
              sublabel: l.saisieManuelle,
              color: AppColors.primary,
              outlined: true,
              onTap: () {
                final shell =
                    context.findAncestorStateOfType<_HomeScreenState>();
                shell?._onNavTap(0);
              },
            ),
            const SizedBox(height: 32),

            const _QuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    bool outlined = false,
    required VoidCallback onTap,
  }) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: outlined ? c.white : color,
          borderRadius: BorderRadius.circular(14),
          border: outlined ? Border.all(color: color, width: 1.5) : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: outlined
                    ? color.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: outlined ? color : Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: outlined ? color : Colors.white,
                  ),
                ),
                Text(
                  sublabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: outlined
                        ? color.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: outlined ? color : Colors.white.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget des infos rapides (KPIs) sur l'écran d'accueil.
class _QuickStats extends StatelessWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context) {
    final stats     = context.watch<StatisticsProvider>().stats;
    final total     = stats?.total ?? 0;
    final autorises = stats?.autorises ?? 0;
    final refuses   = (stats?.refuses ?? 0) + (stats?.expires ?? 0);
    final l         = context.l10n;

    return Row(
      children: [
        Expanded(child: _quickInfo(context, Icons.check_circle_rounded,
            '$autorises', l.autorises, AppColors.green)),
        const SizedBox(width: 10),
        Expanded(child: _quickInfo(context, Icons.cancel_rounded,
            '$refuses', l.refuses, AppColors.danger)),
        const SizedBox(width: 10),
        Expanded(child: _quickInfo(context, Icons.camera_alt_rounded,
            '$total', l.scans, AppColors.primary)),
      ],
    );
  }

  Widget _quickInfo(BuildContext context, IconData icon, String value,
      String label, Color color) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted),
          ),
        ],
      ),
    );
  }
}
