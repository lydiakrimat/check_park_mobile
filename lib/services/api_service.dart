import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/app_constants.dart';

/// Exception personnalisée pour les erreurs API.
/// Transporte un message lisible par l'utilisateur et le code HTTP si disponible.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Client HTTP générique pour toutes les communications avec le backend Laravel.
///
/// Responsabilités :
///   - Ajouter automatiquement le header Authorization: Bearer TOKEN si connecté
///   - Gérer les codes d'erreur HTTP (401, 422, 500, etc.)
///   - Convertir les exceptions réseau en [ApiException] lisibles
///   - Appliquer les timeouts configurés dans [ApiConfig]
///
/// Utilisation :
///   final service = ApiService(getToken: () => prefs.getString('auth_token'));
///   final data = await service.get('/acces');
class ApiService {
  /// Callback pour récupérer le token JWT stocké localement.
  /// Retourne null si l'utilisateur n'est pas connecté.
  final String? Function() getToken;

  const ApiService({required this.getToken});

  // ── En-têtes communs ───────────────────────────────────────────────────────

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      // Sanctum attend le token dans ce format standard Bearer.
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Méthodes HTTP génériques ───────────────────────────────────────────────

  /// Effectue une requête GET sur [url] et retourne le corps décodé en JSON.
  Future<dynamic> get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers())
          .timeout(ApiConfig.defaultTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(AppConstants.erreurReseau);
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }

  /// Effectue une requête POST avec un body JSON.
  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.defaultTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(AppConstants.erreurReseau);
    } on TimeoutException {
      throw const ApiException(AppConstants.erreurTimeout);
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }

  /// Effectue une requête PUT avec un body JSON.
  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.defaultTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(AppConstants.erreurReseau);
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }

  /// Effectue une requête DELETE.
  Future<dynamic> delete(String url) async {
    try {
      final response = await http
          .delete(Uri.parse(url), headers: _headers())
          .timeout(ApiConfig.defaultTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(AppConstants.erreurReseau);
    } on http.ClientException {
      throw const ApiException(AppConstants.erreurReseau);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(AppConstants.erreurInconnu);
    }
  }

  // ── Gestion des réponses ───────────────────────────────────────────────────

  /// Décode la réponse HTTP et lève une [ApiException] si le code n'est pas 2xx.
  dynamic _handleResponse(http.Response response) {
    final body = _decodeBody(response);

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;

      case 401:
        // Token expiré ou invalide — l'AuthProvider doit déconnecter l'utilisateur.
        throw ApiException(
          'Session expirée. Veuillez vous reconnecter.',
          statusCode: 401,
        );

      case 403:
        throw ApiException(
          'Accès refusé.',
          statusCode: 403,
        );

      case 404:
        throw ApiException(
          'Ressource introuvable.',
          statusCode: 404,
        );

      case 422:
        // Erreur de validation Laravel — le body contient les détails.
        final errors = body is Map ? body['errors'] : null;
        final firstError = errors is Map
            ? (errors.values.first as List?)?.first?.toString()
            : null;
        throw ApiException(
          firstError ?? 'Données invalides.',
          statusCode: 422,
        );

      case 500:
        throw ApiException(
          AppConstants.erreurServeur,
          statusCode: 500,
        );

      default:
        throw ApiException(
          'Erreur ${response.statusCode}.',
          statusCode: response.statusCode,
        );
    }
  }

  /// Décode le corps de la réponse en JSON ou retourne le texte brut.
  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }
}
