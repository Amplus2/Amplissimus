import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:flutter/material.dart';

class CustomValues {
  static bool isAprilFools = false;
  static void checkForAprilFools() {
    var now = DateTime.now();
    isAprilFools = now.day == 1 && now.month == 4;
  }
  static Language _lang = Language.fromCode(Prefs.savedLangCode);
  static Language get lang => _lang;
  static set lang(Language l) {
    Prefs.savedLangCode = l.code;
    _lang = l;
  }
  static List<TTColumn> ttColums = [];
}

class AmpStrings {
  static const String appTitle = 'Amplissimus';
  static const String version = '0.0.0-1';
  static const List<String> authors = ['miruslavus', 'chrissx'];
}

class AmpColors {
  static MaterialColor _color(int code) {
    Color c = Color(code);
    return MaterialColor(code, {50: c, 100: c, 200: c, 300: c, 400: c, 500: c, 600: c, 700: c, 800: c, 900: c});
  }

  static MaterialColor _primaryBlack = _color(0xFF000000);
  static MaterialColor _primaryWhite = _color(0xFFFFFFFF);
  static MaterialColor get materialColorForeground => isDarkMode ? _primaryWhite : _primaryBlack;
  static MaterialColor get materialColorBackground => isDarkMode ? _primaryBlack : _primaryWhite;

  static final Color _blankBlack = Color.fromRGBO(0, 0, 0, 1);
  static final Color _blankWhite = Color.fromRGBO(255, 255, 255, 1);
  static final Color _greyBlack = Color.fromRGBO(75, 75, 75, 1);
  static final Color _lightWhite = Color.fromRGBO(25, 25, 25, 1);
  static final Color _greyWhite = Color.fromRGBO(200, 200, 200, 1);
  static final Color _lightBlack = Color.fromRGBO(220, 220, 220, 1);

  static Color get blankGrey => isDarkMode ? _greyBlack : _greyWhite;
  static Color get lightForeground => isDarkMode ? _lightWhite : _lightBlack;
  static Color get colorBackground => isDarkMode ? _blankBlack : _blankWhite;
  static Color get colorForeground => isDarkMode ? _blankWhite : _blankBlack;

  static TextStyle get textStyleForeground => TextStyle(color: colorForeground);
  static TextStyle get textStyleBackground => TextStyle(color: colorBackground);

  static bool isDarkMode = true;
  static void changeMode() => setMode(!isDarkMode);
  static void setMode(bool _isDarkMode) {
    if(_isDarkMode == null) return;
    isDarkMode = _isDarkMode;
    Prefs.designMode = isDarkMode;
    ampInfo(ctx: 'AmpColors', message: 'set isDarkMode = $isDarkMode');
  }

  static TweenSequenceItem _rainbowSequenceElement(MaterialColor begin, MaterialColor end) {
    return TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: begin, end: end));
  }

  static final Animatable<Color> rainbowBackgroundAnimation = TweenSequence<Color>(
    [
      _rainbowSequenceElement(Colors.red, Colors.green),
      _rainbowSequenceElement(Colors.green, Colors.blue),
      _rainbowSequenceElement(Colors.blue, Colors.pink),
    ],
  );
  
}