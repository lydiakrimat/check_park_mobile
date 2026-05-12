import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // MediaType — fourni par le package http (dependance transitive)
import '../config/api_config.dart';
import '../config/app_constants.dart';
import '../models/scan_result.dart';
import 'api_service.dart';

/// Service de communication avec le AI Service FastAPI pour la detection ALPR.
///
/// Ce service gere deux cas d'usage :
///   1. [scanPhoto]   : envoi d'une photo (depuis la camera) → POST /scan
///   2. [verifyPlate] : envoi d'un texte (saisie manuelle)   → POST /verify
///
/// Le AI Service execute le pipeline complet :
///   Photo → YOLOX (detection bounding box) → PaddleOCR (lecture texte)
///   → Fuzzy matching (correspondance BDD) → Verification droits (Laravel)
///   → Retour du resultat JSON au format [ScanResult]
class ScanService {
  /// Envoie une photo JPEG au AI Service et retourne le resultat de detection.
  ///
  /// POURQUOI MULTIPART ET PAS UN POST SIMPLE ?
  ///   Le endpoint FastAPI est declare comme :
  ///     async def scan(image: UploadFile = File(...))
  ///   FastAPI attend obligatoirement un envoi "multipart/form-data", le meme
  ///   format qu'un formulaire HTML avec un <input type="file">.
  ///   Un POST avec les bytes bruts en body renverrait HTTP 415 Unsupported Media Type.
  ///
  /// POURQUOI FORCER contentType ?
  ///   Sur Android, le fichier temporaire produit par camera.takePicture() a un
  ///   chemin du type "/data/user/0/.../cache/CAP1234567890.jpg".
  ///   Le package http detecte le MIME type depuis l'extension du fichier.
  ///   Si l'extension n'est pas reconnue ou absente, aucun Content-Type n'est
  ///   envoye pour la partie fichier — FastAPI rejette alors la requete (HTTP 415).
  ///   En forcant MediaType('image', 'jpeg'), on garantit que l'en-tete
  ///   "Content-Type: image/jpeg" est toujours present dans la partie multipart.
  ///
  /// Equivalent curl :
  ///   curl -X POST http://host:8080/scan -F "image=@photo.jpg"
  ///
  /// Timeout genereux (15s) car le pipeline IA prend 2-5 secondes sur CPU.
  Future<ScanResult> scanPhoto(File imageFile) async {
    try {
      // Verifier que le fichier existe et n'est pas vide avant l'envoi.
      // Evite un multipart vide qui ferait crasher le parsing cote FastAPI.
      if (!imageFile.existsSync() || imageFile.lengthSync() == 0) {
        throw const ApiException(
          'Le fichier photo est vide ou introuvable. Reessayez.',
        );
      }

      // Construire la requete multipart/form-data vers POST /scan.
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.scanUrl),
      );

      // Ajouter l'image en tant que champ multipart nomme "image".
      // Le nom du champ DOIT correspondre au parametre FastAPI :
      //   async def scan(image: UploadFile = File(...))
      // contentType force l'en-tete "Content-Type: image/jpeg" sur cette partie.
      // Sans ce forçage, Android peut envoyer le fichier sans Content-Type,
      // ce qui provoque HTTP 415 cote FastAPI.
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',            // nom du champ — doit correspondre au parametre FastAPI
          imageFile.path,
          filename: 'scan.jpg', // nom de fichier envoye dans la requete
          contentType: MediaType('image', 'jpeg'), // force image/jpeg — corrige le 415
        ),
      );

      // Envoyer la requete avec un timeout genereux.
      // MultipartRequest retourne un StreamedResponse : on le convertit en
      // Response normale pour acceder facilement au body JSON.
      final streamedResponse = await request.send().timeout(
        ApiConfig.scanTimeout,
        onTimeout: () => throw const ApiException(AppConstants.erreurTimeout),
      );
      final response = await http.Response.fromStream(streamedResponse);

      // Convertir le code HTTP en message comprehensible pour l'agent.
      _checkAiServiceStatus(response.statusCode, response.body);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ScanResult.fromJson(json);
    } on ApiException {
      rethrow; // Relancer les erreurs deja formatees.
    } on SocketException {
      // Le AI Service n'est pas joignable (pas demarré, mauvaise IP, etc.).
      throw ApiException(AppConstants.erreurServiceIA);
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }

  /// Verifie une plaque par son texte sans photo (recherche manuelle).
  ///
  /// Envoie POST /verify avec body JSON : { "plate_text": "ALG288" }
  /// La reponse a le meme format JSON que /scan.
  ///
  /// Ce endpoint recoit du JSON simple (pas de fichier) — pas de 415 possible ici.
  Future<ScanResult> verifyPlate(String plateText) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.verifyUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'plate_text': plateText.trim().toUpperCase()}),
          )
          .timeout(ApiConfig.scanTimeout);

      _checkAiServiceStatus(response.statusCode, response.body);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ScanResult.fromJson(json);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(AppConstants.erreurServiceIA);
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }

  /// Traduit un code HTTP du AI Service en [ApiException] lisible par l'agent.
  ///
  /// Centralise la gestion des erreurs HTTP pour tous les appels a ce service.
  /// Appele apres chaque reponse avant de parser le JSON.
  void _checkAiServiceStatus(int statusCode, String body) {
    if (statusCode == 200) return; // Succes — ne rien faire.

    switch (statusCode) {
      case 400:
        throw const ApiException(
          'Requete invalide envoyee au service IA (400). '
          'Verifiez que la photo n\'est pas corrompue.',
        );
      case 415:
        // Ce cas ne devrait plus se produire apres l'ajout du contentType force,
        // mais on le garde comme filet de securite.
        throw const ApiException(
          'Format d\'image non supporte par le service IA (415). '
          'Seul le format JPEG est accepte.',
        );
      case 422:
        throw const ApiException(
          'Donnees non traitables par le service IA (422). '
          'Le champ "image" est peut-etre manquant dans la requete.',
        );
      case 500:
        throw const ApiException(
          'Erreur interne du service IA (500). '
          'Consultez les logs FastAPI sur le Mac.',
        );
      case 503:
        throw ApiException(
          'Service IA indisponible (503). '
          'Le service FastAPI est peut-etre en cours de demarrage.',
          statusCode: statusCode,
        );
      default:
        throw ApiException(
          'Erreur AI Service ($statusCode).',
          statusCode: statusCode,
        );
    }
  }
}
