import 'package:dsbuntis/dsbuntis.dart';
import 'package:amplissimus/langs/language.dart';

import 'testlib.dart';

TestCase languageTestCase(Function(Language) func) => () async {
      Language.all.map((e) => func(e));
    };

List<TestCase> languageTestCases = [
  languageTestCase((lang) => Day.values.map((e) => lang.dayToString(e))),
  languageTestCase((lang) => testAssert(Language.fromCode(lang.code) == lang)),
  languageTestCase((lang) =>
      lang.dsbSubToSubtitle(Substitution('lul', -1, 'kek', 'subJEeKE', false))),
  languageTestCase((lang) => lang.dsbSubToSubtitle(Substitution(
      'lul', 42, '---', 'sub', true,
      notes: 'zdenek je v prdeli'))),
];

void main() {
  tests(languageTestCases, 'lang');
}
