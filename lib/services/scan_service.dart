import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/app_constants.dart';
import '../models/scan_result.dart';
import 'api_service.dart';

/// Service de communication avec le AI Service FastAPI pour la détection ALPR.
///
/// Ce service gère deux cas d'usage :
///   1. [scanPhoto] : envoi d'une photo (depuis la caméra) → POST /scan
///   2. [verifyPlate] : envoi d'un texte (saisie manuelle) → POST /verify
///
/// Le AI Service exécute le pipeline complet :
///   Photo → YOLOX (détection bounding box) → PaddleOCR (lecture texte)
///   → Fuzzy matching (correspondance BDD) → Vérification droits (Laravel)
///   → Retour du résultat JSON au format [ScanResult]
class ScanService {
  /// Envoie une photo JPEG au AI Service et retourne le résultat de détection.
  ///
  /// La requête est un multipart/form-data avec le champ "image" contenant le fichier.
  /// Équivalent curl : curl -X POST http://host:8080/scan -F "image=@photo.jpg"
  ///
  /// Le timeout est généreux (15s) car le pipeline IA prend 2-5 secondes sur CPU.
  Future<ScanResult> scanPhoto(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.scanUrl),
      );

      // Ajout de l'image comme champ multipart nommé "image".
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      // Timeout : on fixe manuellement car MultipartRequest ne supporte pas .timeout() directement.
      final streamedResponse = await request.send().timeout(
        ApiConfig.scanTimeout,
        onTimeout: () => throw const ApiException(AppConstants.erreurTimeout),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw ApiException(
          'Erreur AI Service (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ScanResult.fromJson(json);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'Impossible de joindre le service IA. Vérifiez que le AI Service est démarré.',
      );
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }

  /// Vérifie une plaque par son texte sans photo (recherche manuelle).
  ///
  /// Envoie POST /verify avec body : { "plate_text": "ALG288" }
  /// La réponse a le même format JSON que /scan.
  Future<ScanResult> verifyPlate(String plateText) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.verifyUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'plate_text': plateText.trim().toUpperCase()}),
          )
          .timeout(ApiConfig.scanTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Erreur AI Service (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ScanResult.fromJson(json);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'Impossible de joindre le service IA. Vérifiez que le AI Service est démarré.',
      );
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }
}
