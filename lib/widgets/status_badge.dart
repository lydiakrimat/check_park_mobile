import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';

/// Badge de statut d'accès : Autorisé | Refusé | Expiré.
class StatusBadge extends StatelessWidget {
  final String status; // 'Autorise' | 'Refuse' | 'Expire'

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final c   = context.colors;
    final l   = context.l10n;
    final cfg = _config(status, c, l);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 11, color: cfg.textColor),
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cfg.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeCfg _config(String s, AppColorsScheme c, AppLocalizations l) {
    switch (s) {
      case 'Autorise':
        return _BadgeCfg(
          bg: c.okBg,
          textColor: AppColors.okText,
          label: l.autorise,
          icon: Icons.check_circle_rounded,
        );
      case 'Refuse':
        return _BadgeCfg(
          bg: c.noBg,
          textColor: AppColors.noText,
          label: l.refuse,
          icon: Icons.cancel_rounded,
        );
      default: // Expire
        return _BadgeCfg(
          bg: c.expBg,
          textColor: AppColors.expText,
          label: l.expire,
          icon: Icons.access_time_rounded,
        );
    }
  }
}

class _BadgeCfg {
  final Color bg;
  final Color textColor;
  final String label;
  final IconData icon;
  const _BadgeCfg(
      {required this.bg,
      required this.textColor,
      required this.label,
      required this.icon});
}
