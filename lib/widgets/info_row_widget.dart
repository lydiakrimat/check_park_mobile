import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors_scheme.dart';

/// Widget reutilisable pour afficher une ligne d'information (label + valeur).
///
/// Gere le debordement du texte de la valeur via Expanded.
/// Utilise dans les pages Historique et Parametres pour uniformiser
/// l'affichage des paires label/valeur.
class InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String valeur;

  const InfoRow({
    super.key,
    this.icon,
    required this.label,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: const Color(0xFF004B93)),
          const SizedBox(width: 10),
        ],
        // Label a largeur flexible
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: c.muted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Valeur avec gestion du debordement
        Expanded(
          flex: 3,
          child: Text(
            valeur,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
            overflow: TextOverflow.visible,
            softWrap: true,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
