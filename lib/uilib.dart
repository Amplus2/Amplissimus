import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'langs/language.dart';
import 'logging.dart';
import 'main.dart';

List<Widget> _okAction(BuildContext ctx) =>
    [ampDialogButton('OK', Navigator.of(ctx).pop)];

Future<Null> ampDialog(
  BuildContext context, {
  String? title,
  required List<Widget> Function(BuildContext, StateSetter) children,
  required Widget Function(List<Widget>) widgetBuilder,
  List<Widget> Function(BuildContext) actions = _okAction,
  bool barrierDismissible = true,
}) =>
    ampStatelessDialog(
      context,
      StatefulBuilder(
        builder: (alertContext, setAlState) => widgetBuilder(
          children(alertContext, setAlState),
        ),
      ),
      actions: actions,
      barrierDismissible: barrierDismissible,
      title: title,
    );

Future<Null> ampStatelessDialog(
  BuildContext context,
  Widget child, {
  List<Widget> Function(BuildContext) actions = _okAction,
  bool barrierDismissible = true,
  String? title,
}) =>
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: child,
        actions: actions(context),
      ),
    );

final ampNull = Container(width: 0, height: 0);

Column ampColumn(List<Widget> children) =>
    Column(mainAxisSize: MainAxisSize.min, children: children);

Row ampRow(List<Widget> children) =>
    Row(mainAxisSize: MainAxisSize.min, children: children);

TextButton ampDialogButton(String text, Function() onPressed) =>
    TextButton(onPressed: onPressed, child: Text(text));

DropdownButton<T> ampDropdownButton<T>({
  required T value,
  required List<T> items,
  required void Function(T?)? onChanged,
  Widget Function(T)? itemToDropdownChild,
}) =>
    DropdownButton<T>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(
              value: e, child: (itemToDropdownChild ?? ampText)(e)))
          .toList(),
      onTap: hapticFeedback,
      onChanged:
          onChanged != null ? (v) => {hapticFeedback(), onChanged(v)} : null,
    );

Switch ampSwitch(bool value, [Function(bool)? onChanged]) =>
    Switch(value: value, onChanged: onChanged);

ListTile ampSwitchWithText(String text, bool value,
        [Function(bool)? onChanged]) =>
    ampWidgetWithText(text, ampSwitch(value, onChanged));

ListTile ampWidgetWithText(String text, Widget w, [Function()? onTap]) =>
    ListTile(
      title: Text(text),
      trailing: w,
      onTap: onTap != null ? () => {hapticFeedback(), onTap()} : null,
    );

List<Widget> ampDialogButtonsSaveAndCancel(BuildContext context,
    {required Function() save, String? cancelLabel, String? saveLabel}) {
  return [
    ampDialogButton(cancelLabel ?? Language.current.cancel,
        () => {hapticFeedback(), Navigator.of(context).pop()}),
    ampDialogButton(
        saveLabel ?? Language.current.save, () => {hapticFeedback(), save()}),
  ];
}

ElevatedButton ampRaisedButton(String text, void Function()? onPressed) =>
    ElevatedButton(
        onPressed:
            onPressed != null ? () => {hapticFeedback(), onPressed()} : null,
        child: Text(text));

Padding ampPadding(double value, [Widget? child]) =>
    Padding(padding: EdgeInsets.all(value), child: child);

Text ampText<T>(
  T text, {
  double? size,
  TextAlign? align,
  FontWeight? weight,
  Color? color,
  String Function(T)? toString,
  List<String>? font,
}) {
  toString ??= (o) => o.toString();
  font ??= [];
  final style = TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    fontFamily: font.isNotEmpty ? font.first : null,
    fontFamilyFallback: font,
  );
  return Text(toString(text), style: style, textAlign: align);
}

AppBar ampTitle(String text) => AppBar(title: Text(text));

Icon ampIcon(IconData lowContrast, IconData highContrast, [double? size]) =>
    Icon(prefs.highContrast ? highContrast : lowContrast, size: size);

IconButton ampHidePwdBtn(bool hidden, Function() setHidden) => IconButton(
      onPressed: () => {hapticFeedback(), setHidden()},
      icon: hidden
          ? ampIcon(Icons.visibility_off, Icons.visibility_off_outlined)
          : ampIcon(Icons.visibility, Icons.visibility_outlined),
    );

