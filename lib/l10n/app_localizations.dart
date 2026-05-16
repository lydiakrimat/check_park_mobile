import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

/// Traductions de l'application — français (fr) et arabe (ar).
///
/// Usage dans un build() : `context.l10n.connexion`
class AppLocalizations {
  const AppLocalizations(this._ar);

  final bool _ar;

  String _t(String fr, String ar) => _ar ? ar : fr;

  // ── Commun ──────────────────────────────────────────────────────────────────
  String get champObligatoire  => _t('Champ obligatoire',     'هذا الحقل مطلوب');
  String get annuler           => _t('Annuler',               'إلغاء');
  String get enregistrer       => _t('Enregistrer',           'حفظ');
  String get chargement        => _t('Chargement...',         'جارٍ التحميل...');
  String get rechercher        => _t('Rechercher',            'بحث');
  String get autorises         => _t('Autorisés',             'مسموح');
  String get refuses           => _t('Refusés',               'مرفوض');
  String get autorise          => _t('Autorisé',              'مسموح');
  String get refuse            => _t('Refusé',                'مرفوض');
  String get expire            => _t('Expiré',                'منتهي');
  String get actif             => _t('Actif',                 'نشط');
  String get aucunResultat     => _t('Aucun résultat',        'لا نتائج');

  // ── Splash ──────────────────────────────────────────────────────────────────
  String get splashSubtitle    => _t('Contrôle des Immatriculations de Véhicules',
                                     'مراقبة لوحات أرقام المركبات');
  String get splashUnit        => _t('Unité Recherche et Développement',
                                     'وحدة البحث والتطوير');
  String get chargementEnCours => _t('Chargement en cours...',
                                     'جارٍ التحميل...');

  // ── Login ───────────────────────────────────────────────────────────────────
  String get connexion         => _t('Connexion',               'تسجيل الدخول');
  String get loginSubtitle     => _t('Identifiez-vous pour accéder au système',
                                     'تسجيل الدخول للوصول إلى النظام');
  String get labelEmail        => _t('ADRESSE EMAIL',           'البريد الإلكتروني');
  String get hintEmail         => _t('Entrez votre adresse email',
                                     'أدخل بريدك الإلكتروني');
  String get labelPassword     => _t('MOT DE PASSE',            'كلمة المرور');
  String get hintPassword      => _t('Entrez votre mot de passe',
                                     'أدخل كلمة المرور');
  String get seConnecter       => _t('Se connecter',            'تسجيل الدخول');
  String get connexionEnCours  => _t('Connexion...',            'جارٍ التسجيل...');
  String get emailInvalide     => _t('Email invalide',          'بريد إلكتروني غير صالح');
  String get footer            => _t('Algérie Telecom — Unité Recherche et Développement',
                                     'اتصالات الجزائر — وحدة البحث والتطوير');

  // ── Navigation ──────────────────────────────────────────────────────────────
  String get historique        => _t('Historique',              'السجل');
  String get controleAcces     => _t('Contrôle d\'accès',       'مراقبة الوصول');
  String get statistiques      => _t('Statistiques',            'إحصائيات');
  String get parametres        => _t('Paramètres',              'الإعدادات');
  String get statsNav          => _t('Stats',                   'إحصاء');
  String get paramsNav         => _t('Params',                  'إعداد');

  // ── Accueil ─────────────────────────────────────────────────────────────────
  String get controleTitre     => _t('Contrôle d\'immatriculation\ndes véhicules',
                                     'مراقبة لوحات\nأرقام المركبات');
  String get controleSubtitle  => _t('Scannez ou saisissez une plaque\npour vérifier l\'accès',
                                     'امسح أو أدخل رقم اللوحة\nللتحقق من الوصول');
  String get scannerUnePlaque  => _t('Scanner une plaque',      'مسح اللوحة');
  String get utiliserCamera    => _t('Utiliser la caméra',      'استخدام الكاميرا');
  String get saisirUnePlaque   => _t('Saisir une plaque',       'إدخال اللوحة');
  String get saisieManuelle    => _t('Saisie manuelle',         'إدخال يدوي');
  String get scans             => _t('Scans',                   'مسح');

