import 'package:schttp/schttp.dart';
import 'package:flutter/material.dart';
import 'package:html_search/html_search.dart';

import 'langs/language.dart';
import 'logging.dart' as log;
import 'main.dart';
import 'uilib.dart';

List<MapEntry<String, String>> wpemailsave = [];

Future<void> wpemailUpdate() async => wpemailsave =
    prefs.wpeDomain.isNotEmpty ? await wpemails(prefs.wpeDomain, http) : [];

Future<List<MapEntry<String, String>>> wpemails(
    String domain, ScHttpClient http) async {
  try {
    final u = 'https://$domain/schulfamilie/lehrkraefte/';
    final h = search(
        searchFirst(parse(await http.get(u)),
                (e) => e.className.toLowerCase().contains('entry-content'))!
            .children,
        (e) =>
            e.innerHtml.contains(',') &&
            e.innerHtml.contains('(') &&
            e.innerHtml.contains('.') &&
            !e.innerHtml.contains('<'));

    return h.map((p) {
      final raw = p.innerHtml
          .replaceAll(RegExp('[ ­\r\n]'), '')
          .replaceAll(RegExp('&.+?;'), '')
          .split(',');
      final f = raw[1].split('.').first, l = raw[0].split('.').last;
      return MapEntry('$l $f.', _replaceUmlaut('$f.$l@$domain'.toLowerCase()));
    }).toList()
      ..sort((t1, t2) => t1.key.toLowerCase().compareTo(t2.key.toLowerCase()));
  } catch (e) {
    log.err('WPEmails', e);
    return [];
  }
}

String _replaceUmlaut(String s) => s
    .replaceAll('ö', 'oe')
    .replaceAll('ä', 'ae')
    .replaceAll('ü', 'ue')
    .replaceAll('ß', 'ss');

class WPEmails extends StatefulWidget {
  @override
  WPEmailsState createState() => WPEmailsState();
}

class WPEmailsState extends State<WPEmails> {
  Iterable<MapEntry<String, String>> wpemails = wpemailsave;
  late AmpFormField searchBox;
  WPEmailsState() {
    wpemails = wpemailsave;
    searchBox = AmpFormField(
      label: () => Language.current.search,
      onChanged: (ff) => setState(() {
        wpemails = wpemailsave
            .where((e) => e.key.toLowerCase().contains(ff.text.toLowerCase()));
      }),
    );
  }
  @override
  Widget build(BuildContext ctx) => Column(
        children: [
          ListTile(title: AmpText(Language.current.teachers, size: 24)),
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: ampList([
              ampPadding(10, searchBox.flutter()),
              ...wpemails.map(
                (e) => ListTile(
                  title: AmpText(e.key),
                  subtitle: AmpText(e.value),
                  onTap: () =>
                      {hapticFeedback(), ampOpenUrl('mailto:${e.value}')},
                ),
              )
            ]),
          ),
        ],
      );
}
