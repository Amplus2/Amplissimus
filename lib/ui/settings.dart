import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';
import '../main.dart';
import '../touch_bar.dart';
import '../dsbapi.dart' as dsb;
import '../langs/language.dart';
import '../logging.dart';
import 'first_login.dart';
import '../uilib.dart';
import '../appinfo.dart';

import 'home_page.dart';

class Settings extends StatefulWidget {
  final AmpHomePageState parent;
  Settings(this.parent);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _usernameFormField = AmpFormField.username();
  late AmpFormField _passwordFormField;
  var _hide = true;
  late AmpFormField _wpeFormField;

  _SettingsState() {
    _passwordFormField =
        //has to be this bad, because widget.parent might be null at ctor call
        AmpFormField.password(onChange: () => widget.parent.rebuildDragDown());
    _wpeFormField = AmpFormField(
      initialValue: prefs.wpeDomain,
      label: () => Language.current.wpemailDomain,
      keyboardType: TextInputType.url,
      onChanged: (field) {
        prefs.wpeDomain = field.text.trim();
        widget.parent.rebuildDragDown();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          ampSwitchWithText(
            Language.current.useSystemTheme,
            prefs.useSystemTheme,
            (v) {
              setState(() => prefs.useSystemTheme = v);
              widget.parent.checkBrightness();
            },
          ),
          ampSwitchWithText(
            Language.current.darkMode,
            prefs.isDarkMode,
            (v) async {
              if (prefs.useSystemTheme) return;
              prefs.toggleDarkModePressed();
              setState(() => prefs.isDarkMode = v);
              await dsb.updateWidget(true);
              widget.parent.rebuild();
              rebuildWholeApp();
            },
          ),
          ampSwitchWithText(
            Language.current.highContrastMode,
            prefs.highContrast,
            (v) async {
              ampInfo('Settings', 'switching design mode');
              setState(() => prefs.highContrast = v);
              await dsb.updateWidget(true);
              widget.parent.rebuild();
            },
          ),
          ListTile(
            title: Text(Language.current.selectAccentColor),
            onTap: _showColorPickerDialog,
            trailing: Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.circle, color: prefs.accentColor, size: 28),
            ),
          ),
          Divider(),
          ampWidgetWithText(
            Language.current.changeStudentGroup,
            ampRow(
              [
                ampDropdownButton<String>(
                  value: prefs.classGrade,
                  items: dsb.grades,
                  onChanged: (v) {
                    setState(prefs.setClassGrade(v));
                    dsb.updateWidget(true);
                  },
                ),
                ampPadding(8),
                ampDropdownButton<String>(
                  value: prefs.classLetter,
                  items: dsb.letters,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => prefs.classLetter = v);
                    dsb.updateWidget(true);
                  },
                ),
              ],
            ),
          ),
          ampSwitchWithText(
            Language.current.filterPlans,
            prefs.oneClassOnly,
            (value) {
              setState(() => prefs.oneClassOnly = value);
              widget.parent.rebuildDragDown();
            },
          ),
          ampSwitchWithText(
            Language.current.parseSubjects,
            prefs.parseSubjects,
            (v) {
              setState(() => prefs.parseSubjects = v);
              widget.parent.rebuildDragDown();
            },
          ),
          Divider(),
          ampWidgetWithText(
            Language.current.changeLanguage,
            ampDropdownButton<Language>(
              value: isAprilFools
                  ? Language.fromCode(prefs.savedLangCode)
                  : Language.current,
              itemToDropdownChild: (i) => ampText(i.name),
              items: Language.all,
              onChanged: (v) {
                if (v == null) return;
                setState(() => Language.current = v);
                widget.parent.rebuildDragDown();
                initTouchBar(widget.parent.tabController);
              },
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: AutofillGroup(
              child: ampColumn([
                _usernameFormField.flutter(),
                _passwordFormField.flutter(
                  suffixIcon: ampHidePwdBtn(
                      _hide, () => setState(() => _hide = !_hide)),
                  obscureText: _hide,
                )
              ]),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: _wpeFormField.flutter(),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Card(
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async => showAboutDialog(
                    context: context,
                    applicationName: AMP_APP,
                    applicationVersion:
                        await appVersion + ' (' + await buildNumber + ')',
                    applicationIcon:
                        SvgPicture.asset('assets/logo.svg', height: 40),
                    children: [Text(Language.current.appInfo)],
                  ),
                  child: ampColumn(
                    [
                      ampIcon(Icons.info, Icons.info_outlined, 50),
                      ampPadding(4),
                      Text(Language.current.settingsAppInfo,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
          ),
          devOptions(),
        ],
      ),
    );
  }

  Widget devOptions() {
    if (!prefs.devOptionsEnabled) return ampNull;
    return ampColumn(
      [
        Divider(),
        ampSwitchWithText(
          'Entwickleroptionen aktiviert',
          prefs.devOptionsEnabled,
          (v) => setState(() => prefs.devOptionsEnabled = v),
        ),
        ampSwitchWithText(
          'JSON Cache erzwingen',
          prefs.forceJsonCache,
          (v) => setState(() => prefs.forceJsonCache = v),
        ),
        ampSwitchWithText(
          'Update Notifier',
          prefs.updatePopup,
          (v) => setState(() => prefs.updatePopup = v),
        ),
        ampSwitchWithText(
          Language.current.groupByClass,
          prefs.groupByClass,
          (v) {
            setState(() => prefs.groupByClass = v);
            widget.parent.rebuildDragDown();
          },
        ),
        Divider(),
        ListTile(
          title: ampText('Refreshtimer (Minuten)'),
          trailing: ampText('${prefs.timer}'),
          onTap: () => _inputTimerDialog(context),
        ),
        Divider(),
        ampPadding(5),
        ampRaisedButton('Print Cache', prefs.listCache),
        ampRaisedButton(
          'Clear Cache',
          () => prefs.deleteCache((hash, val, ttl) => true),
        ),
        ampRaisedButton(
          'Set Cache to Demo',
          () => prefs.dsbJsonCache = _demoCache,
        ),
        ampRaisedButton('Set Cache to Input', () => _cacheDialog(context)),
        ampRaisedButton('Log leeeeeEHREn', () => setState(ampClearLog)),
        ampRaisedButton(
            'först lockin', () => ampChangeScreen(FirstLogin(), context)),
        ampRaisedButton(
          'App-Daten löschen',
          () {
            ampDialog(
              context,
              title: 'App-Daten löschen',
              widgetBuilder: ampRow,
              children: (_, __) => [ampText('Sicher?')],
              actions: (context) => ampDialogButtonsSaveAndCancel(
                context,
                save: () async {
                  await prefs.clear();
                  exit(0);
                },
              ),
            );
          },
        ),
        ampLogWidget,
      ],
    );
  }

  String get _demoCache =>
      '[{"url":"https://example.com","preview_url":"https://example.com","preview":[],"day":4,"date":"4.12.2020 Freitag","subs":['
      '{"class":"5c","lesson":3,"org_teacher":"","sub_teacher":"Häußler","subject":"D","notes":"","free":false},'
      '{"class":"9b","lesson":6,"org_teacher":"","sub_teacher":"---","subject":"Bio","notes":"","free":true}]},'
      '{"url":"https://example.com","preview_url":"https://example.com","preview":[],"day":0,"date":"7.12.2020 Montag","subs":['
      '{"class":"5cd","lesson":2,"org_teacher":"","sub_teacher":"Wolf","subject":"Kath","notes":"","free":false},'
      '{"class":"6b","lesson":5,"org_teacher":"","sub_teacher":"Gnan","subject":"Kath","notes":"","free":false},'
      '{"class":"6c","lesson":3,"org_teacher":"","sub_teacher":"Albl","subject":"E","notes":"","free":false},'
      '{"class":"6c","lesson":4,"org_teacher":"","sub_teacher":"Fikrle","subject":"E","notes":"","free":false},'
      '{"class":"6c","lesson":6,"org_teacher":"","sub_teacher":"---","subject":"Frz","notes":"","free":true},'
      '{"class":"9c","lesson":6,"org_teacher":"","sub_teacher":"---","subject":"E","notes":"","free":true}]}]';

  void _cacheDialog(BuildContext context) {
    final cacheFormField = AmpFormField(
      initialValue: prefs.dsbJsonCache,
      label: () => 'Cache',
    );
    ampDialog(
      context,
      children: (_, __) => [cacheFormField.flutter()],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () {
          prefs.dsbJsonCache = cacheFormField.text.trim();
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  void _inputTimerDialog(BuildContext context) {
    final timerFormField = AmpFormField(
      initialValue: prefs.timer,
      keyboardType: TextInputType.number,
      label: () => 'Timer (Minuten)',
    );
    ampDialog(
      context,
      children: (_, __) => [timerFormField.flutter()],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () {
          try {
            setState(() => prefs.timer = int.parse(timerFormField.text.trim()));
          } catch (e) {
            return;
          }
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  void _showColorPickerDialog() {
    const materialColors = Colors.primaries;
    ampSimpleDialog(
      context,
      Wrap(
        children: materialColors
            .map(
              (c) => IconButton(
                icon: Icon(Icons.circle, color: c, size: 36),
                onPressed: () {
                  prefs.accentColor = c;
                  adjustStatusBarForeground();
                  widget.parent.rebuild();
                  rebuildWholeApp();
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
