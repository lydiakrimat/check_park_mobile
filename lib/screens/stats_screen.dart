import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
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
            'Tableau de bord des scans',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 20),

          // ── 3 cartes KPI ──
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Scanner',
                  value: '${MockData.statTotalScans}',
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Existant',
                  value: '${MockData.statExisting}',
                  icon: Icons.directions_car_rounded,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Inexistant',
                  value: '${MockData.statNonExisting}',
                  icon: Icons.no_transfer_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Graphique circulaire ──
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
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 48,
                      sections: [
                        PieChartSectionData(
                          value: MockData.pieExistingPct,
                          title:
                              '${MockData.pieExistingPct.toInt()}%',
                          color: AppColors.primary,
                          radius: 70,
                          titleStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        PieChartSectionData(
                          value: MockData.pieNonExistingPct,
                          title:
                              '${MockData.pieNonExistingPct.toInt()}%',
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
                // Légende
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem(AppColors.primary, 'Existant',
                        '${MockData.pieExistingPct.toInt()}%'),
                    const SizedBox(width: 24),
                    _legendItem(AppColors.primaryLight, 'Inexistant',
                        '${MockData.pieNonExistingPct.toInt()}%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Graphique barres simples ──
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
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bar('Lun', 0.55),
                    _bar('Mar', 0.80),
                    _bar('Mer', 0.40),
                    _bar('Jeu', 0.90),
                    _bar('Ven', 0.65),
                    _bar('Sam', 0.25),
                    _bar('Dim', 0.15),
                  ],
                ),
              ],
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
