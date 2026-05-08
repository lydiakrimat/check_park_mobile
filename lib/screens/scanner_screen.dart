import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../l10n/app_localizations.dart';
import '../providers/scan_provider.dart';
import '../models/scan_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';

/// Écran de scan par caméra.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineCtrl;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _lineAnim =
        CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().initCamera();
    });
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    context.read<ScanProvider>().disposeCamera();
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

  Widget _buildCameraView(ScanProvider scanProv) {
    final screenH     = MediaQuery.of(context).size.height;
    final cameraCtrl  = scanProv.camera.controller;
    final cameraReady = scanProv.camera.isInitialized && cameraCtrl != null;
    final c           = context.colors;
    final l           = context.l10n;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: screenH * 0.55,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (cameraReady)
                ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: screenH * 0.55 /
                            cameraCtrl.value.aspectRatio,
                        height: screenH * 0.55,
                        child: CameraPreview(cameraCtrl),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  color: const Color(0xFF0A0E1A),
                  child: CustomPaint(
                    size: Size(double.infinity, screenH * 0.55),
                    painter: _GridPainter(),
                  ),
                ),

              Container(
                width: 280,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.greenLight, width: 2),
                  color: AppColors.green.withValues(alpha: 0.08),
                ),
                child: Stack(
                  children: [
                    ..._buildCorners(),
                    if (!scanProv.hasDone)
                      AnimatedBuilder(
                        animation: _lineAnim,
                        builder: (_, __) => Positioned(
                          top: 10 + (_lineAnim.value * 110),
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

              if (!cameraReady && !scanProv.hasError)
                const Positioned(
                  bottom: 50,
                  child: CircularProgressIndicator(
                    color: AppColors.greenLight, strokeWidth: 2,
                  ),
                ),

              if (cameraReady)
                Positioned(
                  bottom: 60,
                  child: Text(
                    l.placerPlaque,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

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

  List<Widget> _buildCorners() {
    const c = AppColors.greenLight;
    const t = 3.0;
    const s = 20.0;
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

  Widget _buildScanButton(ScanProvider scanProv) {
    final isSending = scanProv.isSending;
    final hasError  = scanProv.hasError;
    final c         = context.colors;
    final l         = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
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
                onPressed:
                    (isSending || !scanProv.camera.isInitialized)
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
                  isSending
                      ? l.analyseEnCoursBtn
                      : l.capturerEtScanner,
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

  Widget _buildResult(ScanResult r) {
    final isOk = r.authorized;
    final plate = r.displayPlate;
    final c = context.colors;
    final l = context.l10n;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
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
                    _detailRow(l.marque,         r.vehicle!.brand!, c),
                  if (r.vehicle?.color != null)
                    _detailRow(l.couleur,        r.vehicle!.color!, c),
                  if (r.owner != null)
                    _detailRow(l.proprietaire,   r.owner!.fullName, c),
                  if (r.owner?.service != null)
                    _detailRow(l.service,        r.owner!.service!, c),
                  if (!isOk && r.reason != null)
                    _detailRow(l.raison,         r.reason!, c),
                  if (!r.detected)
                    _detailRow(l.statutPlaque,   l.plaqueNonDetectee, c),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: OutlinedButton.icon(
              onPressed: () => context.read<ScanProvider>().reset(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: AppColors.primary, width: 1.5),
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

  Widget _detailRow(String key, String value, AppColorsScheme c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
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