  // ── Historique ──────────────────────────────────────────────────────────────
  String get historiqueDesAcces => _t('Historique des Accès',   'سجل الوصول');
  String get rechercheHint      => _t('Rechercher par nom, matricule...',
                                      'بحث بالاسم أو الرقم...');
  String get filtresTous        => _t('Tous',                   'الكل');
  String get aucuneEntree       => _t('Aucune entrée trouvée',  'لا توجد إدخالات');
  String get modifierFiltres    => _t('Modifiez les filtres ou la recherche',
                                      'عدّل الفلاتر أو البحث');
  String get reessayer          => _t('Réessayer',              'إعادة المحاولة');
  String entrees(int n)         => _t('$n entrée(s)',           '$n إدخال(ات)');

  // ── Recherche ───────────────────────────────────────────────────────────────
  String get rechercheMatricule => _t('Recherche matricule',    'بحث بالمعرف');
  String get saisirNumero       => _t('Saisir le numéro de matricule du véhicule',
                                      'أدخل رقم معرف المركبة');
  String get resultRecherche    => _t('RÉSULTAT DE RECHERCHE',  'نتيجة البحث');
  String get aucunResultatMsg   => _t('Aucun résultat',         'لا نتائج');
  String get saisirMatricule    => _t('Saisissez un matricule et appuyez sur Rechercher',
                                      'أدخل الرقم واضغط بحث');
  String get validerEntree      => _t('Valider l\'entrée',      'تسجيل الدخول');
  String get enregistrement     => _t('Enregistrement...',      'جارٍ التسجيل...');
  String get accesEnregistre    => _t('Accès enregistré avec succès',
                                      'تم تسجيل الدخول بنجاح');
  String get erreurEnregistrement => _t('Erreur lors de l\'enregistrement de l\'accès',
                                        'خطأ في تسجيل الدخول');
  String get confirmerAcces     => _t('Confirmer l\'accès',     'تأكيد الوصول');
  String confirmerMsg(String plate) => _t(
    'Voulez-vous enregistrer l\'entrée du véhicule $plate ?',
    'هل تريد تسجيل دخول المركبة $plate؟',
  );
  String get confirmer          => _t('Confirmer',              'تأكيد');

  // ── Scanner ─────────────────────────────────────────────────────────────────
  String get scannerUnePlaqueTitle => _t('Scanner une plaque',  'مسح لوحة ترقيم');
  String get placerPlaque          => _t('Placez la plaque dans le cadre',
                                         'ضع اللوحة في الإطار');
  String get cadrerVehicule        => _t('Cadrez l\'arrière du véhicule dans le cadre',
                                         'ضع مؤخرة المركبة داخل الإطار');
  String get aucunePlaqueMsg       => _t(
    'Aucune plaque détectée. Réessayez ou utilisez la saisie manuelle.',
    'لم تُكتشف أي لوحة. أعد المحاولة أو استخدم الإدخال اليدوي.',
  );
  String get analyseEnCours        => _t('Analyse en cours... (2-5 secondes)',
                                         'جارٍ التحليل... (2-5 ثوان)');
  String get appuyerPourCapture    => _t('Appuyez sur le bouton pour capturer et analyser',
                                         'اضغط الزر للتقاط وتحليل');
  String get capturerEtScanner     => _t('Capturer et scanner',  'التقاط ومسح');
  String get analyseEnCoursBtn     => _t('Analyse en cours...',  'جارٍ التحليل...');
  String get scannerUnAutre        => _t('Scanner un autre',     'مسح آخر');
  String get ocrLu                 => _t('OCR lu',               'نص مقروء');
  String get correspondance        => _t('Correspondance',       'تطابق');
  String get similarite            => _t('Similarité',           'تشابه');
  String get marque                => _t('Marque',               'الماركة');
  String get couleur               => _t('Couleur',              'اللون');
  String get proprietaire          => _t('Propriétaire',         'المالك');
  String get service               => _t('Service',              'القسم');
  String get raison                => _t('Raison',               'السبب');
  String get statutPlaque          => _t('Statut',               'الحالة');
  String get plaqueNonDetectee     => _t('Plaque non détectée',  'لوحة غير مكتشفة');
  String get plaqueNonTrouvee      => _t('Plaque non trouvée en base',
                                         'لوحة غير موجودة');
  String get matricule             => _t('Matricule',            'رقم المعرف');

