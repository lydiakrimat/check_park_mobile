import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_scheme.dart';

/// Banniere d'erreur reutilisable.
///
/// Affiche un message d'erreur avec une icone et un bouton "Reessayer"
/// optionnel. Peut etre utilise dans n'importe quel ecran de l'application.
///
/// Usage minimal :
///   ErrorBanner(message: 'Impossible de joindre le serveur.')
///
/// Usage avec bouton retry :
///   ErrorBanner(
///     message: provider.errorMessage,
///     onRetry: () => provider.fetch(),
///   )
///
/// [message]   : texte d'erreur a afficher — provient generalement d'une
///               ApiException capturee dans un provider.
/// [onRetry]   : callback appele quand l'agent appuie sur "Reessayer".
///               Si null, le bouton n'est pas affiche.
/// [icon]      : icone affichee a gauche du message. Par defaut : cloud_off.
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Fond rouge tres attenue pour ne pas agresser visuellement.
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icone d'erreur.
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 12),
            child: Icon(icon, color: AppColors.danger, size: 20),
          ),

          // Colonne : message + bouton retry.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: c.text,
                    height: 1.5,
                  ),
                ),

                // Bouton "Reessayer" — affiche uniquement si onRetry est fourni.
                if (onRetry != null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onRetry,
                    child: Text(
                      l.reessayer,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
