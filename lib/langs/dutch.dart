import 'dart:collection';

import 'package:dsbuntis/dsbuntis.dart';

import '../constants.dart';
import 'language.dart';

class Dutch extends Language {
  @override
  String get appInfo =>
      '$AMP_APP is een app om eenvoudig vervangingsplannen van Untis te bekijken via DSBMobile.';

  @override
  String get code => 'nl';

  @override
  String get settings => 'Instellingen';

  @override
  String get start => 'Start';

  @override
  String get name => 'Nederlands';

  @override
  String get settingsAppInfo => 'App-informatie';

  @override
  String get highContrastMode => 'Modus met hoog contrast';

  @override
  String get changeLogin => 'Login gegevens';

  @override
  String get selectClass => 'Selecteer een klas';

  @override
  String get useSystemTheme => 'Gebruik systeemontwerp';

  @override
  String get filterTimetables => 'Filter de dienstregeling';

  @override
  String get edit => 'Aanpassen';

  @override
  String get substitution => 'Stand-in';

  @override
  String dsbSubtoSubtitle(Substitution sub) {
    final notesaddon = sub.notes.isNotEmpty ? ' (${sub.notes})' : '';

    return sub.isFree
        ? 'Vrije periode$notesaddon'
        : 'Vertegenwoordigd door ${sub.subTeacher}$notesaddon';
  }

  @override
  String get dsbError =>
      'Controleer uw internetverbinding en zorg ervoor dat de inloggegevens correct zijn.';

  @override
  String get noLogin => 'Geen inloggegevens ingevoerd.';

  @override
  String get empty => 'Leeg';

  @override
  String get password => 'Wachtwoord';

  @override
  String get username => 'DSBMobile-ID';

  @override
  String get save => 'Opslaan';

  @override
  String get cancel => 'Afbreken';

  @override
  String get allClasses => 'Alle klassen';

  @override
  String get changeLanguage => 'Taal wijzigen';

  @override
  String get done => 'Afgewerkt';

  @override
  String get timetable => 'Rooster';

  @override
  String get setupTimetable => 'Stel het\ntijdschema in';

  @override
  String get setupTimetableTitle => 'Stel het tijdschema in';

  @override
  String get subject => 'Onderwerpen';

  @override
  String get notes => 'Opmerkingen';

  @override
  String get editHour => 'Uurlijkse bewerken';

  @override
  String get teacher => 'Leraar';

  @override
  String get freeLesson => 'Vrij';

  @override
  final LinkedHashMap<String, String> subjectLut = LinkedHashMap.from({
    'spo': 'Sport',
    'e': 'Engels',
    'ev': 'Evangelische religie',
    'et': 'Ethiek',
    'd': 'Duitse',
    'i': 'Informatica',
    'g': 'Geschiedenis',
    'geo': 'Aardrijkskunde',
    'l': 'Latijns',
    'it': 'Italiaans',
    'f': 'Frans',
    'frz': 'Frans',
    'so': 'Sociale Studies',
    'sk': 'Sociale Studies',
    'm': 'Wiskunde',
    'mu': 'Muziek',
    'b': 'Biologie',
    'bwl': 'Bedrijfskunde',
    'c': 'Scheikunde',
    'k': 'Kunst',
    'ka': 'Katholieke religie',
    'p': 'Fysica',
    'ps': 'Psychologie',
    'w': 'Economie/Recht',
    'w/r': 'Economie/Recht',
    'w&r': 'Economie/Recht',
    'nut': 'Natuur en technologie',
    'spr': 'Spreekuur',
  });

  @override
  String get darkMode => 'Donkere modus';

  @override
  String dayToString(Day day) {
    switch (day) {
      case Day.Null:
        return '';
      case Day.Monday:
        return 'Maandag';
      case Day.Tuesday:
        return 'Dinsdag';
      case Day.Wednesday:
        return 'Woensdag';
      case Day.Thursday:
        return 'Donderdag';
      case Day.Friday:
        return 'Vrijdag';
      default:
        throw UnimplementedError('Onbekende dag!');
    }
  }

  @override
  String get noSubs => 'Geen voorstellingen';

  @override
  String get changedAppearance => 'Uiterlijk vervangingsplan gewijzigd!';

  @override
  String get show => 'Tonen';

  @override
  String get useForDsb => 'Verzenden naar DPO (niet aanbevolen)';

  @override
  String get dismiss => 'Afsluiten';

  @override
  String get open => 'Openen';

  @override
  String get update => 'Bijwerken';

  @override
  String plsUpdate(String oldVersion, String newVersion) =>
      'Een update is beschikbaar: $oldVersion → $newVersion';

  @override
  String get wpemailDomain => 'Webadres van uw school (voorbeeld.nl)';

  @override
  String get openPlanInBrowser => 'Open plan in browser';

  @override
  String get parseSubjects => 'Vertaal onderwerpen';

  @override
  String warnWrongDate(String date) =>
      'Het lijkt erop dat dit vervangingsplan achterhaald is. (Datum: "$date")';

  @override
  String get groupByClass => 'Groepeer per klas';

  @override
  String get changeStudentGroup => 'Verander van klas';

  @override
  String get filterPlans => 'Filter vervangingsplannen';

  @override
  String get teachers => 'Leraren';

  @override
  String get selectAccentColor => 'Kies een accentkleur';

  @override
  String get search => 'Zoeken';
}
