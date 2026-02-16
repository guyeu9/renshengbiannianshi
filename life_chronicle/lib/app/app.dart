import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'app_theme.dart';

class LifeChronicleApp extends StatelessWidget {
  const LifeChronicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '人生编年史',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
