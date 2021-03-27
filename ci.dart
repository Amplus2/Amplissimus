import 'dart:convert';
import 'dart:io';

import 'package:github/github.dart';
import 'package:path/path.dart';

import 'lib/constants.dart';
import 'make.dart' as make;

const releaseInfo = 'This is an automatic pre-release by the CI.\n\n'
    '###### Changelog\n\n\n'
    '###### Stores\n'
    '| Store             | Published |\n'
    '|-------------------|-----------|\n'
    '| Google Play Store | :x:       |\n'
    '| Apple App Store   | :x:       |\n';

Future<void> githubRelease(String commit, String dir) async {
  print('Creating release...');
  final github = GitHub(
    auth: Authentication.withToken(
      (await File('/etc/ampci.token').readAsLines()).first,
    ),
  );
  final release = await github.repositories.createRelease(
    RepositorySlug(AMP_GH_ORG, AMP_APP),
    CreateRelease.from(
      tagName: make.version,
      name: make.version,
      targetCommitish: commit,
      isDraft: false,
      isPrerelease: true,
      body: releaseInfo,
    ),
  );
  print('Uploading assets...');
  await github.repositories.uploadReleaseAssets(
    release,
    await Directory(dir)
        .list()
        .where((event) => event is File)
        .asyncMap((event) async => CreateReleaseAsset(
            name: basename(event.path),
            contentType: 'application/octet-stream',
            assetData: await (event as File).readAsBytes()))
        .toList(),
  );
  print('Done uploading.');
}

String sed(String input, String regex, String replace) =>
    input.replaceAll(RegExp(regex), replace);

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
      'https://github.com/$AMP_GH_ORG/$AMP_APP/releases/download/${make.version}/${make.version}.ipa';
  await make.writefile('alpha.json', jsonEncode(json));
  await make.system('git add alpha.json;', throwOnFail: true);
  await make.system(
    'git commit -m \'[CI] Automatic update to $AMP_APP ios alpha ${make.version}\';',
    throwOnFail: true,
  );
  await make.system('git push', throwOnFail: true);
}

Future<void> main() async {
  await make.system('git pull');

  final commit = await make.system('git rev-parse @', printOutput: false);

  await make.clean();
  await make.init();

  await Directory('/usr/local/var/www/$AMP_APP').create(recursive: true);
  final outputDir = '/usr/local/var/www/$AMP_APP/${make.version}';

  final date = await make.system('date', printInput: false, printOutput: false);
  print('[AmpCI][$date] Running the Dart build system for ${make.version}.');

  await make.android();
  await make.iosapp();
  await make.ipa();
  await make.mac();

  await Directory('bin').rename(outputDir);

  final altstore = updateAltstore();
  await githubRelease(commit, outputDir);
  await altstore;

  await make.cleanup();
}
