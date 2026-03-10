import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/log_util.dart';

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _logNavigation('push', route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _logNavigation('pop', route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final routeName = newRoute?.settings.name ?? newRoute?.runtimeType.toString() ?? 'unknown';
    final oldName = oldRoute?.settings.name ?? oldRoute?.runtimeType.toString() ?? 'unknown';
    LogUtil.d('Router', 'replace: $routeName from $oldName');
  }

  void _logNavigation(String action, Route route, Route? previousRoute) {
    final routeName = route.settings.name ?? route.runtimeType.toString();
    final prevName = previousRoute?.settings.name ?? 'root';
    LogUtil.i('Router', '$action: $routeName from $prevName');
  }
}

final routeObserverProvider = Provider<AppRouteObserver>((ref) {
  return AppRouteObserver();
});
