#!/bin/sh
flutter upgrade
flutter config --no-analytics
flutter pub get || { flutter clean && flutter pub get ; } && \
dart run ci.dart
