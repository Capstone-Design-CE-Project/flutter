import 'package:flutter_application_1/utils/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('백엔드와 같은 규칙으로 국내 번호와 국제 표기를 정규화한다', () {
    for (final value in [
      '010-1234-5678',
      '01012345678',
      '+82 10-1234-5678',
      '0082-10-12345678',
      '1012345678',
    ]) {
      expect(normalizePhoneNumber(value), '01012345678', reason: value);
    }
    expect(normalizePhoneNumber('02-123-4567'), '021234567');
    expect(normalizePhoneNumber('02-1234-5678'), '0212345678');
  });

  test('서버가 받지 않는 전화번호는 거부한다', () {
    for (final value in [null, '', '전화번호', '12345', '010123456789']) {
      expect(normalizePhoneNumber(value), isNull, reason: value);
    }
  });
}
