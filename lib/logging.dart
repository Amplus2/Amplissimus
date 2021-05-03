import 'package:flutter/material.dart';
import 'uilib.dart';

bool _disabled = false;
String _log = '';

void disable() => _disabled = true;
void clear() => _log = '';

Widget get widget => ampText(_log,
    font: ['Ubuntu Mono', 'Menlo', 'SF Mono', 'monospace', 'Consolas']);

void log(String lvl, dynamic ctx, Object msg) {
  final now = DateTime.now();
  var s = now.second.toString(),
      m = now.minute.toString(),
      h = now.hour.toString(),
      ms = now.millisecond.toString();
  if (s.length == 1) s = '0$s';
  if (m.length == 1) m = '0$m';
  if (h.length == 1) h = '0$h';
  if (ms.length == 1) ms = '0$ms';
  if (ms.length == 2) ms = '0$ms';
  if (!(ctx is List)) ctx = [ctx];
  ctx.insert(0, lvl);
  final context = ctx.map((c) => '[$c]').reduce((v, e) => '$v$e');
  raw('$h:$m:$s.$ms $context $msg');
}

void raw(Object msg) {
  if (_disabled) return;
  _log += '$msg\n';
  print(msg);
}

String errorString(dynamic e) {
  if (e is Error) return '$e\n${e.stackTrace}';
  return e.toString();
}

void err(Object ctx, Object msg) => log('Error', ctx, errorString(msg));
void info(Object ctx, Object msg) => log('Info', ctx, msg);
