import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';

/// Écran des paramètres — profil, thème, langue, déconnexion.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user      = context.watch<AuthProvider>().user;
    final isDark    = context.watch<ThemeProvider>().isDark;
    final isArabic  = context.watch<LocaleProvider>().isArabic;
    final c         = context.colors;
    final l         = context.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.parametres,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.configSysteme,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: c.muted,
            ),
          ),
          const SizedBox(height: 24),

          _sectionLabel(l.sectionProfil, c),
          const SizedBox(height: 10),
          _profileCard(context, user, c, l),
          const SizedBox(height: 24),

          _sectionLabel(l.sectionApparence, c),
          const SizedBox(height: 10),
          _card(
            c: c,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: isDark ? const Color(0xFF8B5CF6) : AppColors.warning,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDark ? l.modeSombre : l.modeClair,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                      Text(
                        l.apparenceDesc,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDark,
                  onChanged: (_) => context.read<ThemeProvider>().toggle(),
                  activeColor: AppColors.green,
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.green.withValues(alpha: 0.3)
                        : c.border,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionLabel(l.sectionLangue, c),
          const SizedBox(height: 10),
          _card(
            c: c,
            child: Row(
              children: [
                Expanded(child: _langOption(context, l.francais, false, isArabic, c)),
                const SizedBox(width: 10),
                Expanded(child: _langOption(context, l.arabe, true, isArabic, c)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionLabel(l.sectionAPropos, c),
          const SizedBox(height: 10),
          _card(
            c: c,
            child: Column(
              children: [
                _infoRow(Icons.info_outline_rounded,  l.application,  'ALPR Mobile',         c),
                _infoRow(Icons.tag_rounded,            l.version,      '1.0.0',               c),
                _infoRow(Icons.business_rounded,       l.organisation, 'Algerie Telecom',     c),
                _infoRow(Icons.code_rounded,           l.stack,        'Flutter + Laravel 12',c),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: c.redTint,
              ),
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
              label: Text(
                l.seDeconnecter,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // ── Carte profil ────────────────────────────────────────────────────────────

  Widget _profileCard(BuildContext context, UserModel? user,
      AppColorsScheme c, AppLocalizations l) {
    final initials  = user?.initials ?? '?';
    final fullName  = user?.fullName ?? 'Agent';
    final email     = user?.email ?? '';
    final telephone = user?.telephone ?? '';
    final statut    = user?.statut ?? 'Actif';
    final isActif   = statut == 'Actif';

    return _card(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    initials,
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
                      fullName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.okBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l.agentSecurite,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.okText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActif ? c.greenTint : c.redTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statut,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isActif
                                  ? AppColors.green
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 14),
          if (email.isNotEmpty) ...[
            _infoRow(Icons.email_outlined, l.email, email, c),
            const SizedBox(height: 8),
          ],
          if (telephone.isNotEmpty) ...[
            _infoRow(Icons.phone_outlined, l.telephone, telephone, c),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: user == null
                  ? null
                  : () => _openEditSheet(context, user, c, l),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c.border, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.primary, size: 16),
              label: Text(
                l.modifierProfil,
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

  Future<void> _openEditSheet(BuildContext context, UserModel user,
      AppColorsScheme c, AppLocalizations l) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(user: user),
    );
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.profilMisAJour,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        ),
      );
    }
  }

  // ── Widgets utilitaires ─────────────────────────────────────────────────────

  Widget _langOption(BuildContext context, String label, bool isArabic,
      bool currentIsArabic, AppColorsScheme c) {
    final active = currentIsArabic == isArabic;
    return GestureDetector(
      onTap: () => context.read<LocaleProvider>().setArabic(isArabic),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? c.greenTint : c.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppColors.green : c.border,
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
                color: active ? AppColors.green : c.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.green : c.muted,
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

  Widget _infoRow(IconData icon, String label, String value, AppColorsScheme c) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: c.text,
          ),
        ),
      ],
    );
  }

  Widget _card({required AppColorsScheme c, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.white,
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

  Widget _sectionLabel(String t, AppColorsScheme c) => Text(
        t,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: c.muted,
          letterSpacing: 1.0,
        ),
      );
}

// ── Bottom sheet d'édition du profil ──────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});

  final UserModel user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telCtrl;

  bool    _saving      = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nomCtrl    = TextEditingController(text: widget.user.nom);
    _prenomCtrl = TextEditingController(text: widget.user.prenom);
    _emailCtrl  = TextEditingController(text: widget.user.email ?? '');
    _telCtrl    = TextEditingController(text: widget.user.telephone ?? '');
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _errorMessage = null; });

    final error = await context.read<AuthProvider>().updateProfile(
      nom:       _nomCtrl.text.trim(),
      prenom:    _prenomCtrl.text.trim(),
      email:     _emailCtrl.text.trim(),
      telephone: _telCtrl.text.trim().isEmpty ? null : _telCtrl.text.trim(),
    );

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _saving = false; _errorMessage = error; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final c = context.colors;
    final l = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.modifierProfil,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: c.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.modificationsServeur,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _field(l.nom,    _nomCtrl,    c, l, required: true)),
                const SizedBox(width: 12),
                Expanded(child: _field(l.prenom, _prenomCtrl, c, l, required: true)),
              ],
            ),
            const SizedBox(height: 12),
            _field(l.email, _emailCtrl, c, l,
              required: true,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.champObligatoire;
                if (!v.contains('@')) return l.emailInvalide;
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(l.telephoneOptionnel, _telCtrl, c, l,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _readOnlyField(l.role, widget.user.role, c, l),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.redTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l.annuler,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600, color: c.muted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l.enregistrer,
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    AppColorsScheme c,
    AppLocalizations l, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 13, color: c.text, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted),
        filled: true,
        fillColor: c.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty)
                  ? l.champObligatoire
                  : null
              : null),
    );
  }

  Widget _readOnlyField(String label, String value, AppColorsScheme c,
      AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: c.text),
          ),
          const SizedBox(width: 6),
          Icon(Icons.lock_outline, size: 14, color: c.muted),
        ],
      ),
    );
  }
}
