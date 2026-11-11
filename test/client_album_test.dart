import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/api/client_session.dart';
import 'package:flutter_application_1/screens/ClientScreen/client_album.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

void main() {
  setUp(() => ClientSession.start(clientId: 1, loginId: 'test-client'));
  tearDown(ClientSession.clear);

  testWidgets('조회된 이미지가 없으면 빈 앨범 안내를 표시한다', (tester) async {
    final dio = createTestDio((_) => jsonResponse({'total': 0, 'items': []}));
    addTearDown(() => dio.close(force: true));
    await tester.pumpWidget(
      MaterialApp(
        home: ClientalbumWidget(apiService: ApiService(dio: dio)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('저장된 이미지가 없습니다.'), findsOneWidget);
    expect(find.text('다시 시도'), findsNothing);
    expect(find.byType(GridView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('서버 조회 실패를 빈 앨범으로 표시하지 않고 재시도할 수 있다', (tester) async {
    var requests = 0;
    final dio = createTestDio((_) {
      requests++;
      return requests == 1
          ? jsonResponse({'detail': '서버 내부 오류가 발생했습니다.'}, statusCode: 500)
          : jsonResponse({'total': 0, 'items': []});
    });
    addTearDown(() => dio.close(force: true));
    await tester.pumpWidget(
      MaterialApp(
        home: ClientalbumWidget(apiService: ApiService(dio: dio)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('서버 내부 오류가 발생했습니다.'), findsOneWidget);
    expect(find.text('저장된 이미지가 없습니다.'), findsNothing);
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(requests, 2);
    expect(find.text('저장된 이미지가 없습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
