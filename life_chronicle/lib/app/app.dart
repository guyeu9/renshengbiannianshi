import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_shell.dart';
import 'app_theme.dart';

class LifeChronicleApp extends StatelessWidget {
  const LifeChronicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '人生编年史',
      theme: AppTheme.light(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      home: const AppShell(),
    );
  }
}
