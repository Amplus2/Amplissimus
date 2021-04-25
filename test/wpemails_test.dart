import 'package:amplissimus/wpemails.dart';
import 'package:schttp/schttp.dart';

import 'testlib.dart';

void main() async {
  final gpf = wpemails('gympeg.de', ScHttpClient());
  final ampf = wpemails('amplus.chrissx.de', ScHttpClient());
  final amp = await ampf;
  final gp = await gpf;
  tests(
    [
      testAssert(amp.length >= 3),
      testAssert(gp.length >= 50),
      testExpect(amp['Häußler C.'], 'c.haeussler@amplus.chrissx.de'),
      testExpect(amp['Lehnert L.'], 'l.lehnert@amplus.chrissx.de'),
      testExpect(amp['Ganserer T.'], 't.ganserer@amplus.chrissx.de'),
      ...gp.values.map(
        (e) => testAssert(RegExp('.+?\\..+?@gympeg\\.de').hasMatch(e)),
      ),
    ],
    'wpemails',
  );
}
