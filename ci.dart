import 'dart:convert';
import 'dart:io';

import 'package:github/github.dart';
import 'package:path/path.dart';

import 'lib/constants.dart';
import 'make.dart' as make;

const releaseInfo = 'This is an automatic pre-release by the CI.\n\n'
    '#### Changelog\n\n\n'
    '#### Stores\n'
    '| Store             | Published |\n'
    '|-------------------|-----------|\n'
    '| Google Play Store | :x:       |\n'
    '| Apple App Store   | :x:       |\n';

Future<Future Function(String)> githubCreateRelease(
    String commit, String token) async {
  final gh = GitHub(
    auth: Authentication.withToken(token),
  );
  final rel = await gh.repositories.createRelease(
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
  return (file) async => gh.repositories.uploadReleaseAssets(rel, [
        CreateReleaseAsset(
            name: basename(file),
            contentType: 'application/octet-stream',
            assetData: await File(file).readAsBytes())
      ]);
}

Future updateAltstore() async {
  if (!(await Directory('../$AMP_DOMAIN').exists())) {
    await make.system(
      'git clone https://github.com/$AMP_GH_ORG/$AMP_DOMAIN ../$AMP_DOMAIN',
      throwOnFail: true,
    );
  }
  //TODO: DONT set this, so we can run this much earlier
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
  final token = args.isNotEmpty
      ? args.removeAt(0)
      : (await File('/etc/ampci.token').readAsLines()).first;
  final output = args.isNotEmpty
      ? args.removeAt(0)
      : '/usr/local/var/www/$AMP_APP/${make.version}';

  await make.system('git pull');

  final commit = await make.system('git rev-parse @', printOutput: false);

  await make.clean();
  await make.init();

  await Directory(output).create(recursive: true);

  final date = await make.system('date', printInput: false, printOutput: false);
  print('[AmpCI][$date] Running the Dart build system for ${make.version}.');

  await make.iosapp(output);
  final apk = make.apk(output);
  await apk;
  // if these 2 work, we can assume, everything works

  print('Creating release...');
  final upload = await githubCreateRelease(commit, token);

  for (final f in [apk, make.aab(output), make.ipa(output), make.mac(output)]
      .map((e) => e.then(upload))) {
    await f;
  }

  await make.cleanup();
  await updateAltstore();
}
