import 'package:dio/dio.dart';
import 'package:flutter_application_1/api/api_exception.dart';
import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

void main() {
  test('내담자 등록은 별도 로그인 아이디 없이 phone과 PIN으로 요청한다', () async {
    final dio = createTestDio((request) {
      expect(request.method, 'POST');
      expect(request.path, '/clients');
      expect(request.data, {
        'name': '테스트 내담자',
        'age': 72,
        'gender': 'F',
        'phone': '01012345678',
        'memo': '상담 메모',
        'pin': '246810',
      });
      return jsonResponse({
        'id': 1,
        'name': '테스트 내담자',
        'phone': '01012345678',
        'login_id': null,
        'has_pin': true,
        'is_active': true,
      }, statusCode: 201);
    });
    addTearDown(() => dio.close(force: true));

    final client = await ApiService(dio: dio).createClient(
      name: '테스트 내담자',
      age: 72,
      gender: 'F',
      phone: '01012345678',
      pin: '246810',
      memo: '상담 메모',
    );
    expect(client.id, 1);
    expect(client.hasPin, isTrue);
    expect(client.loginId, isNull);
  });

  for (final detail in [
    '이미 등록된 전화번호입니다.',
    '상담사 계정이 쓰는 전화번호입니다.',
    '이미 사용 중인 아이디입니다.',
  ]) {
    test('409 응답 사유를 그대로 표시한다: $detail', () async {
      final dio = createTestDio(
        (_) => jsonResponse({'detail': detail}, statusCode: 409),
      );
      addTearDown(() => dio.close(force: true));

      await expectLater(
        ApiService(dio: dio).createClient(name: '테스트 내담자'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 409)
              .having((error) => error.toString(), 'message', detail),
        ),
      );
    });
  }

  test('수정 요청은 기존 login_id와 PIN을 보내지 않으면 유지한다', () async {
    final dio = createTestDio((request) {
      expect(request.method, 'PATCH');
      expect(request.path, '/clients/1');
      expect(request.data, {'name': '수정 이름', 'phone': '01012345678'});
      return jsonResponse({
        'id': 1,
        'name': '수정 이름',
        'phone': '01012345678',
        'login_id': 'existing-client',
        'has_pin': true,
        'is_active': true,
      });
    });
    addTearDown(() => dio.close(force: true));

    final client = await ApiService(
      dio: dio,
    ).updateClient(1, name: '수정 이름', phone: '01012345678');
    expect(client.loginId, 'existing-client');
    expect(client.hasPin, isTrue);
  });

  test('FastAPI의 422 검증 오류를 입력 항목별 안내로 변환한다', () async {
    final dio = createTestDio(
      (_) => jsonResponse({
        'detail': [
          {
            'type': 'string_pattern_mismatch',
            'loc': ['body', 'pin'],
            'msg': 'String should match pattern',
            'input': 'bad-pin',
          },
          {
            'type': 'string_too_long',
            'loc': ['body', 'name'],
            'msg': 'String should have at most 50 characters',
            'ctx': {'max_length': 50},
          },
        ],
      }, statusCode: 422),
    );
    addTearDown(() => dio.close(force: true));

    await expectLater(
      ApiService(dio: dio).createClient(name: '테스트 내담자'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 422)
            .having(
              (error) => error.message,
              'message',
              '비밀번호(PIN)는 숫자 6자리로 입력해 주세요.\n이름: 50자 이하로 입력해 주세요.',
            ),
      ),
    );
  });

  test('JSON이 아닌 서버 오류에도 Dio 오류 전문을 노출하지 않는다', () async {
    final dio = createTestDio(
      (_) => ResponseBody.fromString('<html>Bad Gateway</html>', 502),
    );
    addTearDown(() => dio.close(force: true));
    await expectLater(
      ApiService(dio: dio).createClient(name: '테스트 내담자'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          '내담자 등록에 실패했습니다.',
        ),
      ),
    );
  });

  test('네트워크 연결 실패를 한국어로 안내한다', () {
    final error = ApiException.fromError(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/clients'),
        reason: 'Connection refused',
      ),
      fallback: '내담자 등록에 실패했습니다.',
    );
    expect(error.message, '서버에 연결할 수 없습니다. 네트워크 상태를 확인해 주세요.');
  });
}