Future ampChangeScreen(
  Widget w,
  BuildContext context, [
  Future Function(BuildContext, Route) push = Navigator.pushReplacement,
]) =>
    push(context, MaterialPageRoute(builder: (_) => w));

Widget ampList(List<Widget> children) {
  if (!prefs.highContrast) {
    return Card(
      margin: EdgeInsets.only(left: 15, right: 15),
      elevation: 0,
      color: Color(prefs.isDarkMode ? 0xff101010 : 0xffefefef),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ampColumn(children),
    );
  } else {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: prefs.isDarkMode ? Colors.white : Colors.black,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ampColumn(children),
    );
  }
}

Future<Null> ampOpenUrl(String url) => url_launcher.canLaunch(url).then((b) {
      if (b) url_launcher.launch(url);
    });

Widget ampErrorText(dynamic e) => ampPadding(
    8,
    ampText(
      errorString(e),
      color: Colors.red,
      weight: FontWeight.bold,
      size: 16,
    ));

Icon ampColorCircle(Color c) => Icon(Icons.circle, color: c, size: 36);

class AmpFormField {
  final key = GlobalKey<FormFieldState>();
  final TextEditingController controller;
  final List<String> autofillHints;
  final TextInputType keyboardType;
  final String Function() label;
  final void Function(AmpFormField) onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  static String _noLabel() => '';

  AmpFormField({
    Object initialValue = '',
    this.autofillHints = const [],
    this.keyboardType = TextInputType.text,
    this.label = _noLabel,
    this.onChanged = _noChange,
    this.onFieldSubmitted,
    this.focusNode,
  }) : controller = TextEditingController(text: initialValue.toString());

  static void _noChange(AmpFormField _) {}

  Widget flutter({Widget? suffixIcon, bool obscureText = false}) {
    return ampColumn(
      [
        ampPadding(
          2,
          TextFormField(
            onChanged: (_) => onChanged(this),
            obscureText: obscureText,
            controller: controller,
            key: key,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            decoration: InputDecoration(
              labelText: label(),
              suffixIcon: suffixIcon,
            ),
            onTap: hapticFeedback,
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted,
          ),
        ),
      ],
    );
  }

  String get text => controller.text;

  static AmpFormField username({
    Function()? rebuild,
    void Function(String)? onFieldSubmitted,
    FocusNode? focusNode,
  }) =>
      AmpFormField(
        initialValue: prefs.username,
        label: () => Language.current.username,
        keyboardType: TextInputType.number,
        autofillHints: [AutofillHints.username],
        onChanged: (field) {
          prefs.username = field.text.trim();
          if (rebuild != null) rebuild();
        },
        onFieldSubmitted: onFieldSubmitted,
        focusNode: focusNode,
      );

  static AmpFormField password({
    Function()? onChange,
    void Function(String)? onFieldSubmitted,
    FocusNode? focusNode,
  }) =>
      AmpFormField(
        initialValue: prefs.password,
        label: () => Language.current.password,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: [AutofillHints.password],
        onChanged: (field) {
          prefs.password = field.text.trim();
          if (onChange != null) onChange();
        },
        onFieldSubmitted: onFieldSubmitted,
        focusNode: focusNode,
      );
}

class AmpTabBar extends Container implements PreferredSizeWidget {
  AmpTabBar(List<Widget> tabs, TabController controller)
      : tabBar = TabBar(
          tabs: tabs,
          automaticIndicatorColorAdjustment: false,
          labelColor: _c,
          indicatorColor: _c,
          controller: controller,
        );

  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: prefs.accentColor,
        child: tabBar,
      );

  static Color get _c => brightAccentColor ? Colors.black : Colors.white;
}

//NOTE: This is a HORRIBLE hack. (but it works at least)
class EmptyAmpAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) => Container(color: prefs.accentColor);

  @override
  Size get preferredSize => Size(0, 0);
}

bool get brightAccentColor =>
    prefs.accentIndex == 11 || prefs.accentIndex == 12;

void adjustStatusBarForeground() =>
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness:
          brightAccentColor ? Brightness.dark : Brightness.light,
    ));

Future<void> hapticFeedback() async =>
    prefs.hapticFeedback ? await HapticFeedback.selectionClick() : null;
