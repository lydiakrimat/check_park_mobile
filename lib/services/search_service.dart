import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/app_constants.dart';
import '../models/scan_result.dart';
import 'api_service.dart';

// =============================================================================
// search_service.dart — Consultation vehicule + enregistrement explicite d'acces
// =============================================================================
// Ce service est utilise UNIQUEMENT par SearchScreen (saisie manuelle de plaque).
// Il est distinct de ScanService (camera + AI Service /scan) et ne partage pas
// l'etat de ScanProvider.
//
// Deux operations distinctes :
//   1. lookupVehicle() — POST /verify-lookup sur le AI Service
//      Consultation pure : fuzzy matching + infos vehicule/proprietaire
//      Aucun enregistrement en BDD.
//
//   2. registerAccess() — POST /api/acces sur Laravel
//      Enregistrement explicite, appele uniquement apres confirmation de l'agent.
// =============================================================================

/// Resultat d'une consultation de vehicule par saisie manuelle de plaque.
///
/// Regroupe le [ScanResult] pour l'affichage et les identifiants
/// necessaires pour enregistrer l'acces si l'agent valide l'entree.
class VehicleLookupResult {
  /// Donnees d'affichage : autorisation, infos vehicule et proprietaire.
  final ScanResult scanResult;

  /// Identifiant du vehicule dans la table "vehicles".
  /// Null si le vehicule n'est pas trouve en base.
  final int? vehicleId;

  /// Identifiant de l'employe proprietaire (vehicles.employee_id).
  /// Null si le vehicule n'est lie a aucun employe.
  final int? employeeId;

  const VehicleLookupResult({
    required this.scanResult,
    this.vehicleId,
    this.employeeId,
  });
}

/// Service de recherche manuelle de vehicule par plaque.
///
/// Necessite un [ApiService] pour les appels au backend Laravel (POST /api/acces).
/// Les appels au AI Service (/verify-lookup) utilisent http directement,
/// comme dans ScanService — le AI Service ne requiert pas d'authentification.
class SearchService {
  /// Client HTTP authentifie pour les appels au backend Laravel.
  final ApiService _api;

  const SearchService(this._api);

  /// Consulte un vehicule par numéro de plaque sans creer d'enregistrement.
  ///
  /// Appelle POST /verify-lookup sur le AI Service FastAPI.
  /// Le AI Service fait le fuzzy matching sur le cache local puis interroge
  /// Laravel (POST /api/vehicles/check) pour les infos vehicule et proprietaire.
  /// Aucun effet de bord en base de donnees.
  ///
  /// La plaque est normalisee en majuscules avant l'envoi.
  ///
  /// Leve une [ApiException] si la requete echoue (reseau, serveur).
  Future<VehicleLookupResult> lookupVehicle(String plate) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.aiServiceBase}/verify-lookup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'plate_text': plate.trim().toUpperCase()}),
          )
          .timeout(ApiConfig.scanTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Erreur AI Service (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Le AI Service retourne une erreur 503 si Laravel etait inaccessible,
      // mais par securite on verifie aussi le champ error dans le corps.
      if (json['error'] == 'backend_unavailable') {
        throw const ApiException(
          'Le serveur est temporairement inaccessible. Reessayez dans un instant.',
        );
      }

      // Construire le ScanResult a partir du JSON (meme format que /verify).
      final scanResult = ScanResult.fromJson(json);

      // Extraire les identifiants exposes par /verify-lookup pour l'enregistrement.
      final vehicleId  = json['vehicle_id']  as int?;
      final employeeId = json['employee_id'] as int?;

      return VehicleLookupResult(
        scanResult: scanResult,
        vehicleId:  vehicleId,
        employeeId: employeeId,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'Impossible de joindre le service IA. Verifiez que le AI Service est demarre.',
      );
    } on TimeoutException {
      throw const ApiException(AppConstants.erreurTimeout);
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }

  /// Enregistre un acces permanent dans la table "acces" de Laravel.
  ///
  /// A appeler UNIQUEMENT apres confirmation explicite de l'agent.
  /// Utilise pour les vehicules d'employes enregistres dans la table "vehicles".
  ///
  /// Retourne le type_passage ('entree' ou 'sortie') fourni par Laravel.
  /// Leve une [ApiException] si l'enregistrement echoue.
  Future<String?> registerPermanentAccess(
      int vehicleId, int? employeeId) async {
    final body = <String, dynamic>{
      'type_acces': 'Permanent',
      'vehicle_id': vehicleId,
      'statut':     'Autorise',
    };
    if (employeeId != null) {
      body['employe_id'] = employeeId;
    }

    // Capturer la réponse pour extraire le type_passage
    final response = await _api.post(ApiConfig.accesUrl, body);
    return (response as Map<String, dynamic>?)?['type_passage'] as String?;
  }

  /// Enregistre un acces temporaire (visiteur) dans la table "acces" de Laravel.
  ///
  /// A appeler UNIQUEMENT apres confirmation explicite de l'agent.
  /// Envoie les champs visiteur requis par AccesController pour type_acces=Temporaire.
  ///
  /// Retourne le type_passage ('entree' ou 'sortie') fourni par Laravel.
  /// Leve une [ApiException] si l'enregistrement echoue.
  Future<String?> registerTemporaireAccess({
    required String plateNumber,
    required String nomVisiteur,
    required String prenomVisiteur,
    String? telephone,
    required int dureeAutorisee,
  }) async {
    final body = <String, dynamic>{
      'type_acces':            'Temporaire',
      'plate_number_visiteur': plateNumber,
      'nom_visiteur':          nomVisiteur,
      'prenom_visiteur':       prenomVisiteur,
      'duree_autorisee':       dureeAutorisee,
      'statut':                'Autorise',
    };
    if (telephone != null && telephone.isNotEmpty) {
      body['telephone_visiteur'] = telephone;
    }

    // Capturer la réponse pour extraire le type_passage
    final response = await _api.post(ApiConfig.accesUrl, body);
    return (response as Map<String, dynamic>?)?['type_passage'] as String?;
  }
}
