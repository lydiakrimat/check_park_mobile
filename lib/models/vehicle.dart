import 'employee.dart';

/// Représente un véhicule enregistré dans le système ALPR.
///
/// Correspond à la table "vehicles" dans MySQL et au Model Vehicle.php dans Laravel.
/// Chaque véhicule appartient à un employé (via [employeeId] → table "employes").
class Vehicle {
  final int id;

  /// Numéro de plaque tel que stocké en BDD (ex: "ALG288", "WW666RV").
  /// Format Algérien : pas d'espaces, stocké tel quel.
  final String plateNumber;

  /// FK vers la table "employes" — identifie le propriétaire du véhicule.
  final int employeeId;

  /// Marque du véhicule (ex: "Renault", "Toyota"). Peut être null si non renseigné.
  final String? brand;

  /// Couleur du véhicule (ex: "Blanc", "Gris"). Peut être null si non renseigné.
  final String? color;

  /// true = le véhicule est autorisé à entrer sur le site.
  /// false = accès refusé (véhicule blacklisté ou suspension temporaire).
  final bool isAuthorized;

  /// Objet employé complet, chargé par Laravel via eager loading (Vehicle::with('employe')).
  /// Peut être null si la requête n'inclut pas la relation.
  final Employee? employe;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.employeeId,
    this.brand,
    this.color,
    required this.isAuthorized,
    this.employe,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      plateNumber: json['plate_number'] as String? ?? '',
      employeeId: json['employee_id'] as int? ?? 0,
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      // Laravel retourne les booléens comme int (1/0) ou bool selon la version.
      isAuthorized: json['is_authorized'] == true || json['is_authorized'] == 1,
      employe: json['employe'] != null
          ? Employee.fromJson(json['employe'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'employee_id': employeeId,
      'brand': brand,
      'color': color,
      'is_authorized': isAuthorized,
    };
  }
}
