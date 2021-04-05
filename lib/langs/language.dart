import 'dart:collection';

import 'dutch.dart';
import 'package:dsbuntis/dsbuntis.dart';
import '../main.dart';
import 'english.dart';
import 'german.dart';

abstract class Language {
  String get code;
  String get name;

  //
  //these are all of the translations hardcoded into the language classes
  //
  String get darkMode;
  String get useSystemTheme;
  String get highContrastMode;
  String get changeLanguage;
  String get parseSubjects;
  String get changeLogin;
  String get username;
  String get password;
  String get save;
  String get cancel;
  String get selectClass;
  String get settingsAppInfo;
  String get appInfo;
  String get start;
  String get settings;
  String get noLogin;
  String get allClasses;
  String get empty;
  String get done;
  String get timetable;
  String get setupTimetable;
  String get setupTimetableTitle;
  String get noSubs;
  String get subject;
  String get notes;
  String get editHour;
  String get teacher;
  String get freeLesson;
  String get filterTimetables;
  String get edit;
  String get substitution;
  String get changedAppearance;
  String get show;
  String get useForDsb;
  String get dismiss;
  String get open;
  String get update;
  String get wpemailDomain;
  String get openPlanInBrowser;
  String get groupByClass;
  String get changeStudentGroup;
  String get filterPlans;
  String get teachers;
  String get selectAccentColor;
  String get search;
  String get hapticFeedback;
  String plsUpdate(String oldVersion, String newVersion);
  String warnWrongDate(String date);
  String dayToString(Day day);
  String get dsbError;
  LinkedHashMap<String, String> get subjectLut;
  String dsbSubtoSubtitleNotFree(String subTeacher, String notesaddon);
  String dsbSubtoSubtitleFree(String notesaddon);
  String _notesaddon(Substitution sub) =>
      sub.notes.isNotEmpty ? ' (${sub.notes})' : '';
  String dsbSubtoSubtitle(Substitution sub) => sub.isFree
      ? dsbSubtoSubtitleFree(_notesaddon(sub))
      : dsbSubtoSubtitleNotFree(sub.subTeacher, _notesaddon(sub));

  //why tf doesnt this break?!
  static Language _current = fromCode(prefs.savedLangCode);
  static Language get current => isAprilFools ? Dutch() : _current;
  static set current(Language l) {
    prefs.savedLangCode = l.code;
    _current = l;
  }

  static final List<Language> _langs = [English(), German()];
  static List<Language> get all => _langs;

  static bool _strcontain(String s1, String s2) =>
      s1.contains(s2) || s2.contains(s1);

  static Language fromCode(String code) => _langs.firstWhere(
      (l) => _strcontain(code.toLowerCase(), l.code.toLowerCase()),
      orElse: () => _langs[0]);

  @override
  String toString() => name;
}

bool get isAprilFools {
  final now = DateTime.now();
  return now.day == 1 && now.month == 4;
}
