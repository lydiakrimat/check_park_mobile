import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../models/scan_result.dart';
import '../theme/app_colors.dart';

/// Écran de recherche manuelle par numéro de plaque.
///
/// L'agent saisit un numéro de plaque au clavier.
/// L'app envoie le texte au AI Service via POST /verify (sans photo)
/// et affiche le résultat identique à celui du scanner caméra.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_ctrl.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    // Appel au AI Service via le ScanProvider (méthode verifyByText).
    await context.read<ScanProvider>().verifyByText(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final scanProv = context.watch<ScanProvider>();
    final isSending = scanProv.isSending;
    final hasDone   = scanProv.hasDone;
    final hasError  = scanProv.hasError;

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

          // Champ de saisie + bouton
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
                    // Bouton effacer si du texte est present
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _ctrl.clear();
                              context.read<ScanProvider>().reset();
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
                    onPressed: isSending ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: isSending
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

          // Séparateur
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

          // Contenu selon l'état
          if (hasError)
            _errorState(scanProv.errorMessage ?? 'Erreur lors de la recherche')
          else if (hasDone && scanProv.result != null)
            _resultCard(scanProv.result!)
          else
            _emptyState(),
        ],
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
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
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
          // En-tête
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
                    color: isOk
                        ? AppColors.okBg
                        : AppColors.noBg,
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

          // Tableau de données
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
