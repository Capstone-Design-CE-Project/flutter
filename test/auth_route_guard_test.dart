import 'package:flutter_application_1/auth/auth_session.dart';
import 'package:flutter_application_1/navigation/auth_route_guard.dart';
import 'package:flutter_application_1/navigation/prototype_routes.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockAuthenticationState implements AuthenticationState {
  _MockAuthenticationState({required this.isAuthenticated});

  @override
  bool isAuthenticated;
}

void main() {
  group('AuthRouteGuard', () {
    test('비로그인 사용자가 보호 화면을 요청하면 첫 화면으로 보낸다', () {
      final authState = _MockAuthenticationState(isAuthenticated: false);
      final guard = AuthRouteGuard(authState);

      expect(guard.resolve(PrototypeRoutes.dashboard), PrototypeRoutes.entry);
      expect(guard.resolve(PrototypeRoutes.clientHome), PrototypeRoutes.entry);
    });

    test('비로그인 사용자도 첫 화면과 로그인 화면에는 접근할 수 있다', () {
      final authState = _MockAuthenticationState(isAuthenticated: false);
      final guard = AuthRouteGuard(authState);

      for (final route in PrototypeRoutes.publicRoutes) {
        expect(guard.resolve(route), route);
      }
    });

    test('로그인 사용자는 보호 화면에 접근할 수 있다', () {
      final authState = _MockAuthenticationState(isAuthenticated: true);
      final guard = AuthRouteGuard(authState);

      expect(
        guard.resolve(PrototypeRoutes.dashboard),
        PrototypeRoutes.dashboard,
      );
      expect(
        guard.resolve(PrototypeRoutes.clientHome),
        PrototypeRoutes.clientHome,
      );
    });
  });
}
