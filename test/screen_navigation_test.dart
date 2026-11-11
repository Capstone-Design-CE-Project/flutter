import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/api/client_session.dart';
import 'package:flutter_application_1/auth/auth_session.dart';
import 'package:flutter_application_1/config/app_settings.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/navigation/app_navigation.dart';
import 'package:flutter_application_1/navigation/prototype_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const routes = [
    PrototypeRoutes.entry,
    PrototypeRoutes.clientLogin,
    PrototypeRoutes.loginFailure,
    PrototypeRoutes.clientHome,
    PrototypeRoutes.clientAlbum,
    PrototypeRoutes.clientSummary,
    PrototypeRoutes.clientSettings,
    PrototypeRoutes.counselorLogin,
    PrototypeRoutes.counselorSignup,
    PrototypeRoutes.dashboard,
    PrototypeRoutes.clientList,
    PrototypeRoutes.clientDetail,
    PrototypeRoutes.calendar,
    PrototypeRoutes.newClient,
    PrototypeRoutes.recordingClientList,
    PrototypeRoutes.sessionInfo,
    PrototypeRoutes.sessionStart,
    PrototypeRoutes.recording,
    PrototypeRoutes.summaryGeneration,
    PrototypeRoutes.summaryReview,
    PrototypeRoutes.textConfirm,
    PrototypeRoutes.imageLoading,
    PrototypeRoutes.imageReview,
    PrototypeRoutes.sessionComplete,
    PrototypeRoutes.sessionDetail,
    PrototypeRoutes.sessionEnd,
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ClientSession.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
  });

  for (final route in routes) {
    testWidgets('$route 화면에 뒤로가기와 로그아웃이 중복 없이 표시된다', (tester) async {
      await tester.binding.setSurfaceSize(const Size(402, 874));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final auth = AuthSession()..signIn();
      final settings = AppSettings();
      await tester.pumpWidget(
        SeniorCareApp(settings: settings, authSession: auth),
      );
      await tester.pumpAndSettle();
      if (route != PrototypeRoutes.entry) {
        final context = tester.element(find.byType(AppNavigationBar));
        Navigator.of(context).pushNamed(route);
        await tester.pumpAndSettle();
      }
      expect(find.byType(AppBackButton), findsOneWidget);
      expect(find.text('로그아웃'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      auth.dispose();
      settings.dispose();
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  }
}
