import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/statistics_provider.dart';
import '../services/statistics_service.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';

/// Ecran des statistiques d'acces — Algerie Telecom.
///
/// Sources de donnees :
///   - KPIs (3 cartes)     : compteurs quotidiens via SharedPreferences
///   - PieChart             : repartition autorises/refuses aujourd'hui (API)
///   - BarChart 7 jours     : total des acces par jour (API)
///   - BarChart horaire     : distribution des acces par heure sur 7 jours (API)
///   - Top 5 vehicules      : matricules les plus frequents (API)
///   - Grouped bar 7 jours  : autorises vs refuses par jour (API)
///
/// Un seul appel API (GET /api/acces via HistoryProvider) alimente tous les charts.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // Reference conservee pour retirer le listener dans dispose().
  HistoryProvider? _histProv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _histProv = context.read<HistoryProvider>();
      // Abonnement aux notifications de HistoryProvider.
      // Quand un fetch se termine (loading passe a false), les stats sont
      // automatiquement recalculees, meme si le fetch a ete declenche par
      // HistoryScreen dont l'initState s'execute en meme temps dans l'IndexedStack.
      _histProv!.addListener(_onHistoryChanged);

      context.read<StatisticsProvider>().loadCounters();

      if (_histProv!.allRecords.isNotEmpty && !_histProv!.loading) {
        // Donnees deja disponibles : calcule immediatement.
        context.read<StatisticsProvider>().compute(_histProv!.allRecords);
      } else if (!_histProv!.loading) {
        // Aucune donnee, aucun fetch en cours : lance le chargement.
        _histProv!.fetch();
      }
      // Si loading=true deja : _onHistoryChanged gerera le compute.
    });
  }

  @override
  void dispose() {
    _histProv?.removeListener(_onHistoryChanged);
    super.dispose();
  }

  // Appele a chaque notification de HistoryProvider.
  // Recalcule les statistiques des que le chargement API se termine.
  void _onHistoryChanged() {
    if (!mounted) return;
    final histProv = _histProv;
    if (histProv == null || histProv.loading) return;
    context.read<StatisticsProvider>().compute(histProv.allRecords);
  }

  @override
  Widget build(BuildContext context) {
    final statsProv = context.watch<StatisticsProvider>();
    final histProv  = context.watch<HistoryProvider>();
    final stats     = statsProv.stats;

    if (histProv.loading || stats == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre ─────────────────────────────────────────────────────────
          Text(
            'Statistiques',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tableau de bord des acces',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 20),

          // ── KPIs : 3 cartes (compteurs quotidiens SharedPreferences) ───────
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Scans auj.',
                  value: '${statsProv.dailyScans}',
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Autorises',
                  value: '${statsProv.dailyAutorises}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Refuses',
                  value: '${statsProv.dailyRefuses}',
                  icon: Icons.cancel_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── PieChart : repartition autorises / refuses aujourd'hui ─────────
          _sectionLabel("REPARTITION DES ACCES AUJOURD'HUI"),
          const SizedBox(height: 14),
          _buildCard(child: _buildTodayPieChart(stats)),
          const SizedBox(height: 24),

          // ── BarChart : total acces par jour (7 derniers jours) ─────────────
          _sectionLabel('ACCES PAR JOUR (7 DERNIERS JOURS)'),
          const SizedBox(height: 14),
          _buildCard(child: _buildWeeklyBarChart(stats)),
          const SizedBox(height: 24),

          // ── BarChart : distribution horaire sur 7 jours ────────────────────
          _sectionLabel('DISTRIBUTION HORAIRE DES ACCES (7 DERNIERS JOURS)'),
          const SizedBox(height: 14),
          _buildCard(child: _buildHourlyChart(stats)),
          const SizedBox(height: 24),

          // ── Barres horizontales : Top 5 vehicules ─────────────────────────
          _sectionLabel('TOP 5 VEHICULES LES PLUS FREQUENTS'),
          const SizedBox(height: 14),
          _buildCard(child: _buildTop5Chart(stats)),
          const SizedBox(height: 24),

          // ── Grouped BarChart : autorises vs refuses par jour ───────────────
          _sectionLabel('AUTORISES VS REFUSES (7 DERNIERS JOURS)'),
          const SizedBox(height: 14),
          _buildCard(child: _buildGroupedBarChart(stats)),

          SizedBox(height: MediaQuery.of(context).padding.bottom),        
        ],
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String t) => Text(
        t,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 1.0,
        ),
      );

  // ── Carte blanche avec ombre (contenant des charts) ───────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F2F5A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── PieChart : repartition autorises / refuses (donnees d'aujourd'hui) ─────

  Widget _buildTodayPieChart(StatsData stats) {
    final todayTotal = stats.todayAutorise + stats.todayRefuse;

    if (todayTotal == 0) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            "Aucun acces aujourd'hui",
            style: GoogleFonts.plusJakartaSans(color: AppColors.muted),
          ),
        ),
      );
    }

    final pctOk  = stats.todayAutorise / todayTotal * 100;
    final pctKo  = stats.todayRefuse   / todayTotal * 100;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 48,
              sections: [
                PieChartSectionData(
                  value: stats.todayAutorise.toDouble(),
                  title: '${pctOk.toInt()}%',
                  color: AppColors.green,
                  radius: 70,
                  titleStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                PieChartSectionData(
                  value: stats.todayRefuse > 0
                      ? stats.todayRefuse.toDouble()
                      : 0.01,
                  title: stats.todayRefuse > 0 ? '${pctKo.toInt()}%' : '',
                  color: AppColors.danger,
                  radius: 70,
                  titleStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(
              AppColors.green,
              'Autorises',
              '${stats.todayAutorise}',
            ),
            const SizedBox(width: 24),
            _legendItem(
              AppColors.danger,
              'Refuses',
              '${stats.todayRefuse}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color c, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $value',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  // ── BarChart : total acces par jour (7 jours) — barres personnalisees ───────

  Widget _buildWeeklyBarChart(StatsData stats) {
    final maxCount = stats.last7Days
        .map((d) => d.count)
        .fold(0, (a, b) => a > b ? a : b);

    if (maxCount == 0) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Aucun acces sur les 7 derniers jours',
            style: GoogleFonts.plusJakartaSans(color: AppColors.muted),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: stats.last7Days.map((day) {
        final pct = maxCount > 0 ? day.count / maxCount : 0.0;
        return _weekBar(day.label, pct.clamp(0.05, 1.0), day.count);
      }).toList(),
    );
  }

  Widget _weekBar(String day, double pct, int count) {
    const maxH = 90.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: maxH * pct,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryLight, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }

  // ── BarChart : distribution horaire (7h-20h) via fl_chart ──────────────────

  Widget _buildHourlyChart(StatsData stats) {
    // Plage horaire affichee : heures d'ouverture du parking (7h a 20h inclus).
    const hourStart = 7;
    const hourEnd   = 20;
    const hourCount = hourEnd - hourStart + 1; // 14 barres

    // Calcule le max uniquement sur la plage affichee.
    final maxH = stats.hourlyDistribution
        .sublist(hourStart, hourEnd + 1)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    if (maxH == 0) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Aucun acces sur les 7 derniers jours',
            style: GoogleFonts.plusJakartaSans(color: AppColors.muted),
          ),
        ),
      );
    }

    // 14 barres (7h-20h) dans un scroll horizontal.
    return SizedBox(
      height: 180,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: hourCount * 30.0, // 30 dp par tranche horaire
          child: BarChart(
            BarChartData(
              maxY: maxH * 1.2,
              barGroups: List.generate(hourCount, (i) {
                final hour = hourStart + i;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: stats.hourlyDistribution[hour].toDouble(),
                      color: AppColors.primary,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final hour = hourStart + value.toInt();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${hour}h',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            color: AppColors.muted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      AppColors.primaryDark.withValues(alpha: 0.85),
                  getTooltipItem: (group, _, rod, __) {
                    // Reconvertit l'index de barre (0-13) en heure reelle (7h-20h).
                    final hour = hourStart + group.x.toInt();
                    return BarTooltipItem(
                      '${hour}h\n${rod.toY.toInt()} acces',
                      GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Barres horizontales : Top 5 vehicules ─────────────────────────────────

  Widget _buildTop5Chart(StatsData stats) {
    if (stats.top5Vehicles.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Aucun acces enregistre',
            style: GoogleFonts.plusJakartaSans(color: AppColors.muted),
          ),
        ),
      );
    }

    // Le premier vehicule a le plus grand compteur (liste deja triee desc).
    final maxCount = stats.top5Vehicles.first.count;

    return Column(
      children: stats.top5Vehicles.map((v) {
        final fraction = maxCount > 0 ? v.count / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Matricule
              SizedBox(
                width: 80,
                child: Text(
                  v.plate,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Barre proportionnelle
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: fraction.clamp(0.04, 1.0),
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryLight, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Compteur
              SizedBox(
                width: 28,
                child: Text(
                  '${v.count}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Grouped BarChart : autorises (vert) vs refuses (rouge) par jour ─────────

  Widget _buildGroupedBarChart(StatsData stats) {
    // Valeur max pour definir l'echelle Y.
    final maxY = stats.last7DaysStatus
        .expand((d) => [d.autorises, d.refuses])
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    if (maxY == 0) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Aucun acces sur les 7 derniers jours',
            style: GoogleFonts.plusJakartaSans(color: AppColors.muted),
          ),
        ),
      );
    }

    // Intervalle des graduations Y adapte au maximum : valeurs "rondes" lisibles.
    final interval = maxY <= 4   ? 1.0
        : maxY <= 10  ? 2.0
        : maxY <= 20  ? 5.0
        : maxY <= 50  ? 10.0
        : maxY <= 100 ? 20.0
        : (maxY / 5).ceil().toDouble();

    return Column(
      children: [
        SizedBox(
          height: 220, // hauteur augmentee pour laisser de la place a l'axe Y
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              groupsSpace: 12,
              barGroups: List.generate(7, (i) {
                final d = stats.last7DaysStatus[i];
                return BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  barRods: [
                    // Barre verte : acces autorises
                    BarChartRodData(
                      toY: d.autorises.toDouble(),
                      color: AppColors.green,
                      width: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    // Barre rouge : acces refuses
                    BarChartRodData(
                      toY: d.refuses.toDouble(),
                      color: AppColors.danger,
                      width: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                // Axe Y gauche avec graduations adaptees au max.
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      // N'affiche que les multiples entiers de l'intervalle.
                      if (value % interval != 0) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '${value.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= 7) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          stats.last7DaysStatus[idx].label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.border,
                  strokeWidth: 0.8,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      AppColors.primaryDark.withValues(alpha: 0.85),
                  getTooltipItem: (group, _, rod, rodIdx) {
                    final label = rodIdx == 0 ? 'Autorises' : 'Refuses';
                    return BarTooltipItem(
                      '$label\n${rod.toY.toInt()}',
                      GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Legende
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(AppColors.green, 'Autorises', ''),
            const SizedBox(width: 24),
            _legendItem(AppColors.danger, 'Refuses', ''),
          ],
        ),
      ],
    );
  }
}
