import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/api/client_session.dart';
import 'package:flutter_application_1/auth/auth_session.dart';
import 'package:flutter_application_1/navigation/app_navigation.dart';
import 'package:flutter_application_1/navigation/prototype_routes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

Widget navigationApp(
  AuthSession auth,
  GlobalKey<NavigatorState> key, {
  String initialRoute = PrototypeRoutes.entry,
}) {
  return AppNavigationScope(
    session: auth,
    child: MaterialApp(
      navigatorKey: key,
      initialRoute: initialRoute,
      routes: {
        for (final route in [
          PrototypeRoutes.entry,
          PrototypeRoutes.dashboard,
          PrototypeRoutes.clientHome,
          PrototypeRoutes.clientAlbum,
          PrototypeRoutes.newClient,
          PrototypeRoutes.recording,
        ])
          route: (_) => Scaffold(
            body: Column(children: [const AppNavigationBar(), Text(route)]),
          ),
      },
    ),
  );
}

void main() {
  setUp(() {
    ApiService().clearAuthToken();
    ClientSession.clear();
  });
  tearDown(() {
    ApiService().clearAuthToken();
    ClientSession.clear();
  });

  testWidgets('로그인 전에는 로그아웃과 첫 화면의 뒤로가기를 비활성화한다', (tester) async {
    final auth = AuthSession();
    addTearDown(auth.dispose);
    await tester.pumpWidget(navigationApp(auth, GlobalKey<NavigatorState>()));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == '뒤로가기',
            ),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '로그아웃'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('뒤로가기는 기존 화면으로 돌아간다', (tester) async {
    final auth = AuthSession()..signIn();
    addTearDown(auth.dispose);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(navigationApp(auth, key));
    key.currentState!.pushNamed(PrototypeRoutes.clientAlbum);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    expect(find.text(PrototypeRoutes.entry), findsOneWidget);
  });

  testWidgets('이전 화면이 없으면 로그인한 내담자 홈으로 돌아간다', (tester) async {
    final auth = AuthSession()..signIn();
    addTearDown(auth.dispose);
    ClientSession.start(clientId: 1, loginId: 'test-client');
    await tester.pumpWidget(
      navigationApp(
        auth,
        GlobalKey<NavigatorState>(),
        initialRoute: PrototypeRoutes.clientAlbum,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    expect(find.text(PrototypeRoutes.clientHome), findsOneWidget);
  });

  testWidgets('로그아웃 취소는 세션을 유지하고 확인은 세션과 화면 이력을 지운다', (tester) async {
    final auth = AuthSession()..signIn();
    addTearDown(auth.dispose);
    ClientSession.start(clientId: 1, loginId: 'test-client');
    final headers = <Object?>[];
    final dio = createTestDio((request) {
      headers.add(request.headers['Authorization']);
      return jsonResponse({'total': 0, 'items': []});
    });
    addTearDown(() => dio.close(force: true));
    final oldApi = ApiService(dio: dio)..setAuthToken('test-token');
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(navigationApp(auth, key));
    key.currentState!.pushNamed(PrototypeRoutes.clientAlbum);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '로그아웃'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(auth.isAuthenticated, isTrue);
    expect(ClientSession.clientId, 1);
    final beforeLogout = oldApi.getAlbumList()..ignore();
    await tester.pumpAndSettle();
    await beforeLogout;
    expect(headers.last, 'Bearer test-token');

    await tester.tap(find.widgetWithText(TextButton, '로그아웃'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '로그아웃'));
    await tester.pumpAndSettle();
    expect(auth.isAuthenticated, isFalse);
    expect(ClientSession.clientId, isNull);
    expect(ClientSession.loginId, isNull);
    expect(find.text(PrototypeRoutes.entry), findsOneWidget);
    expect(key.currentState!.canPop(), isFalse);
    final afterLogout = oldApi.getAlbumList()..ignore();
    await tester.pumpAndSettle();
    await afterLogout;
    expect(headers.last, isNull);
  });

  testWidgets('녹음 화면의 뒤로가기는 종료 확인을 거친다', (tester) async {
    final auth = AuthSession()..signIn();
    addTearDown(auth.dispose);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(navigationApp(auth, key));
    key.currentState!.pushNamed(PrototypeRoutes.recording);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    expect(find.textContaining('진행 중인 녹음이 종료'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.text(PrototypeRoutes.recording), findsOneWidget);
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('이동하기'));
    await tester.pumpAndSettle();
    expect(find.text(PrototypeRoutes.entry), findsOneWidget);
  });

  test('로그인 전에 생성한 API도 새 로그인 토큰을 사용한다', () async {
    Object? header;
    final dio = createTestDio((request) {
      header = request.headers['Authorization'];
      return jsonResponse({'total': 0, 'items': []});
    });
    addTearDown(() => dio.close(force: true));
    final existingApi = ApiService(dio: dio);
    final loginApi = ApiService();
    loginApi.setAuthToken('new-token');
    await existingApi.getAlbumList();
    expect(header, 'Bearer new-token');
    loginApi.setAuthToken('another-token');
    await existingApi.getAlbumList();
    expect(header, 'Bearer another-token');
    loginApi.clearAuthToken();
    await existingApi.getAlbumList();
    expect(header, isNull);
  });
}
