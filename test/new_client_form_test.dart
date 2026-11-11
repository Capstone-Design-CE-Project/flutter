import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/api/consultation_model.dart';
import 'package:flutter_application_1/screens/CounselorScreen/new_client_form.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

Finder fieldWithHint(String hint) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.hintText == hint,
);

void main() {
  testWidgets('내담자 등록 폼은 작은 화면에서도 오류 없이 스크롤된다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: NewClientForm()));

    expect(find.text('새 내담자 추가'), findsOneWidget);
    expect(find.text('새로운 내담자 등록'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('저장하기'));
    await tester.pumpAndSettle();

    expect(find.text('저장하기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('중복 연락처 오류를 표시한 뒤 번호를 수정하면 등록할 수 있다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final requests = <Map<String, dynamic>>[];
    final dio = createTestDio((request) {
      final data = Map<String, dynamic>.from(request.data as Map);
      requests.add(data);
      if (requests.length == 1) {
        return jsonResponse({'detail': '이미 등록된 전화번호입니다.'}, statusCode: 409);
      }
      return jsonResponse({
        'id': 1,
        ...data,
        'has_pin': true,
        'is_active': true,
      }, statusCode: 201);
    });
    addTearDown(() => dio.close(force: true));
    Object? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<Object?>(
                  MaterialPageRoute<Object?>(
                    builder: (_) =>
                        NewClientForm(apiService: ApiService(dio: dio)),
                  ),
                );
              },
              child: const Text('내담자 추가'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('내담자 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(fieldWithHint('내담자의 이름을 입력하세요'), '테스트 내담자');
    await tester.enterText(fieldWithHint('숫자 6자리'), '246810');
    await tester.ensureVisible(fieldWithHint('010-0000-0000'));
    await tester.enterText(fieldWithHint('010-0000-0000'), '+82 10-1234-5678');
    await tester.ensureVisible(find.text('저장하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장하기'));
    await tester.pumpAndSettle();

    expect(find.text('이미 등록된 전화번호입니다.'), findsOneWidget);
    expect(requests.single['phone'], '01012345678');
    expect(requests.single.containsKey('login_id'), isFalse);
    expect(find.textContaining('DioException'), findsNothing);

    await tester.ensureVisible(fieldWithHint('010-0000-0000'));
    await tester.enterText(fieldWithHint('010-0000-0000'), '010-9876-5432');
    await tester.ensureVisible(find.text('저장하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장하기'));
    await tester.pumpAndSettle();

    expect(requests, hasLength(2));
    expect(requests.last['phone'], '01098765432');
    expect(result, '내담자를 등록했습니다.');
    expect(tester.takeException(), isNull);
  });

  testWidgets('정보 수정 시 기존 로그인 아이디와 비밀번호를 유지한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Map<String, dynamic>? sent;
    final dio = createTestDio((request) {
      sent = Map<String, dynamic>.from(request.data as Map);
      return jsonResponse({
        'id': 7,
        'name': '기존 내담자',
        'phone': '01012345678',
        'login_id': 'existing-client',
        'has_pin': true,
        'is_active': true,
      });
    });
    addTearDown(() => dio.close(force: true));
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigatorKey, home: const Scaffold()),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => NewClientForm(
          apiService: ApiService(dio: dio),
          initialClient: ClientDetail(
            id: 7,
            name: '기존 내담자',
            phone: '010-1234-5678',
            loginId: 'existing-client',
            hasPin: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('저장하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장하기'));
    await tester.pumpAndSettle();

    expect(sent, isNotNull);
    expect(sent!.containsKey('login_id'), isFalse);
    expect(sent!.containsKey('pin'), isFalse);
    expect(sent!['phone'], '01012345678');
    expect(tester.takeException(), isNull);
  });
}
