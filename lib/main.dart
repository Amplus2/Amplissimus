import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schttp/schttp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'dsbapi.dart' as dsb;
import 'logging.dart' as log;
import 'prefs.dart';
import 'ui/error_screen.dart';
import 'ui/first_login.dart';
import 'ui/home_page.dart';
import 'uilib.dart';
import 'wpemails.dart';

class _Behavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext c, Widget w, AxisDirection d) => w;
}

class _App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  Widget build(BuildContext context) {
    rebuildWholeApp = () => setState(() {});
    return MaterialApp(
      title: AMP_APP,
      debugShowCheckedModeBanner: false,
      theme: prefs.themeData,
      home: ScrollConfiguration(
        behavior: _Behavior(),
        child: prefs.firstLogin ? FirstLogin() : AmpHomePage(0),
      ),
    );
  }
}

late void Function() rebuildWholeApp;
Prefs? _prefs;
Prefs get prefs => _prefs!;
final http = ScHttpClient(getCache: prefs.getCache, setCache: prefs.setCache);

Future<void> mockPrefs() async {
  _prefs = Prefs(null);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // fixes horrible things about android
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  log.info('prefs', 'Loading SharedPreferences...');
  _prefs = Prefs(await SharedPreferences.getInstance());
  log.info('prefs', 'SharedPreferences (hopefully successfully) loaded.');

  adjustStatusBarForeground();
  try {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      prefs.deleteCache((hash, val, ttl) => now > ttl);
    } catch (e) {
      log.err('CacheGC', e);
    }

    if (!prefs.firstLogin) {
      final d = dsb.updateWidget(true);
      await wpemailUpdate();
      await d;
    }

    runApp(_App());
  } catch (e) {
    log.err('Splash.initState', e);
    runApp(ErrorScreen());
  }
}
