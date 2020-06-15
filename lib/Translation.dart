class Locale {
  String languageCode;
  String language;

  Locale(String languageCode, String language) {
    this.languageCode = languageCode;
    this.language = language;
  }

  static Locale FR = new Locale("FR","Francais");
  static Locale EN = new Locale("EN","English");
  static Locale findByCode(String code) {
    switch(code) {
      case "EN":
        return Locale.EN;
      case "FR":
        return Locale.FR;
      default:
        return Locale.FR;
    }
  }
  static List<Locale> getAllLocales() {
    List<Locale> l = new List<Locale>();
    l.add(Locale.FR);
    l.add(Locale.EN);
    return l;
  }
}


class LanguageManager {
  Locale locale;

  LanguageManager(Locale locale) {
    this.locale = locale;
  }


  static Map<String, Map<String, String>> _localizedValues = {
    'FR': {
      'app_name'                      : 'DemoArena',

      'tooltips_report'               : 'Signaler un bug',
      'tooltips_language'             : 'Changer la langue',
      'tooltips_close'                : 'Fermer',

      'login_please_connect'          : 'Veuillez vous connecter !',
      'login_username'                : 'Entrez votre nom d\'utilisateur :',
      'login_password'                : 'Entrez votre mot de passe :',
      'login_ine'                     : 'Numero INE :',
      'login_connect'                 : 'Se connecter',
      'login_savepwd'                 : 'Enregistrer le mot de passe',
      'login_validate'                : 'Valider',
      'login_captcha'                 : 'Entrez le captcha:',

      'login_format_empty'            : 'Champ vide',
      'login_format_ine_len'          : 'Longueur invalide',
      'login_format_ine_nan'          : 'N\'est pas un nombre',
      'login_format_donotmesswithme'  : 'LAISSE-MOI TANQUILLE !',
      'login_format_captcha'          : 'Longueur invalide',

      'status_text_please_login'      : 'Veuillez vous connecter',
      'status_text_connection_gteinfo': 'Connexion à GateInfo',
      'status_text_connected_gteinfo' : 'Connecté à GateInfo',
      'status_text_connection_dmoaren': 'Connexion à DemoArena',
      'status_text_enter_captcha'     : 'Entrez le captcha',
      'status_text_enter_validcaptcha': 'Validation du captcha',

      'toast_login_incorrect'         : 'Identifiants incorrects',
      'toast_captcha_invalid'         : 'Captcha invalide',
      'toast_ine_invalid'             : 'Numéro étudiant invalide',

      'display_grades'                : 'Notes',
      'display_absences'              : 'Absences',

      'display_loading'               : 'Chargement...',
      'display_empty'                 : 'Ouah, c\'est tellement vide !',

      'display_absences_from'         : 'De :',
      'display_absences_to'           : 'À :',
      'display_absences_reason'       : 'Raison :',

      'errors_amigus_not_here'        : 'Cookie AMIGUS non présent ! Utilisateur ou mot de passe incorrect',
      'errors_python_error'           : 'Erreur de l\'application ! La commande a retourné plus que 3 lignes (voir .demoarena.log)',
      'errors_lt_cookie'              : 'Impossible de lire le tag LT ! Deux problèmes possibles : serveur CAS hors-service ou erreur de l\'application (voir .demoarena-log)',
      'errors_unicorn'                : 'Une licorne sauvage a cassé l\'application ! Essaye de la relancer',

      'restart_required'              : 'Un redémarrage de l\'application pourrait être nécessaire',

      'no_internet'                   : 'Veuillez vérifier votre connexion Internet',
      'update_available'              : 'Une mise à jour est disponible sur Github (Derniere :latest / Actuelle :current)',
      'error'                         : 'L\'application a rencontré une erreur'
    },
    'EN': {
      'app_name'                      : 'DemoArena',

      'tooltips_report'               : 'Report a bug',
      'tooltips_language'             : 'Change language',
      'tooltips_close'                : 'Close',

      'login_please_connect'          : 'Please log in!',
      'login_username'                : 'Enter your username:',
      'login_password'                : 'Enter your password:',
      'login_ine'                     : 'Enter your student number:',
      'login_connect'                 : 'Login',
      'login_savepwd'                 : 'Save password',
      'login_validate'                : 'Validate',
      'login_captcha'                 : 'Enter the captcha:',

      'login_format_empty'            : 'Field empty',
      'login_format_ine_len'          : 'Invalid length',
      'login_format_ine_nan'          : 'Isn\'t a number',
      'login_format_donotmesswithme'  : 'DONT MESS WITH ME',
      'login_format_captcha'          : 'Invalid length',

      'status_text_please_login'      : 'You need to connect',
      'status_text_connection_gteinfo': 'Connecting to GateInfo',
      'status_text_connected_gteinfo' : 'Connected to GateInfo',
      'status_text_connection_dmoaren': 'Connection to DemoArena',
      'status_text_enter_captcha'     : 'Enter the captcha',
      'status_text_enter_validcaptcha': 'Captcha validation',

      'toast_login_incorrect'         : 'Wrong credentials',
      'toast_captcha_invalid'         : 'Wrong captcha',
      'toast_ine_invalid'             : 'Student number invalid',

      'display_grades'                : 'Grades',
      'display_absences'              : 'Absences',

      'display_loading'               : 'Loading...',
      'display_empty'                 : 'Wow, so empty!',

      'display_absences_from'         : 'From:',
      'display_absences_to'           : 'To:',
      'display_absences_reason'       : 'Reason:',

      'errors_amigus_not_here'        : 'AMIGUS Cookie missing ! Wrong user or password',
      'errors_python_error'           : 'App error ! The command returned more than 3 lines (see .demoarena.log)',
      'errors_lt_cookie'              : 'Impossible to read the LT tag ! Two possible issues: CAS Server down or app error (see .demoarena-log)',
      'errors_unicorn'                : 'A wild unicorn broke the app ! Try restarting it',

      'restart_required'              : 'An app restart might be needed',

      'no_internet'                   : 'Please check you internet connection',
      'update_available'              : 'Hey, there is an update available on Github (Latest :latest / Current :current)',
      'error'                         : 'The application has encountered an error'
    },
  };

