// Configuration des URLs et timeouts pour toutes les APIs du projet ALPR.
//
// ARCHITECTURE RÉSEAU :
//   [App Mobile Flutter]
//       |-- POST /scan, POST /verify --> [AI Service FastAPI :8080]
//       |-- GET/POST/PUT              --> [Backend Laravel     :8000]
//
// ADRESSES IP :
//   - Émulateur Android : 10.0.2.2 pointe vers localhost de la machine hôte
//   - Vrai téléphone    : utiliser l'IP locale du PC sur le même WiFi (ex: 192.168.1.x)
//
// Pour basculer entre émulateur et vrai téléphone, changer la constante [_host].

class ApiConfig {
  ApiConfig._(); // Classe non instanciable, uniquement des constantes statiques.

  // ── Hôte cible ────────────────────────────────────────────────────────────
  //
  // EMULATEUR Android (AVD) :
  //   10.0.2.2 est un alias special qui pointe vers localhost du Mac.
  //   Utiliser cette adresse quand on lance l'app dans Android Studio / AVD.
  //
  // VRAI TELEPHONE physique (USB ou Wi-Fi) :
  //   Le telephone doit etre sur le meme reseau Wi-Fi que le Mac.
  //   Remplacer par l'IP locale du Mac : commande Mac → ipconfig getifaddr en0
  //   IP actuelle du Mac sur le reseau local : 192.168.1.6
  //
  // Pour switcher : commenter une ligne, decommenter l'autre.

  // Pour emulateur Android (AVD) :
  //static const String _host = '10.0.2.2';

  // Pour vrai telephone physique (meme reseau Wi-Fi que le pc) :
  static const String _host = '192.168.1.11';


  // ── Backend Laravel (API REST) ─────────────────────────────────────────────
  static const int laravelPort = 8000;
  static const String laravelBase = 'http://$_host:$laravelPort/api';

  // Endpoints d'authentification
  static const String loginUrl    = '$laravelBase/login/mobile';
  static const String logoutUrl   = '$laravelBase/logout';
  static const String meUrl       = '$laravelBase/me';

  // Endpoints métier
  static const String accesUrl         = '$laravelBase/acces';
  static const String notificationsUrl = '$laravelBase/notifications';
  static const String vehiclesUrl      = '$laravelBase/vehicles';
  static const String utilisateursUrl  = '$laravelBase/utilisateurs';

  // ── AI Service FastAPI ─────────────────────────────────────────────────────
  // Ce service reçoit les photos et exécute le pipeline complet 
  static const int aiServicePort = 8080;
  static const String aiServiceBase = 'http://$_host:$aiServicePort';

  // POST avec multipart/form-data contenant le fichier image
  static const String scanUrl   = '$aiServiceBase/scan';
  // POST avec body JSON {"plate_text": "ALG288"} — pour la recherche manuelle
  static const String verifyUrl = '$aiServiceBase/verify';

  // ── Timeouts ───────────────────────────────────────────────────────────────
  // Le pipeline IA (YOLOX + OCR + fuzzy matching) prend 2-5 secondes sur CPU.
  // 15 secondes de marge pour les appels scan/verify.
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration scanTimeout    = Duration(seconds: 15);
}
