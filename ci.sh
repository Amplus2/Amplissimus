#!/bin/sh
flutter channel master
flutter upgrade
flutter config --enable-web
mkdir -p /usr/local/var/www/amplissimus
cd amplissimus
make || exit 1
cp -rf bin "/usr/local/var/www/amplissimus/$1"
cd bin
tar cJf "/usr/local/var/www/amplissimus/$1/$1.tar.xz" *
rm -rf *
cd ../..