  String get app_name{
    return _localizedValues[locale.languageCode]['app_name'];
  }

  String get tooltips_report{
    return _localizedValues[locale.languageCode]['tooltips_report'];
  }

  String get tooltips_language{
    return _localizedValues[locale.languageCode]['tooltips_language'];
  }

  String get tooltips_close{
    return _localizedValues[locale.languageCode]['tooltips_close'];
  }

  String get login_please_connect{
    return _localizedValues[locale.languageCode]['login_please_connect'];
  }

  String get login_username{
    return _localizedValues[locale.languageCode]['login_username'];
  }

  String get login_password{
    return _localizedValues[locale.languageCode]['login_password'];
  }

  String get login_ine{
    return _localizedValues[locale.languageCode]['login_ine'];
  }

  String get login_connect{
    return _localizedValues[locale.languageCode]['login_connect'];
  }

  String get login_savepwd{
    return _localizedValues[locale.languageCode]['login_savepwd'];
  }

  String get login_validate{
    return _localizedValues[locale.languageCode]['login_validate'];
  }

  String get login_captcha{
    return _localizedValues[locale.languageCode]['login_captcha'];
  }

  String get login_format_empty{
    return _localizedValues[locale.languageCode]['login_format_empty'];
  }

  String get login_format_ine_len{
    return _localizedValues[locale.languageCode]['login_format_ine_len'];
  }

  String get login_format_ine_nan{
    return _localizedValues[locale.languageCode]['login_format_ine_nan'];
  }

  String get login_format_donotmesswithme{
    return _localizedValues[locale.languageCode]['login_format_donotmesswithme'];
  }

  String get login_format_captcha{
    return _localizedValues[locale.languageCode]['login_format_captcha'];
  }

  String get status_text_please_login{
    return _localizedValues[locale.languageCode]['status_text_please_login'];
  }

  String get status_text_connection_gteinfo{
    return _localizedValues[locale.languageCode]['status_text_connection_gteinfo'];
  }

  String get status_text_connected_gteinfo{
    return _localizedValues[locale.languageCode]['status_text_connected_gteinfo'];
  }

  String get status_text_connection_dmoaren{
    return _localizedValues[locale.languageCode]['status_text_connection_dmoaren'];
  }

  String get status_text_enter_captcha{
    return _localizedValues[locale.languageCode]['status_text_enter_captcha'];
  }

  String get status_text_enter_validcaptcha{
    return _localizedValues[locale.languageCode]['status_text_enter_validcaptcha'];
  }

  String get toast_login_incorrect{
    return _localizedValues[locale.languageCode]['toast_login_incorrect'];
  }

  String get toast_captcha_invalid{
    return _localizedValues[locale.languageCode]['toast_captcha_invalid'];
  }

  String get toast_ine_invalid{
    return _localizedValues[locale.languageCode]['toast_ine_invalid'];
  }

  String get display_grades{
    return _localizedValues[locale.languageCode]['display_grades'];
  }

  String get display_absences{
    return _localizedValues[locale.languageCode]['display_absences'];
  }

  String get display_loading{
    return _localizedValues[locale.languageCode]['display_loading'];
  }

  String get display_empty{
    return _localizedValues[locale.languageCode]['display_empty'];
  }

  String get display_absences_from{
    return _localizedValues[locale.languageCode]['display_absences_from'];
  }

  String get display_absences_to{
    return _localizedValues[locale.languageCode]['display_absences_to'];
  }

  String get display_absences_reason{
    return _localizedValues[locale.languageCode]['display_absences_reason'];
  }

  String get errors_amigus_not_here{
    return _localizedValues[locale.languageCode]['errors_amigus_not_here'];
  }

  String get errors_python_error{
    return _localizedValues[locale.languageCode]['errors_python_error'];
  }

  String get errors_lt_cookie{
    return _localizedValues[locale.languageCode]['errors_lt_cookie'];
  }

  String get errors_unicorn{
    return _localizedValues[locale.languageCode]['errors_unicorn'];
  }

  String get restart_required{
    return _localizedValues[locale.languageCode]['restart_required'];
  }

  String get no_internet{
    return _localizedValues[locale.languageCode]['no_internet'];
  }

  String get update_available{
    return _localizedValues[locale.languageCode]['update_available'];
  }
  String get error{
    return _localizedValues[locale.languageCode]['error'];
  }
}
