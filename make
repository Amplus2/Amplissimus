#!/bin/sh
flutter config --no-analytics
flutter pub get || { flutter clean && flutter pub get ; } && \
dart run make.dart $@