  // ── Paramètres ──────────────────────────────────────────────────────────────
  String get configSysteme         => _t('Configuration du système',  'إعدادات النظام');
  String get sectionProfil         => _t('PROFIL',                    'الملف الشخصي');
  String get sectionApparence      => _t('APPARENCE',                 'المظهر');
  String get modeSombre            => _t('Mode sombre',               'الوضع الداكن');
  String get modeClair             => _t('Mode clair',                'الوضع الفاتح');
  String get apparenceDesc         => _t('Choisir l\'apparence de l\'interface',
                                         'اختر مظهر الواجهة');
  String get sectionLangue         => _t('LANGUE',                    'اللغة');
  String get francais              => _t('Français',                  'الفرنسية');
  String get arabe                 => _t('Arabe',                     'العربية');
  String get sectionAPropos        => _t('A PROPOS',                  'حول');
  String get application           => _t('Application',               'التطبيق');
  String get version               => _t('Version',                   'الإصدار');
  String get organisation          => _t('Organisation',              'المؤسسة');
  String get stack                 => _t('Stack',                     'التقنية');
  String get seDeconnecter         => _t('Se déconnecter',            'تسجيل الخروج');
  String get agentSecurite         => _t('Agent de Sécurité',         'عون الأمن');
  String get email                 => _t('Email',                     'البريد الإلكتروني');
  String get telephone             => _t('Téléphone',                 'الهاتف');
  String get telephoneOptionnel    => _t('Téléphone (optionnel)',      'الهاتف (اختياري)');
  String get modifierProfil        => _t('Modifier le profil',        'تعديل الملف');
  String get nom                   => _t('Nom',                       'اللقب');
  String get prenom                => _t('Prénom',                    'الاسم');
  String get role                  => _t('Rôle',                      'الدور');
  String get modificationsServeur  => _t('Les modifications sont envoyées au serveur.',
                                         'سيتم إرسال التعديلات إلى الخادم.');
  String get profilMisAJour        => _t('Profil mis à jour avec succès.',
                                         'تم تحديث الملف الشخصي بنجاح.');

  // ── Statistiques ─────────────────────────────────────────────────────────────
  String get statistiquesTitle     => _t('Statistiques',              'إحصائيات');
  String get statsSubtitle         => _t('Tableau de bord d\'aujourd\'hui',
                                         'لوحة اليوم');
  String get scansAujourd          => _t('Scans aujourd\'hui',        'مسح اليوم');
  String get accesAujourd          => _t('Accès aujourd\'hui',        'وصول اليوم');
  String get repartitionDuJour     => _t('Répartition du jour',       'توزيع اليوم');
  String get acces7Jours           => _t('Accès 7 derniers jours',    'وصول آخر 7 أيام');
  String get distributionHoraire   => _t('Distribution horaire',      'التوزيع بالساعة');
  String get top5Vehicules         => _t('Top 5 véhicules',           'أكثر 5 مركبات');
  String get autorisesVsRefuses    => _t('Autorisés vs Refusés',      'مسموح مقابل مرفوض');
  String get aucunAcces            => _t('Aucun accès aujourd\'hui',  'لا وصول اليوم');

  // ── Notifications ────────────────────────────────────────────────────────────
  String get notifications         => _t('Notifications',             'الإشعارات');
  String nonLues(int n)            => _t('$n non lue(s)',             '$n غير مقروءة');
  String get toutLire              => _t('Tout lire',                 'قراءة الكل');
  String get marquerCommeLu        => _t('Marquer comme lu',          'تحديد كمقروء');
  String get toutMarquerCommeLu    => _t('Tout marquer comme lu',     'تحديد الكل كمقروء');
  String get aucuneNotification    => _t('Aucune notification',       'لا إشعارات');
  String get notifTraitees         => _t('Toutes les notifications ont été traitées',
                                         'تمت معالجة جميع الإشعارات');
  String get supprimerAlerte       => _t('Supprimer cette alerte',    'حذف هذا التنبيه');
  String get confirmerSupprAlerte  => _t('Voulez-vous supprimer cette alerte ?',
                                         'هل تريد حذف هذا التنبيه؟');
  String plaqueLabel(String plate) => _t('Plaque : $plate',           'اللوحة : $plate');

