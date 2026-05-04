import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/statistics_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';

/// Écran des statistiques d'accès.
///
/// Les stats sont calculées localement par StatisticsProvider
/// à partir des données d'historique chargées par HistoryProvider.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Charge l'historique si pas encore fait, puis calcule les stats.
      final histProv = context.read<HistoryProvider>();
      if (histProv.allRecords.isEmpty && !histProv.loading) {
        histProv.fetch().then((_) {
          if (mounted) {
            context.read<StatisticsProvider>().compute(histProv.allRecords);
          }
        });
      } else {
        context.read<StatisticsProvider>().compute(histProv.allRecords);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsProv = context.watch<StatisticsProvider>();
    final histProv  = context.watch<HistoryProvider>();
    final stats = statsProv.stats;

    if (histProv.loading || stats == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Calcul des pourcentages pour le PieChart.
    final pctAutorise = stats.pctAutorise;
    final pctRefuse   = stats.pctRefuse;

    // Valeur maximale des 7 derniers jours (pour normaliser les barres).
    final maxCount = stats.last7Days
        .map((d) => d.count)
        .fold(0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // 3 KPIs
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total scans',
                  value: '${stats.total}',
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Autorises',
                  value: '${stats.autorises}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Refuses',
                  value: '${stats.refuses + stats.expires}',
                  icon: Icons.cancel_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // PieChart
          _sectionLabel('REPARTITION DES VEHICULES'),
          const SizedBox(height: 14),
          Container(
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
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: stats.total == 0
                      ? Center(
                          child: Text(
                            'Aucune donnee',
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.muted),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 48,
                            sections: [
                              PieChartSectionData(
                                value: pctAutorise,
                                title: '${pctAutorise.toInt()}%',
                                color: AppColors.primary,
                                radius: 70,
                                titleStyle: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              PieChartSectionData(
                                value: pctRefuse > 0 ? pctRefuse : 0.01,
                                title: pctRefuse > 0
                                    ? '${pctRefuse.toInt()}%'
                                    : '',
                                color: AppColors.primaryLight,
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
                    _legendItem(AppColors.primary, 'Autorises',
                        '${pctAutorise.toInt()}%'),
                    const SizedBox(width: 24),
                    _legendItem(AppColors.primaryLight, 'Refuses',
                        '${pctRefuse.toInt()}%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Graphique barres 7 jours
          _sectionLabel('SCANS PAR JOUR (7 derniers jours)'),
          const SizedBox(height: 14),
          Container(
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.last7Days.map((day) {
                final pct = maxCount > 0 ? day.count / maxCount : 0.0;
                return _bar(day.label, pct.clamp(0.05, 1.0));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(
        t,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 1.0,
        ),
      );

  Widget _legendItem(Color c, String label, String pct) {
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
          '$label $pct',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _bar(String day, double pct) {
    const maxH = 90.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
}
