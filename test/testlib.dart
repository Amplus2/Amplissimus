import 'package:amplissimus/logging.dart' as log;
import 'package:amplissimus/main.dart';
import 'package:flutter_test/flutter_test.dart';

typedef TestCase = Future<Null> Function();

TestCase expectTestCase<T>(
  Future<T> Function() tfunc,
  T expct,
  bool error,
) =>
    () async {
      T res;
      try {
        res = await tfunc();
      } catch (e) {
        if (!error) {
          rethrow;
        } else {
          return;
        }
      }
      if (error) throw '[expectTestCase($tfunc, $expct)] No error.';
      expect(res, expct);
    };

TestCase testAssert(bool b) => () async {
      assert(b);
    };

TestCase testExpect<T>(T actual, T matcher) => () async {
      expect(actual, matcher);
    };

void tests(Iterable<TestCase> testCases, String groupName) =>
    group(groupName, () {
      var i = 1;
      for (final testCase in testCases) {
        test('case ${i++}', () async {
          log.disable();
          await mockPrefs();
          await testCase();
        });
      }
    });
