import '../config/api_config.dart';
import '../models/access_record.dart';
import 'api_service.dart';

/// Service pour les accès (historique des entrées/sorties).
///
/// Correspond à AccesController.php dans Laravel.
/// Tous les appels nécessitent un token valide via [ApiService].
class AccessService {
  final ApiService _api;

  const AccessService(this._api);

  /// Récupère la liste de tous les accès, triés par date décroissante.
  ///
  /// Le backend Laravel appelle automatiquement expireOutdated() avant de retourner
  /// les données, ce qui marque les accès Temporaires expirés comme 'Expire'.
  /// Les relations employe et vehicle sont chargées (eager loading).
  Future<List<AccessRecord>> fetchAll() async {
    final data = await _api.get(ApiConfig.accesUrl);
    final list = data as List<dynamic>;
    return list
        .map((item) => AccessRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
