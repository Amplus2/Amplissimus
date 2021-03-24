import 'package:package_info/package_info.dart';

import 'logging.dart';

Future<String> get appVersion async {
  try {
    return (await PackageInfo.fromPlatform()).version;
  } catch (e) {
    ampErr('AppVersion', e);
    return '0.0.0-1';
  }
}

Future<String> get buildNumber async {
  try {
    return (await PackageInfo.fromPlatform()).buildNumber;
  } catch (e) {
    ampErr('BuildNumber', e);
    return '0';
  }
}
