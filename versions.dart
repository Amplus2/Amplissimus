import 'make.dart' as make;

const shortVersion = '4.2';

Future<String> get commit => make.system('git rev-parse @',
    printInput: false, printOutput: false, throwOnFail: true);

Future<String> get commitCount => make.system('git rev-list @ --count',
    printInput: false, printOutput: false, throwOnFail: true);

Future<String> get version async =>
    '$shortVersion.${int.parse(await commitCount) - 1400}';

void main() async {
  print('::set-output name=commit::${await commit}');
  print('::set-output name=short_version::$shortVersion');
  print('::set-output name=commit_count::${await commitCount}');
  print('::set-output name=version::${await version}');
}
