import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../l10n/app_localizations.dart';
import '../providers/scan_provider.dart';
import '../models/scan_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';
import '../utils/responsive.dart';
import '../widgets/temporaire_result_card.dart';
import '../widgets/badge_type_passage.dart';
import '../widgets/badge_vehicule_temporaire.dart';
import '../providers/locale_provider.dart';

/// Ecran de scan par camera.
///
/// Flux principal :
///   1. La camera s'initialise via ScanProvider.initCamera()
///   2. L'agent cadre l'arriere du vehicule dans le grand cadre guide
///   3. Appui sur le bouton → captureAndScan() : photo + envoi AI Service
///   4. Pendant l'envoi (2-5s) : overlay de chargement sur la preview
///   5. Resultat affiché : vert (autorise), rouge (refuse), orange (non detectee)
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineCtrl;
  late Animation<double> _lineAnim;

  // Reference au provider conservee pour un usage sur dans dispose().
  // dispose() est appele apres la deconnexion du widget de l'arbre de widgets ;
  // appeler context.read() a ce stade peut lever une exception selon la version
  // Flutter. Ce cache evite le probleme "Looking up a deactivated widget's ancestor".
  ScanProvider? _scanProv;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _lineAnim = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Cache la reference avant le premier build asynchrone.
      _scanProv = context.read<ScanProvider>();
      _scanProv!.initCamera();
    });
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    // Utiliser la reference cachee — pas d'acces a context apres deactivation.
    _scanProv?.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanProv = context.watch<ScanProvider>();
    final bool hasDone = scanProv.hasDone;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraView(scanProv),

          // Bouton retour (coin superieur gauche, par-dessus la preview).
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  scanProv.reset();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ),

          // Panneau bas : bouton de capture OU resultat.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: hasDone
                ? _buildResult(scanProv.result!)
                : _buildScanButton(scanProv),
          ),
        ],
      ),
    );
  }

  // ── Preview camera + cadre guide + overlay chargement ──────────────────────

  Widget _buildCameraView(ScanProvider scanProv) {
    final size        = MediaQuery.of(context).size;
    final previewH    = size.height * 0.55;
    // Cadre guide : grand pour contenir l'arriere du vehicule entier.
    // Le modele YOLOX est entraine sur des photos de voitures entieres.
    final frameW      = size.width * 0.82;
    final frameH      = previewH * 0.55;
    final cameraCtrl  = scanProv.camera.controller;
    final cameraReady = scanProv.camera.isInitialized && cameraCtrl != null;
    final isSending   = scanProv.isSending;
    final c           = context.colors;
    final l           = context.l10n;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: previewH,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera preview (ou grille si non initialisee).
              if (cameraReady)
                ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: previewH / cameraCtrl.value.aspectRatio,
                        height: previewH,
                        child: CameraPreview(cameraCtrl),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  color: const Color(0xFF0A0E1A),
                  child: CustomPaint(
                    size: Size(double.infinity, previewH),
                    painter: _GridPainter(),
                  ),
                ),

              // Cadre guide vehicule — coins uniquement, sans fond opaque.
              // L'agent doit cadrer l'arriere du vehicule dans ce rectangle.
              SizedBox(
                width: frameW,
                height: frameH,
                child: Stack(
                  children: [
                    ..._buildCorners(),
                    // Ligne de scan animee traversant le cadre verticalement.
                    if (!scanProv.hasDone && !isSending)
                      AnimatedBuilder(
                        animation: _lineAnim,
                        builder: (_, __) => Positioned(
                          top: 10 + (_lineAnim.value * (frameH - 20)),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.transparent,
                                AppColors.greenLight,
                                Colors.transparent,
                              ]),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Overlay de chargement — visible pendant l'envoi de la photo au AI Service.
              // Le traitement YOLOX + OCR + fuzzy matching prend 2-5 secondes sur CPU.
              // Cet overlay empeche l'agent d'appuyer a nouveau pendant ce delai.
              if (isSending)
                Container(
                  width: double.infinity,
                  height: previewH,
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          color: AppColors.greenLight,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.analyseEnCours,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Indicateur de demarrage camera (avant initialisation).
              if (!cameraReady && !scanProv.hasError && !isSending)
                const Positioned(
                  bottom: 50,
                  child: CircularProgressIndicator(
                    color: AppColors.greenLight, strokeWidth: 2,
                  ),
                ),

              // Texte guide : encourage l'agent a cadrer l'arriere du vehicule.
              // Rappel important car YOLOX performe mieux sur le vehicule entier.
              if (cameraReady && !isSending)
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l.cadrerVehicule,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Message d'erreur camera (ex: permission refusee).
              if (scanProv.hasError && !scanProv.hasDone)
                Positioned(
                  bottom: 55,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      scanProv.errorMessage ?? 'Erreur camera',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: Container(color: c.background)),
      ],
    );
  }

  // ── Coins du cadre guide ────────────────────────────────────────────────────

  List<Widget> _buildCorners() {
    const c = AppColors.greenLight;
    const t = 3.0;
    const s = 24.0;
    return [
      Positioned(
          top: 0, left: 0,
          child: _corner(
              const BorderRadius.only(topLeft: Radius.circular(12)),
              c, t, s, top: true, left: true)),
      Positioned(
          top: 0, right: 0,
          child: _corner(
              const BorderRadius.only(topRight: Radius.circular(12)),
              c, t, s, top: true, right: true)),
      Positioned(
          bottom: 0, left: 0,
          child: _corner(
              const BorderRadius.only(bottomLeft: Radius.circular(12)),
              c, t, s, bottom: true, left: true)),
      Positioned(
          bottom: 0, right: 0,
          child: _corner(
              const BorderRadius.only(bottomRight: Radius.circular(12)),
              c, t, s, bottom: true, right: true)),
    ];
  }

  Widget _corner(BorderRadius br, Color c, double t, double s,
      {bool top = false,
      bool bottom = false,
      bool left = false,
      bool right = false}) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        border: Border(
          top:    top    ? BorderSide(color: c, width: t) : BorderSide.none,
          bottom: bottom ? BorderSide(color: c, width: t) : BorderSide.none,
          left:   left   ? BorderSide(color: c, width: t) : BorderSide.none,
          right:  right  ? BorderSide(color: c, width: t) : BorderSide.none,
        ),
        borderRadius: br,
      ),
    );
  }

  // ── Panneau bas : bouton de capture ────────────────────────────────────────

  Widget _buildScanButton(ScanProvider scanProv) {
    final isSending = scanProv.isSending;
    final hasError  = scanProv.hasError;
    final c         = context.colors;
    final l         = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            l.scannerUnePlaqueTitle,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSending
                ? l.analyseEnCours
                : hasError
                    ? scanProv.errorMessage ?? 'Erreur lors du scan'
                    : l.appuyerPourCapture,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: hasError ? AppColors.danger : c.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.green, AppColors.greenDark]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: (isSending || !scanProv.camera.isInitialized)
                    ? null
                    : () => scanProv.captureAndScan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 20),
                label: Text(
                  isSending ? l.analyseEnCoursBtn : l.capturerEtScanner,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Panneau bas : resultat du scan ─────────────────────────────────────────

  /// Affiche le resultat selon 3 etats :
  ///   - detected == false → panneau orange "aucune plaque detectee"
  ///   - detected == true && authorized == true → panneau vert "AUTORISE"
  ///   - detected == true && authorized == false → panneau rouge "REFUSE"
  Widget _buildResult(ScanResult r) {
    // Cas 1 : YOLOX n'a pas detecte de plaque dans l'image.
    // Peut arriver si le vehicule est mal cadre, la photo floue, ou trop loin.
    if (!r.detected) {
      return _buildNotDetected();
    }

    // Cas 2 : vehicule temporaire — affichage specifique visiteur.
    if (r.isTemporaire) {
      return TemporaireResultCard(result: r);
    }

    // Cas 3 et 4 : plaque detectee — autorisee ou refusee.
    final isOk  = r.authorized;
    final plate = r.displayPlate;
    final c     = context.colors;
    final l     = context.l10n;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Plaque affichee avec style immatriculation (monospace, fond sombre).
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: c.text,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    plate.isEmpty ? '???' : plate,
                    style: const TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenLight,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOk ? c.okBg : c.noBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOk ? Icons.check_rounded : Icons.close_rounded,
                    color: isOk ? AppColors.okText : AppColors.noText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isOk ? l.autorise : l.refuse,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isOk ? AppColors.okText : AppColors.noText,
                  ),
                ),
              ],
            ),
          ),
          // Badge type de passage (entrée/sortie) — affiché si disponible
          if (r.typePassage != null && isOk) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BadgeTypePassage(
                typePassage: r.typePassage!,
                isArabic: context.read<LocaleProvider>().isArabic,
              ),
            ),
          ],
          // Badge véhicule temporaire — affiché uniquement pour les visiteurs
          if (r.typePassage != null && r.isTemporaire) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BadgeVehiculeTemporaire(
                typePassage: r.typePassage!,
                isArabic: context.read<LocaleProvider>().isArabic,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  if (r.plateOcr != null)
                    _detailRow(l.ocrLu,         r.plateOcr!, c),
                  if (r.plateMatched != null)
                    _detailRow(l.correspondance, r.plateMatched!, c),
                  if (r.similarityScore != null)
                    _detailRow(l.similarite,
                        '${(r.similarityScore! * 100).toStringAsFixed(0)}%', c),
                  if (r.vehicle?.brand != null)
                    _detailRow(l.marque,        r.vehicle!.brand!, c),
                  if (r.vehicle?.color != null)
                    _detailRow(l.couleur,       r.vehicle!.color!, c),
                  if (r.owner != null)
                    _detailRow(l.proprietaire,  r.owner!.fullName, c),
                  if (r.owner?.service != null)
                    _detailRow(l.service,       r.owner!.service!, c),
                  if (!isOk && r.reason != null)
                    _detailRow(l.raison,        r.reason!, c),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: OutlinedButton.icon(
              onPressed: () => context.read<ScanProvider>().reset(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary, size: 18),
              label: Text(
                l.scannerUnAutre,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Panneau orange : YOLOX n'a pas detecte de plaque dans l'image.
  /// Invite l'agent a reessayer en cadrant mieux l'arriere du vehicule.
  Widget _buildNotDetected() {
    final c = context.colors;
    final l = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Icone et badge orange.
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.image_search_rounded,
                color: AppColors.warning, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            l.plaqueNonDetectee,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.aucunePlaqueMsg,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: c.muted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => context.read<ScanProvider>().reset(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.warning, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: Icon(Icons.refresh_rounded,
                color: AppColors.warning, size: 18),
            label: Text(
              l.scannerUnAutre,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String key, String value, AppColorsScheme c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: Responsive.rw(context, 110),
            child: Text(
              key,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fond grille sombre affiche pendant l'initialisation de la camera.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
