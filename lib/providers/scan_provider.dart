import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';
import '../services/daily_counter_service.dart';
import '../services/scan_service.dart';
import '../services/camera_service.dart';
import '../services/api_service.dart';

/// État possible du scan en cours.
enum ScanStatus { idle, capturing, sending, done, error }

/// Provider de l'état du scanner caméra et de la recherche manuelle.
///
/// Gère deux flux distincts :
///   1. Capture photo → envoi au AI Service → résultat (écran Scanner)
///   2. Saisie de texte → envoi au AI Service → résultat (écran Recherche)
///
/// Usage dans l'écran Scanner via context.read() ou context.watch() sur ScanProvider.
class ScanProvider extends ChangeNotifier {
  final ScanService _scanService;
  final CameraService _cameraService;

  ScanStatus _status = ScanStatus.idle;
  ScanResult? _result;
  String? _errorMessage;

  ScanProvider(this._scanService, this._cameraService);

  // ── Getters publics ────────────────────────────────────────────────────────

  ScanStatus get status => _status;
  ScanResult? get result => _result;
  String? get errorMessage => _errorMessage;
  CameraService get camera => _cameraService;

  bool get isIdle     => _status == ScanStatus.idle;
  bool get isSending  => _status == ScanStatus.sending;
  bool get hasDone    => _status == ScanStatus.done;
  bool get hasError   => _status == ScanStatus.error;

  // ── Caméra ─────────────────────────────────────────────────────────────────

  /// Initialise la caméra (à appeler dans initState de l'écran Scanner).
  /// Remet le statut à idle si une erreur précédente existait.
  Future<void> initCamera() async {
    _status = ScanStatus.idle;
    _errorMessage = null;
    _result = null;
    try {
      await _cameraService.initialize();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ScanStatus.error;
      notifyListeners();
    }
  }

  /// Libère la caméra (à appeler dans dispose de l'écran Scanner).
  /// Les flags internes du CameraService sont réinitialisés de façon synchrone
  /// avant le dispose async — corrige le warning ImageReader_JNI.
  Future<void> disposeCamera() async {
    await _cameraService.dispose();
    // Notifier même si le widget est déjà détaché (ignoré silencieusement).
    try {
      notifyListeners();
    } catch (_) {}
  }

  // ── Scan par photo ─────────────────────────────────────────────────────────

  /// Capture une photo avec la caméra et l'envoie au AI Service pour analyse.
  ///
  /// Transitions d'état :
  ///   idle → sending → done (si succès)
  ///            ↓
  ///          error (si échec)
  Future<void> captureAndScan() async {
    if (_status == ScanStatus.sending) return; // Évite les doubles appuis.
    _errorMessage = null;
    _result = null;
    _status = ScanStatus.sending;
    notifyListeners();

    try {
      // 1. Capture la photo depuis la caméra.
      final File photo = await _cameraService.takePhoto();

      // 2. Envoie la photo au AI Service (pipeline YOLOX + OCR + fuzzy matching).
      _result = await _scanService.scanPhoto(photo);
      _status = ScanStatus.done;

      // Incremente les compteurs quotidiens (fire and forget).
      unawaited(DailyCounterService.incrementScans());
      if (_result!.authorized) {
        unawaited(DailyCounterService.incrementAutorises());
      } else {
        unawaited(DailyCounterService.incrementRefuses());
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ScanStatus.error;
    } catch (_) {
      _errorMessage = 'Erreur inattendue lors du scan.';
      _status = ScanStatus.error;
    }
    notifyListeners();
  }

  // ── Recherche manuelle par texte ───────────────────────────────────────────

  /// Vérifie une plaque via son texte (sans photo) auprès du AI Service.
  ///
  /// Utilisé par l'écran de recherche manuelle.
  Future<void> verifyByText(String plateText) async {
    if (_status == ScanStatus.sending) return;
    _errorMessage = null;
    _result = null;
    _status = ScanStatus.sending;
    notifyListeners();

    try {
      _result = await _scanService.verifyPlate(plateText);
      _status = ScanStatus.done;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ScanStatus.error;
    } catch (_) {
      _errorMessage = 'Erreur inattendue lors de la recherche.';
      _status = ScanStatus.error;
    }
    notifyListeners();
  }

  // ── Reset ──────────────────────────────────────────────────────────────────

  /// Réinitialise l'état pour permettre un nouveau scan.
  void reset() {
    _status = ScanStatus.idle;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }
}
