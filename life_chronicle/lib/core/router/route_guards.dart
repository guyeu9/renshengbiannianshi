import 'package:go_router/go_router.dart';

class RouteGuards {
  RouteGuards._();

  static String? authGuard(GoRouterState state) {
    return null;
  }

  static String? dataPreloadGuard(GoRouterState state) {
    if (state.matchedLocation.contains('/detail/') || state.matchedLocation.contains('/:id')) {
      final id = state.pathParameters['id'];
      if (id == null || id.isEmpty) {
        return '/';
      }
    }
    return null;
  }

  static String? validateAll(GoRouterState state) {
    return authGuard(state) ?? dataPreloadGuard(state);
  }
}
