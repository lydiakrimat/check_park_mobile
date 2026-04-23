import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mock_data.dart';
import '../theme/app_colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _scanned = false;
  bool _scanning = false;

  late AnimationController _lineCtrl;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _lineAnim = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    super.dispose();
  }

  Future<void> _simulateScan() async {
    setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _scanned  = true;
    });
  }

  void _reset() => setState(() => _scanned = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Zone caméra simulée (fond noir + cadre de scan) ──
          _buildCameraView(),

          // ── Bouton retour ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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

          // ── Résultat ou bouton scan ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _scanned ? _buildResult() : _buildScanButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    final screenH = MediaQuery.of(context).size.height;
    return Column(
      children: [
        // Vue caméra (fond noir simulé)
        Container(
          width: double.infinity,
          height: screenH * 0.55,
          color: const Color(0xFF0A0E1A),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Grille simulée (effet caméra)
              CustomPaint(
                size: Size(double.infinity, screenH * 0.55),
                painter: _GridPainter(),
              ),

              // Cadre de scan
              Container(
                width: 280,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.greenLight,
                    width: 2,
                  ),
                  color: AppColors.green.withValues(alpha: 0.08),
                ),
                child: Stack(
                  children: [
                    // Coins
                    ..._buildCorners(),
                    // Ligne de scan animée
                    if (!_scanned)
                      AnimatedBuilder(
                        animation: _lineAnim,
                        builder: (_, __) => Positioned(
                          top: 10 + (_lineAnim.value * 110),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.greenLight,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Texte guide
              Positioned(
                bottom: 60,
                child: Text(
                  'Placez la plaque dans le cadre',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Container(color: AppColors.background)),
      ],
    );
  }

  List<Widget> _buildCorners() {
    const c = AppColors.greenLight;
    const t = 3.0;
    const s = 20.0;
    return [
      // TL
      Positioned(top: 0, left: 0,
          child: _corner(BorderRadius.only(topLeft: Radius.circular(12)), c, t, s, top: true, left: true)),
      // TR
      Positioned(top: 0, right: 0,
          child: _corner(BorderRadius.only(topRight: Radius.circular(12)), c, t, s, top: true, right: true)),
      // BL
      Positioned(bottom: 0, left: 0,
          child: _corner(BorderRadius.only(bottomLeft: Radius.circular(12)), c, t, s, bottom: true, left: true)),
      // BR
      Positioned(bottom: 0, right: 0,
          child: _corner(BorderRadius.only(bottomRight: Radius.circular(12)), c, t, s, bottom: true, right: true)),
    ];
  }

  Widget _corner(BorderRadius br, Color c, double t, double s,
      {bool top = false, bool bottom = false, bool left = false, bool right = false}) {
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

  Widget _buildScanButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      decoration: BoxDecoration(
        color: AppColors.background,
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
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Scanner une plaque',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Appuyez sur le bouton pour simuler un scan',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green, AppColors.greenDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: _scanning ? null : _simulateScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _scanning
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 20),
                label: Text(
                  _scanning ? 'Analyse en cours...' : 'Simuler un scan',
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

  Widget _buildResult() {
    final r = MockData.scanResult;
    final isOk = r.isAuthorized;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Plaque + statut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Plaque simulée
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.text,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r.plate,
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
                // Icône statut
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOk ? AppColors.okBg : AppColors.noBg,
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
                  isOk ? 'Autorise' : 'Refuse',
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

          // Tableau de détails
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: r.fields
                    .map((e) => _detailRow(e.key, e.value))
                    .toList(),
              ),
            ),
          ),

          // Bouton scanner un autre
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: OutlinedButton.icon(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary, size: 18),
              label: Text(
                'Scanner un autre',
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

  Widget _detailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              key,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
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
                color: AppColors.text,
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
