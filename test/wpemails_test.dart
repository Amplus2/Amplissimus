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
      testExpect(amp[0].key, 'Ganserer T.'),
      testExpect(amp[0].value, 't.ganserer@amplus.chrissx.de'),
      testExpect(amp[1].key, 'Häußler C.'),
      testExpect(amp[1].value, 'c.haeussler@amplus.chrissx.de'),
      testExpect(amp[2].key, 'Lehnert L.'),
      testExpect(amp[2].value, 'l.lehnert@amplus.chrissx.de'),
      ...gp.map(
        (e) => testAssert(RegExp('.+?\\..+?@gympeg\\.de').hasMatch(e.value)),
      ),
    ],
    'wpemails',
  );
}
