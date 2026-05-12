// ============================================================
//  DONNEES MOCKEES — aucun appel réseau dans ce fichier
// ============================================================

class VehicleScanResult {
  final String plate;
  final String fullName;
  final String service;
  final String phone;
  final String direction;
  final String entity;
  final String vehicleType;
  final String brand;
  final String structure;
  final bool isAuthorized;

  const VehicleScanResult({
    required this.plate,
    required this.fullName,
    required this.service,
    required this.phone,
    required this.direction,
    required this.entity,
    required this.vehicleType,
    required this.brand,
    required this.structure,
    required this.isAuthorized,
  });

  List<MapEntry<String, String>> get fields => [
        MapEntry('Matricule', plate),
        MapEntry('Nom complet', fullName),
        MapEntry('Service', service),
        MapEntry('Telephone', phone),
        MapEntry('Direction', direction),
        MapEntry('Entite', entity),
        MapEntry('Type', vehicleType),
        MapEntry('Marque', brand),
        MapEntry('Structure', structure),
      ];
}

class SearchResult {
  final String name;
  final String firstName;
  final String service;
  final String model;
  final String vehicleType;
  final String phone;
  final String vehicleOwnership;

  const SearchResult({
    required this.name,
    required this.firstName,
    required this.service,
    required this.model,
    required this.vehicleType,
    required this.phone,
    required this.vehicleOwnership,
  });

  List<MapEntry<String, String>> get fields => [
        MapEntry('Nom', name),
        MapEntry('Prenom', firstName),
        MapEntry('Service', service),
        MapEntry('Modele', model),
        MapEntry('Type', vehicleType),
        MapEntry('Mobile', phone),
        MapEntry('Voiture', vehicleOwnership),
      ];
}

class AccessEntry {
  final String? name;
  final String plate;
  final String type;   // 'Permanent' | 'Temporaire'
  final String entry;
  final String? exit;
  final String status; // 'Autorise' | 'Refuse' | 'Expire'

  const AccessEntry({
    this.name,
    required this.plate,
    required this.type,
    required this.entry,
    this.exit,
    required this.status,
  });

  String get displayName => name ?? 'Visiteur inconnu';

  String get initials {
    if (name == null) return 'V';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class NotificationEntry {
  final String id;
  final String title;
  final String message;
  final String time;
  bool isRead;
  final String type; // 'warning' | 'danger'

  NotificationEntry({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}

// ============================================================
//  DONNEES
// ============================================================

class MockData {
  MockData._();

  // --- Résultat scan caméra ---
  static const VehicleScanResult scanResult = VehicleScanResult(
    plate: '131952-118-16',
    fullName: 'Ben13 Ilyes',
    service: 'DG',
    phone: '066003513',
    direction: 'CP',
    entity: 'CP',
    vehicleType: 'IBIZA13',
    brand: 'SEAT13',
    structure: 'structure13',
    isAuthorized: true,
  );

  // --- Résultat recherche manuelle ---
  static const SearchResult searchResult = SearchResult(
    name: 'BENABDALLAH',
    firstName: 'Mohammed Ilyas',
    service: 'URD',
    model: 'SEAT',
    vehicleType: 'IBIZA',
    phone: '0660 03 58 40',
    vehicleOwnership: 'Personnel',
  );

  // --- Historique des accès ---
  static final List<AccessEntry> accessHistory = [
    const AccessEntry(
      name: 'Amira Khelifa',
      plate: '0277311731',
      type: 'Permanent',
      entry: '14/04 07:45',
      status: 'Autorise',
    ),
    const AccessEntry(
      name: 'Omar Zerrouki',
      plate: 'WW666RV',
      type: 'Permanent',
      entry: '13/04 18:00',
      status: 'Autorise',
    ),
    const AccessEntry(
      name: 'Amira Khelifa',
      plate: '222871',
      type: 'Permanent',
      entry: '13/04 09:00',
      status: 'Refuse',
    ),
    const AccessEntry(
      name: 'Sofiane Meziane',
      plate: 'ALG288',
      type: 'Permanent',
      entry: '12/04 08:15',
      status: 'Autorise',
    ),
    const AccessEntry(
      name: 'Moussa Hadj',
      plate: '16ABC24',
      type: 'Temporaire',
      entry: '14/04 21:04',
      status: 'Expire',
    ),
    const AccessEntry(
      plate: '1050911831',
      type: 'Temporaire',
      entry: '14/04 21:44',
      status: 'Expire',
    ),
    const AccessEntry(
      plate: '2475111231',
      type: 'Temporaire',
      entry: '14/04 20:04',
      status: 'Expire',
    ),
  ];

  // --- Notifications ---
  static List<NotificationEntry> notifications = [
    NotificationEntry(
      id: 'n1',
      title: 'Accès temporaire expiré',
      message:
          "L'accès temporaire de Aissaoui Nadia (plaque 2475111231) est expiré depuis 1h30.",
      time: '14/04 22:04',
      isRead: false,
      type: 'warning',
    ),
    NotificationEntry(
      id: 'n2',
      title: "Tentative d'accès refusée",
      message:
          "Le véhicule avec la plaque 222871 a été refusé à l'entrée du site.",
      time: '14/04 22:04',
      isRead: false,
      type: 'danger',
    ),
  ];

  // --- Statistiques ---
  static const int statTotalScans  = 120;
  static const int statExisting    = 100;
  static const int statNonExisting = 200;

  static const double pieExistingPct    = 80;
  static const double pieNonExistingPct = 20;
}
