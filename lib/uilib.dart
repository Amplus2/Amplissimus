import 'package:flutter/services.dart';

import 'langs/language.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'main.dart';
import 'logging.dart';

List<Widget> _noActions(BuildContext ctx) => [];

Future<Null> ampDialog(
  BuildContext context, {
  String? title,
  required List<Widget> Function(BuildContext, StateSetter) children,
  required Widget Function(List<Widget>) widgetBuilder,
  List<Widget> Function(BuildContext) actions = _noActions,
  bool barrierDismissible = true,
}) =>
    ampSimpleDialog(
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

Future<Null> ampSimpleDialog(
  BuildContext context,
  Widget child, {
  List<Widget> Function(BuildContext) actions = _noActions,
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

Tab ampTab(IconData iconDefault, IconData iconOutlined, String text) =>
    Tab(icon: ampIcon(iconDefault, iconOutlined), text: text);

TextButton ampDialogButton(String text, Function() onPressed) =>
    TextButton(onPressed: onPressed, child: Text(text));

DropdownButton<T> ampDropdownButton<T>({
  required T value,
  required List<T> items,
  required void Function(T?) onChanged,
  Widget Function(T)? itemToDropdownChild,
}) =>
    DropdownButton<T>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(
              value: e, child: (itemToDropdownChild ?? ampText)(e)))
          .toList(),
      onChanged: onChanged,
    );

Switch ampSwitch(bool value, Function(bool) onChanged) => Switch(
      value: value,
      onChanged: onChanged,
      activeColor: prefs.themeData.accentColor,
    );

ListTile ampSwitchWithText(String text, bool value, Function(bool) onChanged) =>
    ampWidgetWithText(text, ampSwitch(value, onChanged));

ListTile ampWidgetWithText(String text, Widget w, [Function()? onTap]) =>
    ListTile(title: Text(text), trailing: w, onTap: onTap);

List<Widget> ampDialogButtonsSaveAndCancel(BuildContext context,
    {required Function() save}) {
  return [
    ampDialogButton(Language.current.cancel, Navigator.of(context).pop),
    ampDialogButton(Language.current.save, save),
  ];
}

ElevatedButton ampRaisedButton(String text, void Function() onPressed) =>
    ElevatedButton(onPressed: onPressed, child: Text(text));

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
      onPressed: setHidden,
      icon: hidden
          ? ampIcon(Icons.visibility_off, Icons.visibility_off_outlined)
          : ampIcon(Icons.visibility, Icons.visibility_outlined),
    );

SnackBar ampSnackBar(
  String content, [
  String? label,
  Function()? f,
]) =>
    SnackBar(
      content: Text(content),
      action: label != null && f != null
          ? SnackBarAction(label: label, onPressed: f)
          : null,
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
  final void Function(AmpFormField)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  static String _noLabel() => '';

  AmpFormField({
    Object initialValue = '',
    this.autofillHints = const [],
    this.keyboardType = TextInputType.text,
    this.label = _noLabel,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
  }) : controller = TextEditingController(text: initialValue.toString());

  Widget flutter({Widget? suffixIcon, bool obscureText = false}) {
    return ampColumn(
      [
        ampPadding(
          2,
          TextFormField(
            onChanged: (_) {
              (onChanged ?? (_) {})(this);
            },
            obscureText: obscureText,
            controller: controller,
            key: key,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            decoration: InputDecoration(
              labelText: label(),
              suffixIcon: suffixIcon,
            ),
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
          indicatorColor: Colors.white,
          controller: controller,
        );

  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: prefs.themeData.accentColor,
        child: tabBar,
      );
}

class EmptyAmpAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) => Container(color: prefs.accentColor);

  @override
  Size get preferredSize => Size(0, 0);
}
