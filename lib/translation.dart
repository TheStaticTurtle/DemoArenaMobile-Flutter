class Locale {
  String languageCode;
  String language;

  Locale(String languageCode, String language) {
    this.languageCode = languageCode;
    this.language = language;
  }
  static Set<Locale> avalibleLocales = {
    new Locale("FR","Francais"),
    new Locale("EN","English"),
  };
}


class LanguageManager {
  Locale locale;

  LanguageManager(Locale locale) {
    this.locale = locale;
  }


  static Map<String, Map<String, String>> _localizedValues = {
    'FR': {
      'app_name                      ': 'DemoArena',
      'login_please_connect          ': 'Veuillez vous connecter!',
      'login_user                    ': 'Utilisateur:',
      'login_ine                     ': 'Numero INE:',
      'login_password                ': 'Mot de passe:',
      'login_connect                 ': 'Se connecter',
      'login_savepwd                 ': 'Enregistrer le mot de passe',
      'login_gateinfo_connected      ': 'Application connectée a gateinfo',
      'stage2_captcha                ': 'Veuillez completer le captcha.',
      'stage2_invalidCaptcha         ': 'Captcha invalide.',
      'stage1_incorrect              ': 'Mot de passe ou Utilisateur incorrect',
      'stage2_faliedine              ': 'Numero INE incorrect.',
      'viewer_grades                 ': 'Notes',
      'viewer_absences               ': 'Absences',
      'viewer_absences_from          ': 'De:',
      'viewer_absences_to            ': 'A: ',
      'viewer_absences_cause         ': 'Raison:',
      'viewer_absences_cause_unknown ': 'Inconnue',
      'viewer_grades_moygene         ': 'Moyenne generale',
      'viewer_grades_grade           ': 'Note:',
      'viewer_grades_min             ': 'Min',
      'viewer_grades_max             ': 'Max',
      'viewer_grades_coeff           ': 'Coeff',
      'pretty_errors_connection_reset': 'Connection impossible.',
      'pretty_errors_soft_abort      ': 'Erreur logiciel.',
      'pretty_errors_auth_fail       ': 'Erreur d\'authentification (Mot de passe ou utilisateur incorrect)',
      'pretty_errors_unknown         ': 'Erreur inconnue.',
      'dialog_ok                     ': 'Ok ',
      'dialog_error                  ': 'Erreur!',
      'no_internet                   ': 'Pas de connexion Internet',
      'no_internet_message           ': 'Il semblerait que vous n\'êtes pas connecté à Internet. Veuillez vous assurer que vous êtes en ligne et réessayez.',
      'action_newversion             ': 'Nouvelle version',
      'action_actualversion          ': 'Version actuelle',
      'action_newupdate              ': 'Mise à jour disponible',
      'report_bug                    ': 'Report un bug',
    },
    'EN': {
      'title': 'DemoArena',
    },
  };

  String get app_name {
    return _localizedValues[locale.languageCode]['app_name'];
  }

  String get login_please_connect {
    return _localizedValues[locale.languageCode]['login_please_connect'];
  }

  String get login_user {
    return _localizedValues[locale.languageCode]['login_user'];
  }

  String get login_ine {
    return _localizedValues[locale.languageCode]['login_ine'];
  }

  String get login_password {
    return _localizedValues[locale.languageCode]['login_password'];
  }

  String get login_connect {
    return _localizedValues[locale.languageCode]['login_connect'];
  }

  String get login_savepwd {
    return _localizedValues[locale.languageCode]['login_savepwd'];
  }

  String get login_gateinfo_connected {
    return _localizedValues[locale.languageCode]['login_gateinfo_connected'];
  }

  String get stage2_captcha {
    return _localizedValues[locale.languageCode]['stage2_captcha'];
  }

  String get stage2_invalidCaptcha {
    return _localizedValues[locale.languageCode]['stage2_invalidCaptcha'];
  }

  String get stage1_incorrect {
    return _localizedValues[locale.languageCode]['stage1_incorrect'];
  }

  String get stage2_faliedine {
    return _localizedValues[locale.languageCode]['stage2_faliedine'];
  }

  String get viewer_grades {
    return _localizedValues[locale.languageCode]['viewer_grades'];
  }

  String get viewer_absences {
    return _localizedValues[locale.languageCode]['viewer_absences'];
  }

  String get viewer_absences_from {
    return _localizedValues[locale.languageCode]['viewer_absences_from'];
  }

  String get viewer_absences_to {
    return _localizedValues[locale.languageCode]['viewer_absences_to'];
  }

  String get viewer_absences_cause {
    return _localizedValues[locale.languageCode]['viewer_absences_cause'];
  }

  String get viewer_absences_cause_unknown {
    return _localizedValues[locale.languageCode]['viewer_absences_cause_unknown'];
  }

  String get viewer_grades_moygene {
    return _localizedValues[locale.languageCode]['viewer_grades_moygene'];
  }

  String get viewer_grades_grade {
    return _localizedValues[locale.languageCode]['viewer_grades_grade'];
  }

  String get viewer_grades_min {
    return _localizedValues[locale.languageCode]['viewer_grades_min'];
  }

  String get viewer_grades_max {
    return _localizedValues[locale.languageCode]['viewer_grades_max'];
  }

  String get viewer_grades_coeff {
    return _localizedValues[locale.languageCode]['viewer_grades_coeff'];
  }

  String get pretty_errors_connection_reset {
    return _localizedValues[locale.languageCode]['pretty_errors_connection_reset'];
  }

  String get pretty_errors_soft_abort {
    return _localizedValues[locale.languageCode]['pretty_errors_soft_abort'];
  }

  String get pretty_errors_auth_fail {
    return _localizedValues[locale.languageCode]['pretty_errors_auth_fail'];
  }

  String get pretty_errors_unknown {
    return _localizedValues[locale.languageCode]['pretty_errors_unknown'];
  }

  String get dialog_ok {
    return _localizedValues[locale.languageCode]['dialog_ok'];
  }

  String get dialog_error {
    return _localizedValues[locale.languageCode]['dialog_error'];
  }

  String get no_internet {
    return _localizedValues[locale.languageCode]['no_internet'];
  }

  String get no_internet_message {
    return _localizedValues[locale.languageCode]['no_internet_message'];
  }

  String get action_newversion {
    return _localizedValues[locale.languageCode]['action_newversion'];
  }

  String get action_actualversion {
    return _localizedValues[locale.languageCode]['action_actualversion'];
  }

  String get action_newupdate {
    return _localizedValues[locale.languageCode]['action_newupdate'];
  }

  String get report_bug {
    return _localizedValues[locale.languageCode]['report_bug'];
  }
}
