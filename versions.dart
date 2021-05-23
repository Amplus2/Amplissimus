import 'make.dart' as make;

Future<String> shortVersion() async => '5.0';
const int commitOffset = 1500;

Future<String> commit() => make.system('git rev-parse @',
    printInput: false, printOutput: false, throwOnFail: true);

Future<String> commitCount() => make.system('git rev-list @ --count',
    printInput: false, printOutput: false, throwOnFail: true);

Future<String> version() async =>
    '${await shortVersion()}.${int.parse(await commitCount()) - commitOffset}';

void main() async {
  print('::set-output name=commit::${await commit()}');
  print('::set-output name=short_version::${await shortVersion()}');
  print('::set-output name=commit_count::${await commitCount()}');
  print('::set-output name=version::${await version()}');
}
