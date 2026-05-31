import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge indiquant le type de passage : entrée ou sortie.
///
/// Entrée : fond vert clair, texte vert foncé, icône login.
/// Sortie : fond bleu clair, texte bleu foncé, icône logout.
class BadgeTypePassage extends StatelessWidget {
  /// 'entree' ou 'sortie'
  final String typePassage;

  /// true si la langue active est l'arabe
  final bool isArabic;

  const BadgeTypePassage({
    super.key,
    required this.typePassage,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isSortie = typePassage == 'sortie';

    // Couleurs selon le type de passage
    final bgColor   = isSortie ? const Color(0xFFDBEAFE) : const Color(0xFFD1FAE5);
    final textColor = isSortie ? const Color(0xFF1E3A8A) : const Color(0xFF065F46);
    final icon      = isSortie ? Icons.logout_rounded     : Icons.login_rounded;

    // Texte bilingue
    final label = isSortie
        ? (isArabic ? 'تم تسجيل الخروج' : 'Sortie enregistrée')
        : (isArabic ? 'تم تسجيل الدخول' : 'Entrée enregistrée');

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
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
