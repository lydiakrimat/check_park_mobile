import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/scan_result.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/daily_counter_service.dart';
import '../services/search_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';

/// Ecran de recherche manuelle par numero de plaque.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  late final SearchService _searchService;

  bool        _isSearching  = false;
  ScanResult? _result;
  String?     _errorMessage;

  int? _vehicleId;
  int? _employeeId;

  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _searchService = SearchService(
      ApiService(getToken: context.read<AuthProvider>().getToken),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _resetResult() {
    setState(() {
      _result       = null;
      _errorMessage = null;
      _vehicleId    = null;
      _employeeId   = null;
    });
  }

  Future<void> _search() async {
    if (_ctrl.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching  = true;
      _result       = null;
      _errorMessage = null;
      _vehicleId    = null;
      _employeeId   = null;
    });

    try {
      final lookup = await _searchService.lookupVehicle(_ctrl.text.trim());
      setState(() {
        _result     = lookup.scanResult;
        _vehicleId  = lookup.vehicleId;
        _employeeId = lookup.employeeId;
      });
      unawaited(DailyCounterService.incrementScans());
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() =>
          _errorMessage = 'Erreur inattendue lors de la recherche.');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _showConfirmDialog() async {
    if (_vehicleId == null) return;
    final plate = _result?.displayPlate ?? '';
    final l = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (bCtx) {
        final cl = bCtx.colors;
        return AlertDialog(
          backgroundColor: cl.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            l.confirmerAcces,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: cl.text,
            ),
          ),
          content: Text(
            l.confirmerMsg(plate),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: cl.text,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(bCtx).pop(false),
              child: Text(
                l.annuler,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: cl.muted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(bCtx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              child: Text(
                l.confirmer,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;
    await _registerAccess();
  }

  Future<void> _registerAccess() async {
    if (_vehicleId == null) return;
    setState(() => _isRegistering = true);
    final l = context.l10n;

    try {
      await _searchService.registerAccess(_vehicleId!, _employeeId);
      unawaited(DailyCounterService.incrementAutorises());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.accesEnregistre,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.erreurEnregistrement,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.rechercheMatricule,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.saisirNumero,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: c.muted),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: c.text),
                  decoration: InputDecoration(
                    hintText: 'Ex: ALG288',
                    filled: true,
                    fillColor: c.white,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _ctrl.clear();
                              _resetResult();
                            },
                            child: Icon(Icons.clear_rounded,
                                color: c.muted, size: 18),
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.border, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 4),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            l.rechercher,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l.resultRecherche,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: c.muted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null)
            _errorState(_errorMessage!, c)
          else if (_result != null)
            _resultCard(_result!, c, l)
          else
            _emptyState(c, l),

          if (_result != null && _result!.authorized)
            _validateButton(c, l),

          SizedBox(height: MediaQuery.of(context).padding.bottom),

        ],
        
      ),

    );
  }

  Widget _validateButton(AppColorsScheme c, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isRegistering
                  ? [
                      AppColors.primary.withValues(alpha: 0.5),
                      AppColors.primaryDark.withValues(alpha: 0.5),
                    ]
                  : [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton.icon(
            onPressed: _isRegistering ? null : _showConfirmDialog,
            icon: _isRegistering
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white, size: 20),
            label: Text(
              _isRegistering ? l.enregistrement : l.validerEntree,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(AppColorsScheme c, AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.background,
                shape: BoxShape.circle,
                border: Border.all(color: c.border),
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 32, color: c.muted),
            ),
            const SizedBox(height: 16),
            Text(
              l.aucunResultatMsg,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.saisirMatricule,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: c.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String message, AppColorsScheme c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.noBg,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 32, color: AppColors.danger),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(ScanResult r, AppColorsScheme c, AppLocalizations l) {
    final isOk = r.authorized;

    return Container(
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F2F5A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isOk ? c.greenTint : c.redTint,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOk ? c.okBg : c.noBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOk ? Icons.check_rounded : Icons.close_rounded,
                    color: isOk ? AppColors.okText : AppColors.noText,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        r.owner?.fullName ?? r.displayPlate,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                        ),
                      ),
                      if (r.owner?.service != null)
                        Text(
                          r.owner!.service!,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: AppColors.primary),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOk ? c.okBg : c.noBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOk ? l.autorise : l.refuse,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isOk ? AppColors.okText : AppColors.noText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (r.displayPlate.isNotEmpty)
                  _row(l.matricule, r.displayPlate, c),
                if (r.vehicle?.brand != null)
                  _row(l.marque, r.vehicle!.brand!, c),
                if (r.vehicle?.color != null)
                  _row(l.couleur, r.vehicle!.color!, c),
                if (r.owner != null)
                  _row(l.proprietaire, r.owner!.fullName, c),
                if (r.owner?.service != null)
                  _row(l.service, r.owner!.service!, c),
                if (r.similarityScore != null)
                  _row(l.similarite,
                      '${(r.similarityScore! * 100).toStringAsFixed(0)}%', c),
                if (!r.detected) _row(l.statutPlaque, l.plaqueNonTrouvee, c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String key, String value, AppColorsScheme c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              key,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
