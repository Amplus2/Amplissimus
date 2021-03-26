import 'dart:async';

import 'package:url_launcher/link.dart';

import 'main.dart';
import 'langs/language.dart';
import 'logging.dart';
import 'subject.dart';
import 'ui/home_page.dart';
import 'uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

Widget _classWidget(List<Substitution> subs) {
  var mappedSubs = <String, List<Substitution>>{};
  for (var s in subs) {
    if (mappedSubs[s.affectedClass] == null) {
      mappedSubs[s.affectedClass] = [s];
    } else {
      mappedSubs[s.affectedClass]?.add(s);
    }
  }
  var firstEntry = true;
  var result = <Widget>[];
  for (var entry in mappedSubs.entries) {
    result.add(
      Container(
        padding: EdgeInsets.only(
          left: 20,
          bottom: 4,
          top: firstEntry ? 0 : 12,
        ),
        width: double.infinity,
        child: ampText('${entry.key}', size: 21),
      ),
    );
    result.add(ampList(
        entry.value.map((s) => _renderSub(s, displayClass: false)).toList()));
    firstEntry = false;
  }
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: result,
  );
}

Widget _renderPlans(List<Plan> plans) {
  ampInfo('DSB', 'Rendering plans: $plans');
  final widgets = <Widget>[];
  for (final plan in plans) {
    final dayWidget = plan.subs.isEmpty
        ? ListTile(title: ampText(Language.current.noSubs))
        : prefs.groupByClass
            ? _classWidget(plan.subs)
            : ampList(plan.subs.map((s) => _renderSub(s)).toList());
    final warn = outdated(plan.date, DateTime.now());
    widgets.add(
      ListTile(
        title: ampRow([
          ampText(' ${Language.current.dayToString(plan.day)}', size: 24),
          IconButton(
            icon: warn
                ? ampIcon(Icons.warning, Icons.warning_amber_outlined)
                : ampIcon(Icons.info, Icons.info_outline),
            tooltip: warn
                ? Language.current.warnWrongDate(plan.date)
                : plan.date.split(' ').first,
            onPressed: () => scaffoldMessanger?.showSnackBar(ampSnackBar(
                warn ? Language.current.warnWrongDate(plan.date) : plan.date)),
            padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
          ),
          Link(
            uri: Uri.parse(plan.url),
            builder: (_, followLink) => IconButton(
              icon: ampIcon(Icons.open_in_new, Icons.open_in_new_outlined),
              tooltip: Language.current.openPlanInBrowser,
              onPressed: followLink,
              padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
            ),
          ),
        ]),
      ),
    );
    widgets.add(dayWidget);
  }
  ampInfo('DSB', 'Done rendering plans.');
  return ampColumn(widgets);
}

Widget widget = ampNull;

Future<Null> updateWidget([bool useJsonCache = false]) async {
  try {
    List<Plan> plans;
    if (prefs.forceJsonCache) {
      plans = Plan.plansFromJsonString(prefs.dsbJsonCache);
    } else if (useJsonCache && prefs.dsbJsonCache != '') {
      try {
        plans = Plan.plansFromJsonString(prefs.dsbJsonCache);
      } catch (e) {
        plans = (await getAllSubs(prefs.username, prefs.password, http: http))!;
      }
    } else {
      plans = (await getAllSubs(prefs.username, prefs.password, http: http))!;
    }

    prefs.dsbJsonCache = Plan.plansToJsonString(plans);
    if (prefs.oneClassOnly) {
      plans = Plan.searchInPlans(
          plans,
          (sub) =>
              sub.affectedClass.contains(prefs.classGrade) &&
              sub.affectedClass.contains(prefs.classLetter));
    }
    for (final plan in plans) {
      plan.subs.sort();
    }
    widget = _renderPlans(plans);
  } catch (e) {
    ampErr(['DSB', 'updateWidget'], e);
    widget = ampList([ampErrorText(e)]);
  }
}

bool outdated(String date, DateTime now) {
  try {
    final raw = date.split(' ').first.split('.');
    return now.isAfter(DateTime(
      int.parse(raw[2]),
      int.parse(raw[1]),
      int.parse(raw[0]),
    ).add(Duration(days: 3)));
  } catch (e) {
    return false;
  }
}

Widget _renderSub(Substitution sub, {bool displayClass = true}) {
  final subject = parseSubject(sub.subject);
  final title = sub.orgTeacher == null || sub.orgTeacher!.isEmpty
      ? subject
      : '$subject – ${sub.orgTeacher}';

  return ListTile(
    horizontalTitleGap: 4,
    title: ampText(title, size: 18),
    leading: Padding(
      padding: EdgeInsets.only(left: sub.lesson > 9 ? 1 : 6, top: 5),
      child: ampText(sub.lesson, size: 28, weight: FontWeight.bold),
    ),
    subtitle: ampText(Language.current.dsbSubtoSubtitle(sub), size: 16),
    trailing: displayClass
        ? ampText(sub.affectedClass, weight: FontWeight.bold, size: 20)
        : null,
  );
}

//this is a really bad place to put this, but we can fix that later
List<String> get grades => ['5', '6', '7', '8', '9', '10', '11', '12', '13'];
List<String> get letters => ['', 'a', 'b', 'c', 'd', 'e', 'f', 'g'];
