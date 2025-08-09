import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Silence Schedules',
      'tabHome': 'Home',
      'tabPast': 'Past Schedules',
      'noUpcoming': 'No upcoming schedules.',
      'noPast': 'No past schedules.',
      'noSchedules': 'No schedules yet.',
      'addSchedule': 'Add Schedule',
      'editSchedule': 'Edit Schedule',
      'scheduleTitle': 'Schedule Title',
      'selectStart': 'Start Date',
      'selectEnd': 'End Date',
      'start': 'Start',
      'end': 'End',
      'add': 'Add',
      'save': 'Save',
      'cancel': 'Cancel',
      'endAfterStart': 'End must be after start.',
      'today': 'Today',
      'globalTime': 'Global Time',
      'settings': 'Settings',
      'exportSchedules': 'Export Schedules',
      'importSchedules': 'Import Schedules',
      'exportedToFile':
          'Exported to schedules_export.json in app documents folder.',
      'exportFailed': 'Export failed.',
      'importedFromFile':
          'Imported from schedules.json in app documents folder.',
      'importFailed': 'Import failed.',
      'noExportFile': 'No schedules.json file found in app documents folder.',
    },
    'fr': {
      'appTitle': 'Horaires de silence',
      'tabHome': 'Accueil',
      'tabPast': 'Horaires passés',
      'noUpcoming': 'Aucun horaire à venir.',
      'noPast': 'Aucun horaire passé.',
      'noSchedules': 'Aucun horaire.',
      'addSchedule': 'Ajouter un horaire',
      'editSchedule': "Modifier l'horaire",
      'scheduleTitle': "Titre de l'horaire",
      'selectStart': 'Date de début',
      'selectEnd': 'Date de fin',
      'start': 'Début',
      'end': 'Fin',
      'add': 'Ajouter',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'endAfterStart': 'La fin doit être après le début.',
      'today': "Aujourd'hui",
      'globalTime': 'Heure mondiale',
      'settings': 'Paramètres',
      'exportSchedules': 'Exporter les horaires',
      'importSchedules': 'Importer les horaires',
      'exportedToFile':
          'Exporté vers schedules_export.json dans le dossier documents de l\'application.',
      'exportFailed': 'Échec de l\'exportation.',
      'importedFromFile':
          'Importé depuis schedules_export.json dans le dossier documents de l\'application.',
      'importFailed': 'Échec de l\'importation.',
      'noExportFile':
          'Aucun fichier schedules_export.json trouvé dans le dossier documents de l\'application.',
    },
  };

  String _t(String key) =>
      _localizedValues[locale.languageCode]?[key] ??
      _localizedValues['en']![key]!;

  String get appTitle => _t('appTitle');
  String get tabHome => _t('tabHome');
  String get tabPast => _t('tabPast');
  String get noUpcoming => _t('noUpcoming');
  String get noPast => _t('noPast');
  String get noSchedules => _t('noSchedules');
  String get addSchedule => _t('addSchedule');
  String get editSchedule => _t('editSchedule');
  String get scheduleTitle => _t('scheduleTitle');
  String get selectStart => _t('selectStart');
  String get selectEnd => _t('selectEnd');
  String get start => _t('start');
  String get end => _t('end');
  String get add => _t('add');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get endAfterStart => _t('endAfterStart');
  String get today => _t('today');
  String get globalTime => _t('globalTime');
  String get settings => _t('settings');
  String get exportSchedules => _t('exportSchedules');
  String get importSchedules => _t('importSchedules');
  String get exportedToFile => _t('exportedToFile');
  String get exportFailed => _t('exportFailed');
  String get importedFromFile => _t('importedFromFile');
  String get importFailed => _t('importFailed');
  String get noExportFile => _t('noExportFile');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
