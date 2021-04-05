import 'package:schttp/schttp.dart';
import 'package:flutter/material.dart';
import 'package:html_search/html_search.dart';

import 'langs/language.dart';
import 'logging.dart';
import 'main.dart';
import 'uilib.dart';

Map<String, String> wpemailsave = {};

Future<void> wpemailUpdate() async => wpemailsave =
    prefs.wpeDomain.isNotEmpty ? await wpemails(prefs.wpeDomain, http) : {};

Future<Map<String, String>> wpemails(String domain, ScHttpClient http) async {
  try {
    var html = htmlParse(
      await http.get('https://$domain/schulfamilie/lehrkraefte/'),
    );
    html = htmlSearchByClass(html, 'entry-content')!.children;
    html = htmlSearchAllByPredicate(
        html,
        (e) =>
            e.innerHtml.contains(',') &&
            e.innerHtml.contains('(') &&
            e.innerHtml.contains('.') &&
            !e.innerHtml.contains('<'));

    return Map.fromEntries(html.map((p) {
      final raw = p.innerHtml
          .replaceAll(RegExp('[ ­]'), '')
          .replaceAll(RegExp('&.+?;'), '')
          .split(',');
      final f = raw[1].split('.').first, l = raw[0].split('.').last;
      return MapEntry('$l $f.', _replaceUmlaut('$f.$l@$domain'.toLowerCase()));
    }));
  } catch (e) {
    ampErr('WPEmails', e);
    return {};
  }
}

String _replaceUmlaut(String s) =>
    s.replaceAll('ö', 'oe').replaceAll('ä', 'ae').replaceAll('ü', 'ue');

class WPEmails extends StatefulWidget {
  @override
  WPEmailsState createState() => WPEmailsState();
}

class WPEmailsState extends State<WPEmails> {
  Iterable<MapEntry<String, String>> wpemails = wpemailsave.entries;
  late AmpFormField searchBox;
  WPEmailsState() {
    wpemails = wpemailsave.entries;
    searchBox = AmpFormField(
      label: () => Language.current.search,
      onChanged: (ff) => setState(() {
        wpemails = wpemailsave.entries
            .where((e) => e.key.toLowerCase().contains(ff.text.toLowerCase()));
      }),
    );
  }
  @override
  Widget build(BuildContext ctx) => ampColumn(
        [
          ListTile(title: ampText(Language.current.teachers, size: 24)),
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: ampList([
              ampPadding(10, searchBox.flutter()),
              ...wpemails.map(
                (e) => ListTile(
                  title: ampText(e.key),
                  subtitle: ampText(e.value),
                  onTap: () =>
                      {hapticFeedback(), ampOpenUrl('mailto:${e.value}')},
                ),
              )
            ]),
          ),
        ],
      );
}
