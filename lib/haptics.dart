// This file could be considered as useless but it exists anyways
import 'package:flutter/services.dart';

import 'main.dart';

void hapticFeedback() {
  if (prefs.hapticFeedback) HapticFeedback.selectionClick();
}
