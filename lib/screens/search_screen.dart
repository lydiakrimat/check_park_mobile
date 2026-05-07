import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/scan_result.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/daily_counter_service.dart';
import '../services/search_service.dart';
import '../theme/app_colors.dart';

/// Ecran de recherche manuelle par numero de plaque.
///
/// L'agent saisit un numero de plaque au clavier.
/// L'app interroge le AI Service via POST /verify-lookup (consultation pure,
/// sans enregistrement en BDD) et affiche les infos du vehicule.
///
/// Si le vehicule est autorise, un bouton "Valider l'entree" apparait.
/// L'enregistrement dans la table acces n'est effectue qu'apres confirmation
/// explicite de l'agent via le dialog de confirmation.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  // Service de recherche — cree dans initState avec le token courant.
  late final SearchService _searchService;

  // Etat de la consultation vehicule.
  bool        _isSearching  = false;
  ScanResult? _result;
  String?     _errorMessage;

  // Identifiants conserves apres la consultation pour l'enregistrement d'acces.
  int? _vehicleId;
  int? _employeeId;

  // Etat de l'enregistrement d'acces (spinner pendant la requete POST /api/acces).
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    // Injection du token d'authentification depuis AuthProvider.
    _searchService = SearchService(
      ApiService(getToken: context.read<AuthProvider>().getToken),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Reinitialise l'etat de la recherche (resultat, erreur, IDs).
  void _resetResult() {
    setState(() {
      _result       = null;
      _errorMessage = null;
      _vehicleId    = null;
      _employeeId   = null;
    });
  }

  /// Lance la consultation vehicule via POST /verify-lookup.
  /// Ne cree aucun enregistrement en BDD.
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
      // Incremente le compteur de scans pour chaque recherche manuelle reussie.
      unawaited(DailyCounterService.incrementScans());
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Erreur inattendue lors de la recherche.');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  /// Affiche le dialog de confirmation puis enregistre l'acces si confirme.
  Future<void> _showConfirmDialog() async {
    if (_vehicleId == null) return;
    final plate = _result?.displayPlate ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (bCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmer l\'acces',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Voulez-vous enregistrer l\'entree du vehicule $plate ?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.text,
          ),
        ),
        actions: [
          // Bouton Annuler — ferme le dialog sans rien faire.
          TextButton(
            onPressed: () => Navigator.of(bCtx).pop(false),
            child: Text(
              'Annuler',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          // Bouton Confirmer — ferme le dialog et declenche l'enregistrement.
          ElevatedButton(
            onPressed: () => Navigator.of(bCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Confirmer',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;
    await _registerAccess();
  }

  /// Enregistre l'acces en BDD via POST /api/acces.
  /// Appele uniquement apres confirmation dans le dialog.
  Future<void> _registerAccess() async {
    if (_vehicleId == null) return;
    setState(() => _isRegistering = true);

    try {
      await _searchService.registerAccess(_vehicleId!, _employeeId);
      // Incremente le compteur d'acces autorises apres confirmation reussie.
      unawaited(DailyCounterService.incrementAutorises());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Acces enregistre avec succes',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'enregistrement de l\'acces',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Recherche matricule',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Saisir le numero de matricule du vehicule',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 18),

          // Champ de saisie + bouton Rechercher
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'Ex: ALG288',
                    filled: true,
                    fillColor: AppColors.white,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(13),
                      child: Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    // Bouton effacer le champ et reinitialiser le resultat.
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _ctrl.clear();
                              _resetResult();
                            },
                            child: const Icon(Icons.clear_rounded,
                                color: AppColors.muted, size: 18),
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.border, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 4),
                  ),
                  onChanged: (_) => setState(() {}), // rafraichit le bouton clear
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            'Rechercher',
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

          // Separateur
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'RESULTAT DE RECHERCHE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Contenu selon l'etat
          if (_errorMessage != null)
            _errorState(_errorMessage!)
          else if (_result != null)
            _resultCard(_result!)
          else
            _emptyState(),

          // Bouton "Valider l'entree" — visible uniquement si le vehicule est autorise.
          // N'apparait pas pour les vehicules refuses ou inconnus.
          if (_result != null && _result!.authorized)
            _validateButton(),
        ],
      ),
    );
  }

  /// Bouton de validation de l'entree — affiche un spinner pendant l'enregistrement.
  Widget _validateButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isRegistering
                  ? [AppColors.primary.withValues(alpha: 0.5),
                     AppColors.primaryDark.withValues(alpha: 0.5)]
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
              _isRegistering ? 'Enregistrement...' : 'Valider l\'entree',
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

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 32, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun resultat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Saisissez un matricule et appuyez sur Rechercher',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.noBg,
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

  Widget _resultCard(ScanResult r) {
    final isOk = r.authorized;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
          // En-tete colore selon le statut d'autorisation.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isOk ? AppColors.greenTint : AppColors.redTint,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOk ? AppColors.okBg : AppColors.noBg,
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
                          color: AppColors.text,
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
                    color: isOk ? AppColors.okBg : AppColors.noBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOk ? 'Autorise' : 'Refuse',
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

          // Tableau de donnees du vehicule.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (r.displayPlate.isNotEmpty)
                  _row('Matricule', r.displayPlate),
                if (r.vehicle?.brand != null)
                  _row('Marque', r.vehicle!.brand!),
                if (r.vehicle?.color != null)
                  _row('Couleur', r.vehicle!.color!),
                if (r.owner != null)
                  _row('Proprietaire', r.owner!.fullName),
                if (r.owner?.service != null)
                  _row('Service', r.owner!.service!),
                if (r.similarityScore != null)
                  _row('Similarite',
                      '${(r.similarityScore! * 100).toStringAsFixed(0)}%'),
                if (!r.detected)
                  _row('Statut', 'Plaque non trouvee en base'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
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
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