  // ── Traduction des messages de notification venant du serveur ───────────────
  String get titreAccesRefuse      => _t('Tentative d\'accès refusée',        'محاولة دخول مرفوضة');
  String get titreAccesExpire      => _t('Accès temporaire expiré',           'انتهاء صلاحية الدخول المؤقت');
  String get titreNotifLue         => _t('Notification lue — accès expiré',   'إشعار مقروء — دخول منتهي');
  String get titreDureeExpiree     => _t('Durée expirée',                     'انتهت المدة');
  String get titreAccesRefuseAlt   => _t('Accès refusé',                      'دخول مرفوض');

  /// Traduit un message de notification provenant du serveur.
  /// Détecte les patterns connus et les traduit ; sinon retourne le message tel quel.
  String traduireMessageNotif(String message) {
    if (!_ar) return message;

    // Pattern : "Le véhicule avec la plaque XXX a été refusé à l'entrée du site."
    final refusMatch = RegExp(r"Le véhicule avec la plaque (.+) a été refusé").firstMatch(message);
    if (refusMatch != null) {
      return 'تم رفض دخول المركبة ذات اللوحة ${refusMatch.group(1)} إلى الموقع.';
    }

    // Pattern : "L'accès temporaire de XXX (plaque YYY) est expiré depuis ZZZ."
    final expireMatch = RegExp(r"L'accès temporaire de (.+?) \(plaque (.+?)\) est expiré depuis (.+)\.").firstMatch(message);
    if (expireMatch != null) {
      return 'انتهت صلاحية الدخول المؤقت لـ ${expireMatch.group(1)} (اللوحة ${expireMatch.group(2)}) منذ ${expireMatch.group(3)}.';
    }

    // Pattern : "Accès visiteur XXX expiré..."
    final visiteurMatch = RegExp(r"Accès visiteur (.+?) expiré").firstMatch(message);
    if (visiteurMatch != null) {
      return 'انتهى دخول الزائر ${visiteurMatch.group(1)}.';
    }

    // Message non reconnu : retourner tel quel
    return message;
  }

  /// Traduit le titre d'une notification provenant du serveur.
  String traduireTitreNotif(String titre) {
    if (!_ar) return titre;

    final map = <String, String>{
      'Tentative d\'accès refusée': titreAccesRefuse,
      'Accès temporaire expiré': titreAccesExpire,
      'Notification lue — accès expiré': titreNotifLue,
      'Acces refuse': titreAccesRefuseAlt,
      'Duree expiree': titreDureeExpiree,
      'Acces expire': titreAccesExpire,
    };

    return map[titre] ?? titre;
  }

  // ── Statuts d'acces supplementaires ──────────────────────────────────────────
  String get enAttente             => _t('En attente',                'في الانتظار');
  String get entre                 => _t('Entré',                     'دخل');
  String get refusAcces            => _t('Refus d\'accès',            'رفض الدخول');
  String get dureeExpiree          => _t('Durée expirée',             'انتهت المدة');

  // ── Carte d'accès ────────────────────────────────────────────────────────────
  String get employeAT             => _t('Employé AT',                'موظف اتصالات الجزائر');
  String get visiteur              => _t('Visiteur',                  'زائر');
  String get permanent             => _t('Permanent',                 'دائم');
  String get temporaire            => _t('Temporaire',                'مؤقت');
  String get entreePrefix          => _t('Entrée : ',                 'دخول : ');
  String get sortiePrefix          => _t('Sortie  : ',                'خروج : ');
}

/// Accès raccourci aux traductions depuis n'importe quel build().
///
///   final l = context.l10n;
///   Text(l.connexion)
extension AppL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations(
        Provider.of<LocaleProvider>(this, listen: false).isArabic,
      );
}
