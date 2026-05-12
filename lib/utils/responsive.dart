import 'package:flutter/material.dart';

/// Utilitaires pour le dimensionnement responsive.
///
/// Toutes les valeurs sont calculées proportionnellement à la largeur
/// ou la hauteur de l'écran, en prenant 390px comme référence (iPhone 14).
class Responsive {
  Responsive._();

  /// Largeur de référence utilisée pour le calcul proportionnel.
  static const double _refWidth = 390.0;

  /// Hauteur de référence utilisée pour le calcul proportionnel.
  static const double _refHeight = 844.0;

  /// Largeur totale de l'écran.
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Hauteur totale de l'écran.
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Valeur proportionnelle à la largeur de l'écran.
  /// Ex : `rw(context, 100)` retourne 100 sur un écran de 390px,
  /// et ~92 sur un écran de 360px.
  static double rw(BuildContext context, double value) =>
      value * width(context) / _refWidth;

  /// Valeur proportionnelle à la hauteur de l'écran.
  static double rh(BuildContext context, double value) =>
      value * height(context) / _refHeight;
}
