# Amplessimus
Amplessimus is an app that tries to be what the 'DSBMobile' app could
have been. It currently supports Android, iOS, Linux, macOS and
Windows. We could theoretically build a webapp version of this with
almost no effort, BUT it would require a proxy server of some kind as
all mainstream browsers try to block, what is called CSRF: You open up
evil.com and in JavaScript it makes a request to bank.com that tells
it to send me $1000. Of course we, as well as the browser vendors
should, know that making requests to DSBMobile probably cannot ever
be abused in a relevant way, but that doesn't fix the problem. Proxy
servers are a solution for this and there will probably be one, but
that makes it a bit harder to run this as a webapp.

## Installing
Just take the binary and install it in your OS's standard way.
### Android
Download the APK and click `Install`.
### Linux, Windows
Flutter doesn't cross-compile at the moment. Goto [`Building`](#build).
### macOS
We try to build for it, but there are weird problems. Goto [`Building`](#build).
### iOS
iOS installation is interesting, because, to run on iOS "officially",
we would have to pay Apple $99/year.
#### Filza
The easiest way to install any IPA is to just open Filza, go to the
Downloads folder, click the file and then on `Install`.
#### AltStore 1.3
AltStore allows you to install IPAs. Download the IPA and install it,
either with the `+` button in AltStore or by using `open in` AltStore.
#### AltStore 1.4 (beta < 5)
AltStore 1.4 (currently in beta) allows you to add custom software
repositories. Go to `Browse` → `Sources` → `+` and enter:
```
https://ampless.chrissx.de/altstore/stable.json
```
and you can install Amplessimus like you would install Riley's apps.
#### AltStore 1.4
In Beta 5 of AltStore 1.4 a new feature was added: You can add the Amplessimus
source by clicking
[this link](altstore://source?url=https://ampless.chrissx.de/altstore/stable.json).
#### Cydia (broken, help needed)
There is an apt repo at
```
https://apt.chrissx.de/cydia
```
containing a build that is broken and outdated. Making
Cydia-compatible builds is hard. Many older Cydia apps are broken in
similar ways and since there is not a lot of documentation it is
really hard to learn it.

## <a name="build"></a> Building
Building on Windows is a mess, because Windows is a mess. Luckily
Windows will long-term be replaced by the Unixes. So compiling for
everything except Windows will assume you are running macOS or Linux,
as the instructions for Windows are a lot more complicated. However,
for all build targets a recent version of
[Flutter](https://flutter.dev/docs/get-started/install) is required.
Additionally you currently need `make` for these build instructions
(except for Windows). In the Output sections `$VERSION` means
"the full name of the version you are building". All of the outputs
are placed in the `bin/` folder, which created automatically.

### Android
#### Prepare
* The [Android SDK](https://developer.android.com/studio)
#### Compile
```
make android
```
#### Output
* `$VERSION.aab` an application bundle
* `$VERSION.apk` an application bundle

### Linux
#### Prepare
* Linux (maybe some other Unixes, too)
* Clang
* CMake
* GTK3 headers
* Ninja
* pkg-config
(pre-installed if you installed Flutter through snap)
(if you use Debian/Ubuntu/PopOS/…, you can apt install:
`clang cmake libgtk-3-dev ninja-build pkg-config`)
#### Compile
```
make linux
```
#### Output
* `$VERSION.linux/` a folder containing the Amplessimus binary and all deps

### iOS
#### Prepare
* Recent macOS
* Recent Xcode
#### Compile
```
make ios
```
#### Output
* `$VERSION.deb` a cydia package (maybe broken)
* `$VERSION.ipa` an unsigned app (works)

### macOS
#### Prepare
* Recent macOS
* Recent Xcode
```
make mac
```
#### Output
* `$VERSION.dmg` an installer image for macOS 10.13+

### Web
#### Compile
```
make web
```
#### Output
* `$VERSION.web/` a folder containing your `/var/www/html/*` basically
#### Notes
It won't work, because browsers like "security". (CSRF is a serious security
problem, but it also makes web Amplessimus impossible)

### Windows
#### Prepare
* Recent Windows
* Recent Visual Studio (2019 as of writing this)
#### Compile if make would work
```
make.exe win
```
#### Compile without make (buggy)
```
make_win.bat
```
#### Output (make)
* `$VERSION.win/`
#### Output (without make)
* `amplessimus.win/`
