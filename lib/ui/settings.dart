import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../appinfo.dart';
import '../constants.dart';
import '../dsbapi.dart' as dsb;
import '../langs/language.dart';
import '../logging.dart' as log;
import '../main.dart';
import '../touch_bar.dart';
import '../uilib.dart';
import 'first_login.dart';

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
            // chrissx, don't remove this
            prefs.useSystemTheme
                ? null
                : (v) async {
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
              log.info('Settings', 'switching design mode');
              setState(() => prefs.highContrast = v);
              await dsb.updateWidget(true);
              widget.parent.rebuild();
            },
          ),
          ampSwitchWithText(
            Language.current.hapticFeedback,
            prefs.hapticFeedback,
            (value) {
              setState(() => prefs.hapticFeedback = value);
              widget.parent.rebuildDragDown();
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
            Language.current.filterPlans,
            ampRow(
              [
                ampDropdownButton<String>(
                  value: prefs.classGrade,
                  items: dsb.grades,
                  onChanged: (v) {
                    setState(prefs.setClassGrade(v));
                    dsb.updateWidget(true);
                  },
                  enabled: prefs.oneClassOnly,
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
                  enabled: prefs.oneClassOnly,
                ),
                ampPadding(4),
                ampSwitch(
                  prefs.oneClassOnly,
                  (value) {
                    setState(() => prefs.oneClassOnly = value);
                    widget.parent.rebuildDragDown();
                  },
                ),
              ],
            ),
          ),
          ampSwitchWithText(
            Language.current.groupByClass,
            prefs.groupByClass,
            (v) {
              setState(() => prefs.groupByClass = v);
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
              onChanged: (v) async {
                if (v == null) return;
                setState(() => Language.current = v);
                await dsb.updateWidget(true);
                widget.parent.rebuild();
                rebuildWholeApp();
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
                    applicationVersion: '$appVersion ($buildNumber)',
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
        Divider(),
        ampPadding(5),
        ampRaisedButton('Print HTTP Cache', prefs.listCache),
        ampRaisedButton(
          'Clear HTTP Cache',
          () => prefs.deleteCache((hash, val, ttl) => true),
        ),
        ampRaisedButton(
          'Set JSON Cache to Demo',
          () => prefs.dsbJsonCache = _demoCache,
        ),
        ampRaisedButton('Clear Log', () => setState(log.clear)),
        ampRaisedButton('Den Firsten einsperren',
            () => ampChangeScreen(FirstLogin(), context)),
        ampRaisedButton(
          'App-Daten löschen',
          () {
            ampStatelessDialog(
              context,
              ampText('Sicher?'),
              title: 'App-Daten löschen',
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
        log.widget,
      ],
    );
  }

  void _showColorPickerDialog() {
    hapticFeedback();
    const materialColors = Colors.primaries;
    ampStatelessDialog(
      context,
      Wrap(
        children: materialColors
            .map(
              (c) => IconButton(
                icon: Icon(Icons.circle, color: c, size: 36),
                onPressed: () {
                  hapticFeedback();
                  prefs.accentColor = c;
                  adjustStatusBarForeground();
                  widget.parent.rebuildDragDown();
                  rebuildWholeApp();
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
      actions: (_) => [],
    );
  }

  String get _demoCache => jsonEncode([
        {
          'url': 'https://example.com',
          'preview_url': 'https://example.com',
          'preview': [],
          'day': 4,
          'date': '2.4.2021 Freitag',
          'subs': [
            {
              'class': '5c',
              'lesson': 3,
              'sub_teacher': 'Häußler',
              'subject': 'D',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '9b',
              'lesson': 6,
              'sub_teacher': '---',
              'subject': 'Bio',
              'notes': '',
              'free': true,
              'org_teacher': null,
              'room': null,
            }
          ]
        },
        {
          'url': 'https://example.com',
          'preview_url': 'https://example.com',
          'preview': [],
          'day': 0,
          'date': '5.4.2021 Montag',
          'subs': [
            {
              'class': '5cd',
              'lesson': 2,
              'sub_teacher': 'Wolf',
              'subject': 'Kath',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '6b',
              'lesson': 5,
              'sub_teacher': 'Gnan',
              'subject': 'Kath',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '6c',
              'lesson': 3,
              'sub_teacher': 'Albl',
              'subject': 'E',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '6c',
              'lesson': 4,
              'sub_teacher': 'Fikrle',
              'subject': 'E',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '6c',
              'lesson': 6,
              'sub_teacher': '---',
              'subject': 'Frz',
              'notes': '',
              'free': true,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '9c',
              'lesson': 6,
              'sub_teacher': '---',
              'subject': 'E',
              'notes': '',
              'free': true,
              'org_teacher': null,
              'room': null,
            }
          ]
        }
      ]);
}
