import 'dart:io';

import 'lib/constants.dart';
import 'versions.dart' as vers;

//import 'package:flutter_tools/src/build_system/build_system.dart';

late String shortVersion;
late String version;
late String buildNumber;

String appinfo(version, buildnum) => """const String appVersion = '$version';
const String buildNumber = '$buildnum';
""";

final flags = '--release --suppress-analytics --split-debug-info=bin';
final winFlags = flags;
final linuxX86Flags = '$flags --target-platform linux-x64';
final linuxARMFlags = '$flags --target-platform linux-arm64';
String get pkgFlags =>
    '$flags --build-name=$version --build-number $buildNumber';
String get iosFlags => '$pkgFlags --no-codesign';
//--target-platform android-arm,android-arm64,android-x64
String get apkFlags => '$pkgFlags --shrink';
String get aabFlags => apkFlags;
String get macFlags => pkgFlags;

final testFlags =
    '--coverage -j 100 --test-randomize-ordering-seed random -r expanded';

Future<String> system(
  String cmd, {
  bool throwOnFail = false,
  bool printInput = true,
  bool printOutput = true,
  bool powershell = false,
}) async {
  if (printInput) stderr.writeln(cmd);
  final p = await (Platform.isWindows
      ? (powershell
          ? Process.run('powershell', ['-command', cmd])
          : Process.run('cmd', ['/c', cmd]))
      : Process.run('sh', ['-c', cmd]));
  if (printOutput) {
    stderr.write(p.stderr);
    stderr.write(p.stdout);
  }
  if (p.exitCode != 0 && throwOnFail) throw p.exitCode;
  return p.stdout.trimRight();
}

Future<String> readfile(path) async => File(path).readAsString();
Future writefile(path, content) async => File(path).writeAsString(content);

Future<void> rm(f) async {
  if (await File(f).exists()) {
    await File(f).delete();
  }
}

Future<void> rmd(d) async {
  if (await Directory(d).exists()) {
    await Directory(d).delete(recursive: true);
  }
}

Future<String> mv(from, to) =>
    File(from).rename(to).then((value) => value.path);
Future mvd(from, to) => Directory(from).rename(to);

Future zip(from, to, [rootDir = '.']) => system(
    Platform.isWindows
        ? 'Compress-Archive -LiteralPath $from -DestinationPath $to'
        : 'cd $rootDir && zip -r -9 $to $from',
    throwOnFail: true,
    powershell: true);

Future mkdirs(d) => Directory(d).create(recursive: true);

Future<String> md5(String path) =>
    system("md5sum '$path' | cut -d' ' -f1", printOutput: false);

Future<void> flutter(String cmd, {bool throwOnFail = true}) =>
    system('flutter $cmd', throwOnFail: throwOnFail);
Future build(String cmd, String flags) => flutter('build $cmd $flags');

Future<void> strip(String files) =>
    system('strip -u -r $files', printOutput: false);

String aid(plat, arch) => '${AMP_APP.toLowerCase()}-$version-$plat-$arch';
String filename(o, plat, arch, ext) => '$o/${aid(plat, arch)}.$ext';

Future<void> iosapp([String o = 'bin']) async {
  const buildDir = 'build/ios/Release-iphoneos/Runner.app';
  await build('ios', iosFlags);
  await system(
      'xcrun bitcode_strip $buildDir/Frameworks/Flutter.framework/Flutter -r -o tmpfltr');
  await mv('tmpfltr', '$buildDir/Frameworks/Flutter.framework/Flutter');
  await system('rm -f $buildDir/Frameworks/libswift*');
  await strip('$buildDir/Runner $buildDir/Frameworks/*.framework/*');
}

Future<String> ipa([String o = 'bin']) async {
  //await flutter('build ipa $iosFlags');
  await system('cp -rp build/ios/Release-iphoneos/Runner.app tmp/Payload');
  await zip('Payload', 'tmp.ipa', 'tmp');
  return await mv('tmp/tmp.ipa', filename(o, 'ios', 'arm64', 'ipa'));
}

Future<String> apk([String o = 'bin']) async {
  await build('apk', apkFlags);
  return await mv('build/app/outputs/flutter-apk/app-release.apk',
      filename(o, 'android', 'universal', 'apk'));
}

