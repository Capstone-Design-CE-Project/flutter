import 'package:dio/dio.dart';

/// FastAPI의 오류 응답을 화면에 표시할 메시지로 변환한다.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromError(Object error, {required String fallback}) {
    if (error is ApiException) return error;
    if (error is! DioException) return ApiException(fallback);

    final status = error.response?.statusCode;
    final body = error.response?.data;
    final detail = body is Map ? body['detail'] : null;
    if (detail is String && detail.trim().isNotEmpty) {
      return ApiException(detail.trim(), statusCode: status);
    }
    if (detail is List) {
      final messages = detail.whereType<Map>().map(_validationMessage).toSet();
      if (messages.isNotEmpty) {
        return ApiException(messages.join('\n'), statusCode: status);
      }
    }

    final message = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해 주세요.',
      DioExceptionType.connectionError => '서버에 연결할 수 없습니다. 네트워크 상태를 확인해 주세요.',
      _ => switch (status) {
        401 => '인증 정보를 확인해 주세요. 로그인이 만료되었다면 다시 로그인해 주세요.',
        403 => '이 작업을 수행할 권한이 없습니다.',
        409 => '이미 등록된 정보와 중복됩니다. 입력 내용을 확인해 주세요.',
        422 => '입력한 정보의 형식을 확인해 주세요.',
        _ => fallback,
      },
    };
    return ApiException(message, statusCode: status);
  }

  static String _validationMessage(Map error) {
    final location = error['loc'];
    final field = location is List && location.isNotEmpty
        ? location.last.toString()
        : '';
    final label = switch (field) {
      'name' => '이름',
      'age' => '나이',
      'gender' => '성별',
      'phone' => '전화번호',
      'pin' => '비밀번호(PIN)',
      'login_id' => '아이디',
      'password' => '비밀번호',
      'organization' => '등록기관',
      _ => '입력 정보',
    };
    final context = error['ctx'];
    final constraints = context is Map ? context : const {};
    return switch (error['type']) {
      'string_pattern_mismatch' when field == 'pin' =>
        '비밀번호(PIN)는 숫자 6자리로 입력해 주세요.',
      'string_too_long' => '$label: ${constraints['max_length']}자 이하로 입력해 주세요.',
      'string_too_short' => '$label: ${constraints['min_length']}자 이상 입력해 주세요.',
      'greater_than_equal' => '$label: ${constraints['ge']} 이상으로 입력해 주세요.',
      'less_than_equal' => '$label: ${constraints['le']} 이하로 입력해 주세요.',
      'missing' => '$label 항목을 입력해 주세요.',
      _ => '$label: ${error['msg'] ?? '입력한 값을 확인해 주세요.'}',
    };
  }

  @override
  String toString() => message;
}
