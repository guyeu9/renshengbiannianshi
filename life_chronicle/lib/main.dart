import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const ProviderScope(child: LifeChronicleApp()));
  }, (error, stack) {
    debugPrint('Global error: $error');
    debugPrintStack(stackTrace: stack);
  });
}
