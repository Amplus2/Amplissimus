import '../dsbapi.dart';
import '../langs/language.dart';
import '../logging.dart';
import '../main.dart';
import 'dev_options.dart';
import '../uilib.dart';
import 'package:flutter/material.dart';
import '../prefs.dart' as Prefs;
import '../colors.dart' as AmpColors;
import '../appinfo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pedantic/pedantic.dart';

class Settings extends StatefulWidget {
  final AmpHomePageState parent;
  Settings(this.parent);

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<Null> credentialDialog() {
    final usernameFormField = AmpFormField(Prefs.username);
    final passwordFormField = AmpFormField(Prefs.password);
    var passwordHidden = true;
    return ampDialog(
      context: context,
      title: Language.current.changeLoginPopup,
      children: (context, setAlState) => [
        ampPadding(2),
        usernameFormField.formField(
          labelText: Language.current.username,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: [AutofillHints.username],
        ),
        ampPadding(6),
        passwordFormField.formField(
          suffixIcon: IconButton(
            onPressed: () => setAlState(() => passwordHidden = !passwordHidden),
            icon: passwordHidden
                ? ampIcon(Icons.visibility_outlined)
                : ampIcon(Icons.visibility_off_outlined),
          ),
          labelText: Language.current.password,
          keyboardType: TextInputType.visiblePassword,
          obscureText: passwordHidden,
          autofillHints: [AutofillHints.password],
        )
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () async {
          Prefs.username = usernameFormField.text.trim();
          Prefs.password = passwordFormField.text.trim();
          unawaited(widget.parent.rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      color: Colors.transparent,
      child: Scaffold(
        appBar: ampAppBar(Language.current.settings),
        backgroundColor: Colors.transparent,
        body: ListView(
          children: [
            ampSwitchWithText(
              Language.current.darkMode,
              AmpColors.isDarkMode,
              (v) async {
                Prefs.toggleDarkModePressed();
                Prefs.useSystemTheme = false;
                AmpColors.isDarkMode = v;
                await dsbUpdateWidget();
                Future.delayed(
                  Duration(milliseconds: 150),
                  widget.parent.rebuild,
                );
              },
            ),
            ampSwitchWithText(
              Language.current.lightsUseSystem,
              Prefs.useSystemTheme,
              (v) {
                Prefs.useSystemTheme = v;
                widget.parent.checkBrightness();
              },
            ),
            ampSwitchWithText(
              Language.current.alternativeAppearance,
              Prefs.altTheme,
              (v) async {
                ampInfo('Settings', 'switching design mode');
                Prefs.altTheme = v;
                await dsbUpdateWidget();
                widget.parent.rebuild();
                scaffoldMessanger.showSnackBar(ampSnackBar(
                  Language.current.changedAppearance,
                  Language.current.show,
                  () => widget.parent.tabController.index = 0,
                ));
              },
            ),
            ampDivider,
            ListTile(
              //TODO: might want to change that label
              title: ampText(Language.current.changeLanguage),
              trailing: ampDropdownButton(
                value: Language.current,
                itemToDropdownChild: (i) => ampText(i.name),
                items: Language.all,
                onChanged: (v) {
                  setState(() => Language.current = v);
                  widget.parent.rebuildDragDown();
                },
              ),
            ),
            ampSwitchWithText(
              Language.current.useForDsb,
              Prefs.dsbUseLanguage,
              (v) {
                setState(() => Prefs.dsbUseLanguage = v);
                widget.parent.rebuildDragDown();
              },
            ),
            ampDivider,
            ListTile(
              //TODO: see above
              title: ampText(Language.current.selectClass),
              trailing: ampRow(
                [
                  ampDropdownButton(
                    value: Prefs.grade,
                    items: dsbGrades,
                    onChanged: (value) => setState(() {
                      Prefs.grade = value;
                      try {
                        if (int.parse(value) > 10) Prefs.char = '';
                        // ignore: empty_catches
                      } catch (e) {}
                    }),
                  ),
                  ampPadding(8),
                  ampDropdownButton(
                    value: Prefs.char,
                    items: dsbLetters,
                    onChanged: (value) => setState(() => Prefs.char = value),
                  ),
                ],
              ),
            ),
            ampSwitchWithText(
              'TODO: parse subjects',
              Prefs.parseSubjects,
              (v) => setState(() => Prefs.parseSubjects = v),
            ),
            ampDivider,
            Row(
              children: [
                ampBigButton(
                  Language.current.changeLogin,
                  Icons.vpn_key_outlined,
                  () => credentialDialog(),
                ),
                ampBigButton(
                  Language.current.settingsAppInfo,
                  Icons.info_outline,
                  () => showAboutDialog(
                    context: context,
                    applicationName: appTitle,
                    applicationVersion: appVersion,
                    applicationIcon:
                        SvgPicture.asset('assets/logo.svg', height: 40),
                    children: [Text(Language.current.appInfo)],
                    //TODO: flame flutter people for not letting me set the
                    //background color
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
            DevOptions(),
          ],
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }
}
