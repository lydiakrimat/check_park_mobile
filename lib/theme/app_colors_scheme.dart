import 'package:flutter/material.dart';

/// Extension de thème Flutter qui fournit les couleurs de surface/neutres
/// adaptées au mode clair et sombre.
///
/// Les couleurs de marque (primary, green, danger, warning, okText, noText…)
/// restent dans [AppColors] et ne changent pas entre les modes.
///
/// Usage : `context.colors.background`, `context.colors.white`, etc.
class AppColorsScheme extends ThemeExtension<AppColorsScheme> {
  const AppColorsScheme({
    required this.background,
    required this.white,
    required this.text,
    required this.muted,
    required this.border,
    required this.okBg,
    required this.noBg,
    required this.expBg,
    required this.blueTint,
    required this.greenTint,
    required this.orangeTint,
    required this.redTint,
  });

  // Fond de page (scaffold)
  final Color background;
  // Surface des cartes / panneaux
  final Color white;
  // Texte principal
  final Color text;
  // Texte secondaire / labels
  final Color muted;
  // Bordures
  final Color border;
  // Fonds des badges de statut
  final Color okBg;
  final Color noBg;
  final Color expBg;
  // Tints colorés pour les cartes
  final Color blueTint;
  final Color greenTint;
  final Color orangeTint;
  final Color redTint;

  // ── Palette claire ─────────────────────────────────────────────────────────

  static const light = AppColorsScheme(
    background:  Color(0xFFEEF2F7),
    white:       Color(0xFFFFFFFF),
    text:        Color(0xFF0D1F3C),
    muted:       Color(0xFF5E7491),
    border:      Color(0xFFD0DCEA),
    okBg:        Color(0xFFD1FAE5),
    noBg:        Color(0xFFFEE2E2),
    expBg:       Color(0xFFF3F4F6),
    blueTint:    Color(0xFFEFF6FF),
    greenTint:   Color(0xFFF0FDF4),
    orangeTint:  Color(0xFFFFFBEB),
    redTint:     Color(0xFFFEF2F2),
  );

  // ── Palette sombre ─────────────────────────────────────────────────────────

  static const dark = AppColorsScheme(
    background:  Color(0xFF0F1117),
    white:       Color(0xFF1A2035),
    text:        Color(0xFFE8EDF5),
    muted:       Color(0xFF8899B4),
    border:      Color(0xFF2A3850),
    okBg:        Color(0xFF0A2218),
    noBg:        Color(0xFF2A0F0F),
    expBg:       Color(0xFF1E2030),
    blueTint:    Color(0xFF0D1A2E),
    greenTint:   Color(0xFF091F12),
    orangeTint:  Color(0xFF2A1F00),
    redTint:     Color(0xFF2A0A0A),
  );

  // ── ThemeExtension boilerplate ─────────────────────────────────────────────

  @override
  AppColorsScheme copyWith({
    Color? background,
    Color? white,
    Color? text,
    Color? muted,
    Color? border,
    Color? okBg,
    Color? noBg,
    Color? expBg,
    Color? blueTint,
    Color? greenTint,
    Color? orangeTint,
    Color? redTint,
  }) {
    return AppColorsScheme(
      background:  background  ?? this.background,
      white:       white       ?? this.white,
      text:        text        ?? this.text,
      muted:       muted       ?? this.muted,
      border:      border      ?? this.border,
      okBg:        okBg        ?? this.okBg,
      noBg:        noBg        ?? this.noBg,
      expBg:       expBg       ?? this.expBg,
      blueTint:    blueTint    ?? this.blueTint,
      greenTint:   greenTint   ?? this.greenTint,
      orangeTint:  orangeTint  ?? this.orangeTint,
      redTint:     redTint     ?? this.redTint,
    );
  }

  @override
  AppColorsScheme lerp(covariant AppColorsScheme? other, double t) {
    if (other == null) return this;
    return AppColorsScheme(
      background:  Color.lerp(background,  other.background,  t)!,
      white:       Color.lerp(white,       other.white,       t)!,
      text:        Color.lerp(text,        other.text,        t)!,
      muted:       Color.lerp(muted,       other.muted,       t)!,
      border:      Color.lerp(border,      other.border,      t)!,
      okBg:        Color.lerp(okBg,        other.okBg,        t)!,
      noBg:        Color.lerp(noBg,        other.noBg,        t)!,
      expBg:       Color.lerp(expBg,       other.expBg,       t)!,
      blueTint:    Color.lerp(blueTint,    other.blueTint,    t)!,
      greenTint:   Color.lerp(greenTint,   other.greenTint,   t)!,
      orangeTint:  Color.lerp(orangeTint,  other.orangeTint,  t)!,
      redTint:     Color.lerp(redTint,     other.redTint,     t)!,
    );
  }
}

/// Accès raccourci aux couleurs de surface depuis n'importe quel build().
///
///   final c = context.colors;
///   Container(color: c.white)
extension AppColorsX on BuildContext {
  AppColorsScheme get colors =>
      Theme.of(this).extension<AppColorsScheme>()!;
}
