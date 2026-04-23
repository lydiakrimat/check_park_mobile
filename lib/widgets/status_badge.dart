import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Badge de statut d'accès : Autorisé | Refusé | Expiré.
class StatusBadge extends StatelessWidget {
  final String status; // 'Autorise' | 'Refuse' | 'Expire'

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
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

  _BadgeCfg _config(String s) {
    switch (s) {
      case 'Autorise':
        return _BadgeCfg(
          bg: AppColors.okBg,
          textColor: AppColors.okText,
          label: 'Autorise',
          icon: Icons.check_circle_rounded,
        );
      case 'Refuse':
        return _BadgeCfg(
          bg: AppColors.noBg,
          textColor: AppColors.noText,
          label: 'Refuse',
          icon: Icons.cancel_rounded,
        );
      default: // Expire
        return _BadgeCfg(
          bg: AppColors.expBg,
          textColor: AppColors.expText,
          label: 'Expire',
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
