import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge affiché uniquement pour les véhicules temporaires (visiteurs).
///
/// Entrée temporaire : fond ambre, icône horloge — "accès limité".
/// Sortie temporaire : fond gris, icône check — "visite terminée".
class BadgeVehiculeTemporaire extends StatelessWidget {
  /// 'entree' ou 'sortie'
  final String typePassage;

  /// true si la langue active est l'arabe
  final bool isArabic;

  const BadgeVehiculeTemporaire({
    super.key,
    required this.typePassage,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isSortie = typePassage == 'sortie';

    final bgColor   = isSortie ? const Color(0xFFF3F4F6) : const Color(0xFFFEF3C7);
    final textColor = isSortie ? const Color(0xFF374151) : const Color(0xFF92400E);
    final icon      = isSortie ? Icons.check_circle_outline_rounded : Icons.access_time_rounded;

    final label = isSortie
        ? (isArabic ? 'تم تسجيل الخروج — انتهت الزيارة' : 'Sortie enregistrée — visite terminée')
        : (isArabic ? 'مركبة مؤقتة — وصول محدود' : 'Véhicule temporaire — accès limité');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
