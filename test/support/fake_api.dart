import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

Dio createTestDio(ResponseBody Function(RequestOptions) respond) {
  return Dio(BaseOptions(baseUrl: 'https://example.invalid'))
    ..httpClientAdapter = _FakeApiAdapter(respond);
}

ResponseBody jsonResponse(Object body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _FakeApiAdapter implements HttpClientAdapter {
  _FakeApiAdapter(this.respond);

  final ResponseBody Function(RequestOptions) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  @override
  void close({bool force = false}) {}
}
