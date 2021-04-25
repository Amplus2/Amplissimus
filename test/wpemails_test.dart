import 'package:amplissimus/wpemails.dart';
import 'package:schttp/schttp.dart';

import 'testlib.dart';

void main() async {
  final wpe = await wpemails('amplus.chrissx.de', ScHttpClient());
  tests(
    [
      testAssert(wpe.length >= 3),
      testExpect(wpe['Häußler C.'], 'c.haeussler@amplus.chrissx.de'),
      testExpect(wpe['Lehnert L.'], 'l.lehnert@amplus.chrissx.de'),
      testExpect(wpe['Ganserer T.'], 't.ganserer@amplus.chrissx.de'),
    ],
    'wpemails',
  );
}
