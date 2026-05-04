import 'dart:io';
import 'package:camera/camera.dart';
import 'api_service.dart';

/// Service de gestion de la caméra pour la capture de plaques d'immatriculation.
///
/// Utilise le package [camera] pour accéder à la caméra arrière du téléphone.
/// Ce service gère le cycle de vie complet de la caméra :
///   1. Récupération des caméras disponibles
///   2. Initialisation de la caméra arrière
///   3. Capture d'une photo JPEG
///   4. Libération des ressources quand l'agent quitte l'écran
///
/// Usage typique dans un écran Scanner :
///   - initState  : await cameraService.initialize()
///   - build      : CameraPreview(cameraService.controller!)
///   - bouton     : final file = await cameraService.takePhoto()
///   - dispose    : cameraService.dispose()
class CameraService {
  CameraController? _controller;
  bool _initialized = false;

  /// Retourne le contrôleur de caméra (null si pas encore initialisé).
  CameraController? get controller => _controller;

  /// true si la caméra est prête à capturer.
  bool get isInitialized => _initialized;

  /// Initialise la caméra arrière du téléphone.
  ///
  /// Sélectionne automatiquement la première caméra orientée vers l'arrière.
  /// Résolution : high (bon compromis qualité/performance pour l'OCR).
  ///
  /// Lance une [ApiException] si aucune caméra n'est disponible.
  Future<void> initialize() async {
    if (_initialized) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw const ApiException('Aucune caméra disponible sur cet appareil.');
    }

    // Recherche de la caméra arrière — meilleure qualité pour lire les plaques.
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      // ResolutionPreset.high donne ~720p, suffisant pour lire une plaque
      // sans surcharger la mémoire ou ralentir PaddleOCR.
      ResolutionPreset.high,
      enableAudio: false, // Pas besoin du micro pour scanner des plaques.
    );

    await _controller!.initialize();
    _initialized = true;
  }

  /// Capture une photo et retourne le fichier JPEG résultant.
  ///
  /// Ce fichier sera ensuite envoyé au AI Service via [ScanService.scanPhoto].
  /// La photo est stockée temporairement dans le répertoire de cache de l'app.
  Future<File> takePhoto() async {
    if (!_initialized || _controller == null) {
      throw const ApiException('La caméra n\'est pas initialisée.');
    }
    if (!_controller!.value.isInitialized) {
      throw const ApiException('La caméra n\'est pas prête.');
    }

    final xfile = await _controller!.takePicture();
    return File(xfile.path);
  }

  /// Libère les ressources de la caméra.
  /// À appeler dans le dispose() de l'écran Scanner.
  ///
  /// Les flags sont mis à null/false de façon SYNCHRONE en premier,
  /// car dispose() des widgets Flutter ne peut pas être awaité.
  /// L'ancien controller est ensuite libéré en arrière-plan.
  Future<void> dispose() async {
    if (_controller == null) return;

    // Invalider immédiatement pour couper tout nouvel accès (synchrone).
    final ctrl = _controller!;
    _controller = null;
    _initialized = false;

    // Arrêt propre du stream d'images avant dispose (corrige ImageReader_JNI).
    try {
      if (ctrl.value.isStreamingImages) {
        await ctrl.stopImageStream();
      }
    } catch (_) {}

    // Libération asynchrone du controller natif.
    try {
      await ctrl.dispose();
    } catch (_) {}
  }
}
