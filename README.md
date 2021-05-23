# Amplissimus
Amplissimus is an app that tries to be what the DSBMobile app could
have been. It currently supports Android, iOS, Linux, macOS and
Windows and is a merge of
[Luddifee/Amplissimus](https://github.com/Luddifee/Amplissimus)
and [Ampless/Amplessimus](https://github.com/Ampless/Amplessimus).

## Why not the browser?
We could theoretically build a webapp version of this with
almost no effort, BUT it would require a proxy server of some kind as
all mainstream browsers try to block, what is called CSRF: You open up
evil.com and in JavaScript it makes a request to bank.com that tells
it to send me $1000. Of course we, as well as the browser vendors
should, know that making requests to DSBMobile probably cannot ever
be abused in a relevant way, but that doesn't fix the problem. Proxy
servers are a solution for this and, while we might one day make one,
that makes it quite a bit harder to run this as a web app.

## Installing
Just take the binary and install it in your OS's standard way.
### Android
Download the APK and click `Install`.
### Linux, Windows
Download and extract the ZIP and run the included binary.
(on Linux you have to `chmod +x` it)
### macOS
<!--TODO: make macOS also a ZIP, because the DMG is kinda unnecessary-->
Download and mount the DMG and drag-and-drop Amplissimus into the Applications.
### iOS
iOS installation is interesting, because, to run on iOS "officially",
we would have to pay Apple $99/year.
#### Filza (jailbroken)
The easiest way to install any IPA is to just open Filza, go to the
Downloads folder, click the file and then on `Install`.
#### Current AltStore Beta
In Beta 5 of AltStore 1.4 a new feature was added: You can add the Amplissimus
source by going to
altstore://source?url=https://amplus.chrissx.de/altstore/stable.json
#### AltStore 1.4 Beta 1-4
Some AltStore Betas allowed you to add custom software
repositories. Go to `Browse` → `Sources` → `+` and enter:
```
https://amplus.chrissx.de/altstore/stable.json
```
and you can install Amplissimus like you would install Riley's apps.
#### AltStore 1.3 and older
AltStore allows you to install IPAs. Download the IPA and install it,
either with the `+` button in AltStore or by using `open in` AltStore.

## <a name="build"></a> Building
Compiling for everything except Windows will assume you are running
macOS or Linux, but nowadays Windows should work, too. However, for all
build targets a recent version of
[Flutter](https://flutter.dev/docs/get-started/install) is required.
In the Output sections `$aid{plat,arch}` means "amplissimus-version-plat-arch".
(e.g. "amplissimus-4.1.42-ios-arm64") All of the outputs are placed in the
`bin/` folder, which is created automatically.

### Android
#### Dependencies
* [Android SDK](https://developer.android.com/studio)
* A development certificate (`keytool -genkey -v -keystore /tmp/amp.jks -keyalg RSA -keysize 2048 -validity 10000 -alias amp -storetype JKS`)
* [A bit of configuration](https://flutter.dev/docs/deployment/android#reference-the-keystore-from-the-app)
#### Compile
```
./make android
```
#### Output
* `$aid{android,universal}.aab` an application bundle
* `$aid{android,universal}.apk` an application package

### Linux
#### Dependencies
* Linux (maybe some other Unixes work, too)
* Clang
* CMake
* GTK3 headers
* Ninja
* pkg-config

(pre-installed if you installed Flutter through snap)
(if you use Debian\*, you can apt install:
`clang cmake libgtk-3-dev ninja-build pkg-config`)
#### Compile
```
./make linux
```
#### Output
* `$aid{linux,x86_64}.zip` an archive containing Amplissimus and all deps for x86
* `$aid{linux,arm64}.zip` an archive containing Amplissimus and all deps for ARM
#### Notes
You can also run `./make linux-x86_64` or `./make linux-arm64` to build just a
specific architecture.

### iOS
#### Dependencies
* macOS
* Xcode
#### Compile
```
./make ios
```
#### Output
* `$aid{ios,arm64}.ipa` an unsigned iOS 12.2+ app

### macOS
#### Dependencies
* macOS
* Xcode
#### Compile
```
./make mac
```
#### Output
* `$aid{macos,x86_64}.dmg` an installer image for macOS 10.15+
#### Notes
Unfortunately the Flutter team is slow, so you have to use Rosetta 2 on ARM64.

### Windows
#### Dependencies
* Windows
* Visual Studio
#### Compile
```
flutter upgrade
flutter config --no-analytics
flutter clean
flutter pub get
dart run make.dart win
```
#### Output
* `$aid{windows,x86_64}.zip`
#### Notes
Flutter might get Windows ARM support at some point, in a few decades.
