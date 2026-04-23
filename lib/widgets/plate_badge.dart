import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Badge plaque d'immatriculation — monospace, fond #0D1F3C, texte vert.
class PlateBadge extends StatelessWidget {
  final String plate;
  final double fontSize;

  const PlateBadge({
    super.key,
    required this.plate,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        plate,
        style: TextStyle(
          fontFamily: 'Courier New',
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.greenLight,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
