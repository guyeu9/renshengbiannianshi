import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_shell.dart';
import 'app_theme.dart';
import '../core/widgets/unfocus_on_tap.dart';
import '../core/errors/error_boundary.dart';

class BottomSheetFocusObserver extends RouteObserver<ModalRoute<void>> {
  @override
  void didPop(Route<void> route, Route<void>? previousRoute) {
    super.didPop(route, previousRoute);
    
    if (previousRoute != null) {
      final context = previousRoute.navigator?.context;
      if (context != null && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            FocusScope.of(context).unfocus();
          }
        });
      }
    }
  }
}

final bottomSheetFocusObserver = BottomSheetFocusObserver();

class LifeChronicleApp extends StatelessWidget {
  const LifeChronicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: UnfocusOnTap(
        child: MaterialApp(
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
          navigatorObservers: [bottomSheetFocusObserver],
          home: const AppShell(),
        ),
      ),
    );
  }
}
