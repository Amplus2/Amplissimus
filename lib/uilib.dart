import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'langs/language.dart';
import 'logging.dart';
import 'main.dart';

final Widget emptyWidget = Container(width: 0, height: 0);

DialogButton okDialogButton(BuildContext context,
        {void Function()? onPressed}) =>
    DialogButton(context, 'OK', onPressed: onPressed);

DialogButton cancelDialogButton(BuildContext context,
        {void Function()? onPressed}) =>
    DialogButton(context, Language.current.cancel, onPressed: onPressed);

Future<void> showSimpleDialog(
  BuildContext context, {
  Widget? title,
  Widget Function(BuildContext context)? content,
  List<Widget> Function(BuildContext context)? actions,
  bool barrierDismissible = true,
}) async {
  actions ??= (context) => [];
  return await showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      title: title,
      content: content == null ? null : content(context),
      actions: actions!(context),
    ),
  );
}

Future<void> showInfoDialog(
  BuildContext context, {
  Widget? title,
  Widget Function(BuildContext context)? content,
  void Function()? onConfirm,
}) async {
  return await showSimpleDialog(
    context,
    title: title,
    content: content,
    actions: (context) => [okDialogButton(context, onPressed: onConfirm)],
  );
}

Future<void> showConfirmDialog(
  BuildContext context, {
  Widget? title,
  Widget Function(BuildContext context)? content,
  List<Widget> Function(BuildContext context)? actions,
  void Function()? onConfirm,
  void Function()? onCancel,
}) async {
  return await showSimpleDialog(
    context,
    title: title,
    content: content,
    actions: actions ??
        (context) => [
              cancelDialogButton(context, onPressed: onCancel),
              okDialogButton(context, onPressed: onConfirm),
            ],
  );
}

class DropdownMenu<T> extends DropdownButton<T> {
  DropdownMenu({
    required T value,
    required List<T> items,
    void Function(T? value)? onChanged,
    bool enabled = true,
  }) : super(
          value: value,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ))
              .toList(),
          onTap: hapticFeedback,
          onChanged: enabled ? onChanged : null,
        );
}

class TextSwitch extends TextWidget {
  TextSwitch({
    required String text,
    required bool value,
    void Function(bool)? onChanged,
    bool enabled = true,
  }) : super(
          text: text,
          widget: Switch(value: value, onChanged: onChanged),
          onTap: onChanged == null ? null : () => onChanged(!value),
        );
}

class TextWidget extends ListTile {
  TextWidget({
    required String text,
    required Widget widget,
    void Function()? onTap,
  }) : super(
          title: Text(text),
          trailing: widget,
          onTap: onTap == null ? null : () => {hapticFeedback(), onTap()},
        );
}

ElevatedButton ampRaisedButton(String text, void Function()? onPressed) =>
    ElevatedButton(
        onPressed:
            onPressed != null ? () => {hapticFeedback(), onPressed()} : null,
        child: Text(text));

Padding ampPadding(double value, [Widget? child]) =>
    Padding(padding: EdgeInsets.all(value), child: child);

class AmpText extends Text {
  AmpText(
    dynamic text, {
    double? size,
    TextAlign? align,
    FontWeight? weight,
    Color? color,
    String? fontFamily,
  }) : super(
          text.toString(),
          textAlign: align,
          style: TextStyle(
            fontSize: size,
            fontWeight: weight,
            color: color,
            fontFamily: fontFamily,
          ),
        );
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
      child: Column(children: children),
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
      child: Column(children: children),
    );
  }
}

Future<Null> ampOpenUrl(String url) => url_launcher.canLaunch(url).then((b) {
      if (b) url_launcher.launch(url);
    });

Widget ampErrorText(dynamic e) => ampPadding(
    8,
    AmpText(
      errorString(e),
      color: Colors.red,
      weight: FontWeight.bold,
      size: 16,
    ));

Icon ampColorCircle(Color c) => Icon(Icons.circle, color: c, size: 36);

class DialogButton extends TextButton {
  DialogButton(BuildContext context, String text, {void Function()? onPressed})
      : super(
          onPressed: () async {
            if (onPressed != null) onPressed();
            await hapticFeedback();
            Navigator.pop(context);
          },
          child: Text(text),
        );
}

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
    return Column(
      children: [
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
    Function()? onChange,
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
          if (onChange != null) onChange();
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

void showSnackBar(
  BuildContext context,
  Widget content, {
  SnackBarAction? action,
  SnackBarBehavior? behavior = SnackBarBehavior.floating,
}) {
  action ??= SnackBarAction(
    label: 'OK',
    onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      action: action,
      content: content,
      behavior: behavior,
    ),
  );
}
