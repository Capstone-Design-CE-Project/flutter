import '../auth/auth_session.dart';
import 'prototype_routes.dart';

class AuthRouteGuard {
  const AuthRouteGuard(this.authState);

  final AuthenticationState authState;

  String resolve(String requestedRoute) {
    if (authState.isAuthenticated || PrototypeRoutes.isPublic(requestedRoute)) {
      return requestedRoute;
    }
    return PrototypeRoutes.entry;
  }
}
