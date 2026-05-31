/// Résultat retourné par le AI Service FastAPI après analyse d'une photo ou d'un texte.
///
/// Ce modèle NE correspond PAS à une table Laravel — c'est la structure du JSON
/// retourné par le endpoint POST /scan ou POST /verify du AI Service.
///
/// PIPELINE DE DÉTECTION (ce qui se passe côté AI Service) :
///
///   1. YOLOX (réseau de neurones) analyse l'image et dessine une bounding box
///      autour de la zone où se trouve la plaque d'immatriculation.
///      → [confidence] = score de certitude de YOLOX (0.0 à 1.0)
///      → [boundingBox] = coordonnées du rectangle détecté en pixels
///
///   2. La zone de la plaque est découpée (crop) et pré-traitée
///      (agrandissement, correction de contraste) pour améliorer la lisibilité.
///
///   3. PaddleOCR lit les caractères sur le crop de la plaque.
///      → [plateOcr] = texte brut lu par l'OCR (peut avoir des erreurs, ex: "ALGC288")
///
///   4. Fuzzy matching compare [plateOcr] avec toutes les plaques en BDD.
///      On utilise un seuil de similarité de 80% pour tolérer les erreurs d'OCR.
///      → [plateMatched] = la plaque en BDD la plus proche (ex: "ALG288")
///      → [similarityScore] = score de similarité (0.0 à 1.0)
///
///   5. Si un match est trouvé, le AI Service interroge Laravel (POST /api/vehicles/check)
///      pour obtenir les détails du véhicule et du propriétaire.
///      → [authorized] = true si le véhicule a le droit d'entrer
///      → [vehicle] et [owner] = infos du véhicule et du propriétaire
///
/// Format JSON exact retourné par le AI Service :
/// {
///   "detected": true,
///   "plate_ocr": "ALGC288",
///   "plate_matched": "ALG288",
///   "similarity_score": 0.923,
///   "authorized": true,
///   "reason": null,
///   "confidence": 0.98,
///   "bounding_box": {"x1": 120, "y1": 340, "x2": 480, "y2": 410},
///   "vehicle": {"brand": "Renault", "color": "Blanc", "plate_number": "ALG288"},
///   "owner": {"prenom": "Rachid", "nom": "Boudiaf", "service": "Systèmes d'Information"}
/// }
class ScanResult {
  /// true = une plaque a été détectée dans l'image par YOLOX.
  /// false = aucune plaque détectée (voiture mal cadrée, image floue, etc.)
  final bool detected;

  /// Texte brut lu par PaddleOCR sur la plaque détectée.
  /// Peut contenir des erreurs OCR (ex: "0" lu à la place de "O").
  /// Null si [detected] = false.
  final String? plateOcr;

  /// Plaque en BDD qui correspond au résultat OCR via fuzzy matching.
  /// Ex: "ALG288" même si l'OCR a lu "ALGC288".
  /// Null si aucun match trouvé avec un score suffisant.
  final String? plateMatched;

  /// Score de similarité entre [plateOcr] et [plateMatched] (0.0 à 1.0).
  /// Un score >= 0.8 est requis pour valider le match.
  /// Null si aucun match.
  final double? similarityScore;

  /// true = le véhicule identifié est autorisé à entrer.
  /// false = véhicule refusé (non autorisé ou non trouvé en BDD).
  final bool authorized;

  /// Raison du refus si [authorized] = false (ex: "Véhicule non autorisé").
  /// Null si autorisé.
  final String? reason;

  /// Score de confiance YOLOX pour la détection de la plaque (0.0 à 1.0).
  /// Un score élevé signifie que YOLOX est très sûr d'avoir trouvé une plaque.
  final double? confidence;

  /// Coordonnées en pixels de la zone de la plaque dans l'image originale.
  /// Permet d'afficher un rectangle vert autour de la plaque dans l'UI.
  final BoundingBox? boundingBox;

  /// Informations sur le véhicule trouvé en BDD.
  final VehicleInfo? vehicle;

  /// Informations sur le propriétaire du véhicule.
  final OwnerInfo? owner;

  /// Type de véhicule : "temporaire" (visiteur) ou null (permanent par défaut).
  final String? vehicleType;

  /// Type de passage : 'entree' ou 'sortie' (logique entrée/sortie Laravel).
  final String? typePassage;

  const ScanResult({
    required this.detected,
    this.plateOcr,
    this.plateMatched,
    this.similarityScore,
    required this.authorized,
    this.reason,
    this.confidence,
    this.boundingBox,
    this.vehicle,
    this.owner,
    this.vehicleType,
    this.typePassage,
  });

  /// true si le véhicule est un visiteur temporaire.
  bool get isTemporaire => vehicleType == 'temporaire';

  /// La plaque à afficher en priorité : [plateMatched] si disponible, sinon [plateOcr].
  String get displayPlate => plateMatched ?? plateOcr ?? '';

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      detected: json['detected'] as bool? ?? false,
      plateOcr: json['plate_ocr'] as String?,
      plateMatched: json['plate_matched'] as String?,
      similarityScore: (json['similarity_score'] as num?)?.toDouble(),
      authorized: json['authorized'] as bool? ?? false,
      reason: json['reason'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      boundingBox: json['bounding_box'] != null
          ? BoundingBox.fromJson(json['bounding_box'] as Map<String, dynamic>)
          : null,
      vehicle: json['vehicle'] != null
          ? VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      owner: json['owner'] != null
          ? OwnerInfo.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      vehicleType: json['type'] as String?,
      typePassage: json['type_passage'] as String?,
    );
  }
}

/// Coordonnées du rectangle de détection en pixels.
/// x1,y1 = coin supérieur gauche ; x2,y2 = coin inférieur droit.
class BoundingBox {
  final double x1, y1, x2, y2;

  const BoundingBox({
    required this.x1, required this.y1,
    required this.x2, required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
    );
  }
}

/// Informations synthétiques sur le véhicule retournées par le AI Service.
class VehicleInfo {
  final String? brand;
  final String? color;
  final String? plateNumber;

  const VehicleInfo({this.brand, this.color, this.plateNumber});

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      plateNumber: json['plate_number'] as String?,
    );
  }
}

/// Informations sur le propriétaire (employé) ou le visiteur (temporaire).
///
/// Pour un véhicule permanent : [prenom], [nom], [service] sont remplis.
/// Pour un véhicule temporaire : [prenom], [nom], [telephone],
/// [motifVisite] et [dureeAutorisee] sont remplis.
class OwnerInfo {
  final String? prenom;
  final String? nom;
  final String? service;

  /// Champs spécifiques aux visiteurs temporaires.
  final String? telephone;
  final String? motifVisite;
  final int? dureeAutorisee;

  const OwnerInfo({
    this.prenom,
    this.nom,
    this.service,
    this.telephone,
    this.motifVisite,
    this.dureeAutorisee,
  });

  String get fullName => '$prenom $nom'.trim();

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      prenom:          json['prenom']           as String?,
      nom:             json['nom']              as String?,
      service:         json['service']          as String?,
      telephone:       json['telephone']        as String?,
      motifVisite:     json['motif_visite']     as String?,
      dureeAutorisee:  (json['duree_autorisee'] as num?)?.toInt(),
    );
  }
}
