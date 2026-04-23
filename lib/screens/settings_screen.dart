import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _isArabic = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Configuration du système',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),

          // ── Profil ──
          _sectionLabel('PROFIL'),
          const SizedBox(height: 10),
          _profileCard(),
          const SizedBox(height: 24),

          // ── Apparence ──
          _sectionLabel('APPARENCE'),
          const SizedBox(height: 10),
          _card(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _darkMode
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _darkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: _darkMode
                        ? const Color(0xFF8B5CF6)
                        : AppColors.warning,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _darkMode ? 'Mode sombre' : 'Mode clair',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Choisir l\'apparence de l\'interface',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                  activeColor: AppColors.green,
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.green.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Langue ──
          _sectionLabel('LANGUE'),
          const SizedBox(height: 10),
          _card(
            child: Row(
              children: [
                Expanded(child: _langOption('Francais', false)),
                const SizedBox(width: 10),
                Expanded(child: _langOption('Arabe', true)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── A propos ──
          _sectionLabel('A PROPOS'),
          const SizedBox(height: 10),
          _card(
            child: Column(
              children: [
                _infoRow(
                  Icons.info_outline_rounded,
                  'Application',
                  'ALPR Mobile',
                ),
                _infoRow(Icons.tag_rounded, 'Version', '1.0.0'),
                // _infoRow(Icons.school_outlined, 'Projet',
                //     'Fin d\'Etudes'),
                _infoRow(
                  Icons.business_rounded,
                  'Organisation',
                  'Algérie Télécom',
                ),
                _infoRow(Icons.code_rounded, 'Stack', 'Flutter + Laravel 11'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Déconnexion ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.redTint,
              ),
              icon: const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              label: Text(
                'Se déconnecter',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return _card(
      child: Column(
        children: [
          // Avatar + infos
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'HY',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hamidi Yacine',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.okBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Agent de Sécurité',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.okText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _infoRow(Icons.email_outlined, 'Email', 'garde@algerietelecom.dz'),
          const SizedBox(height: 10),
          // Bouton modifier profil
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              label: Text(
                'Modifier le profil',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _langOption(String label, bool isArabic) {
    final active = _isArabic == isArabic;
    return GestureDetector(
      onTap: () => setState(() => _isArabic = isArabic),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.greenTint : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppColors.green : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              isArabic ? 'AR' : 'FR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: active ? AppColors.green : AppColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.green : AppColors.muted,
              ),
            ),
            if (active) ...[
              const SizedBox(height: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E0F2F5A),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String t) => Text(
    t,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
      letterSpacing: 1.0,
    ),
  );
}
