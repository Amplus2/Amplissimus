import 'dart:convert';
import 'dart:io';

import 'lib/constants.dart';
import 'make.dart' as make;

//TODO: use a webhook to get rid of this
Future updateAltstore() async {
  if (!(await Directory('../$AMP_DOMAIN').exists())) {
    await make.system(
      'git clone https://github.com/$AMP_GH_ORG/$AMP_DOMAIN ../$AMP_DOMAIN',
      throwOnFail: true,
    );
  }
  Directory.current = '../$AMP_DOMAIN/altstore';
  await make.system('git pull');
  var versionDate = await make.system('date -u +%FT%T', printOutput: false);
  versionDate += '+00:00';
  final desc = await make.system("date '+%d.%m.%y %H:%M'", printOutput: false);
  final json = jsonDecode(await make.readfile('alpha.json'));
  final app = json['apps'].first;
  app['version'] = make.version;
  app['versionDate'] = versionDate;
  app['versionDescription'] = desc;
  app['downloadURL'] =
      '$AMP_GH_URL/releases/download/${make.version}/${make.version}.ipa';
  await make.writefile('alpha.json', jsonEncode(json));
  await make.system('git add alpha.json', throwOnFail: true);
  await make.system(
    'git commit -m \'[CI] Automatic update to $AMP_APP iOS Alpha ${make.version}\'',
    throwOnFail: true,
  );
  await make.system('git push', throwOnFail: true);
}

Future<void> main(List<String> args) async {
  print('The CI is currently being replaced by GitHub Actions.');
  exit(1);
}