Future<String> aab([String o = 'bin']) async {
  await build('appbundle', aabFlags);
  return await mv('build/app/outputs/bundle/release/app-release.aab',
      filename(o, 'android', 'universal', 'aab'));
}

Future<void> test() async {
  await flutter('test $testFlags');
  await system('genhtml -o coverage/html coverage/lcov.info');
  await system('lcov -l coverage/lcov.info');
}

Future<void> ios() async {
  await iosapp();
  await ipa();
}

Future<void> android() async {
  await apk();
  await aab();
}

Future win([String o = 'bin']) async {
  await flutter('config --enable-windows-desktop');
  await build('windows', winFlags);
  final id = aid('windows', 'x86_64');
  await mvd('build/windows/runner/Release', 'tmp/$id');
  await zip('tmp/$id', '$o/$id.zip');
}

Future<String> mac([String o = 'bin']) async {
  await flutter('config --enable-macos-desktop');
  await build('macos', macFlags);

  final file = filename(o, 'macos', 'x86_64', 'dmg');

  await system('cp -r build/macos/Build/Products/Release/$AMP_APP.app tmp/dmg');
  await system('rm -f tmp/dmg/Contents/Frameworks/libswift*');
  await system('ln -s /Applications "tmp/dmg/drop here"');
  await system('hdiutil create \'$file\' -ov '
      '-srcfolder tmp/dmg -volname \'$AMP_APP $shortVersion\' '
      // 106M RW
      //  86M RO
      //  39M UDCO (adc)
      //  34M UDZO (zlib)
      //  31M ULFO (lzfse)
      //  29M UDBZ (bzip2)
      //  25M ULMO (lzma)
      '-fs APFS -format ULMO');
  return file;
}

Future<void> linuxX86([String o = 'bin']) async {
  await flutter('config --enable-linux-desktop');
  await build('linux', linuxX86Flags);
  final id = aid('linux', 'x86_64');
  await mvd('build/linux/x64/release/bundle', 'tmp/$id');
  await zip(id, '../$o/$id.zip', 'tmp');
}

Future<void> linuxArm([String o = 'bin']) async {
  await flutter('config --enable-linux-desktop');
  await build('linux', linuxARMFlags);
  final id = aid('linux', 'arm64');
  await mvd('build/linux/arm64/release/bundle', 'tmp/$id');
  await zip(id, '../$o/$id.zip', 'tmp');
}

Future<void> linux([o = 'bin']) => linuxX86(o).then((_) => linuxArm(o));

Future<void> ver() async {
  print(version);
}

Future<void> clean() async {
  await rmd('tmp');
  await rmd('build');
  await rmd('bin');
}

Future env(s, d) async {
  if (Platform.environment.containsKey(s)) {
    print('Found $s in environment.');
    return Platform.environment[s];
  } else {
    final def = await d();
    print('Using default value $def for $s.');
    return def;
  }
}

Future<void> init() async {
  shortVersion = await env('short_version', vers.shortVersion);
  buildNumber = await env('commit_count', vers.commitCount);
  version = await env('version', vers.version);
  await rmd('tmp');
  await mkdirs('bin');
  await mkdirs('tmp/Payload');
  await mkdirs('tmp/dmg');
  await File('lib/appinfo.dart').writeAsString(appinfo(version, buildNumber));
}

Future<void> cleanup() async {
  await rmd('tmp');
  await rmd('build');
  await File('lib/appinfo.dart').writeAsString(appinfo('0.0.0-1', '0'));
}

const targets = {
  'ios': ios,
  'android': android,
  'test': test,
  'win': win,
  'mac': mac,
  'linux': linux,
  'linux-x86_64': linuxX86,
  'linux-arm64': linuxArm,
  'ver': ver,
  'clean': clean,
};

Future<void> main(List<String> argv) async {
  try {
    await init();
    for (final target in argv) {
      if (!targets.containsKey(target)) throw 'Target $target doesn\'t exist.';
      await targets[target]!();
    }
  } catch (e) {
    stderr.writeln(e);
    if (e is Error) stderr.writeln(e.stackTrace);
    exitCode = e is int ? e : -1;
  }
  await cleanup();
}
