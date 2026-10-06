import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/network/auth_retry_interceptor.dart';

// Fake transport: first [failTimes] calls answer 401, the rest 200. Answers
// flow through the real pipeline (validateStatus -> error interceptors),
// exactly like a live 401 — unlike handler.reject/resolve inside onRequest,
// which bypass response validation and error routing in this Dio version.
class _StubAdapter implements HttpClientAdapter {
  var calls = 0;
  final int failTimes;
  _StubAdapter({this.failTimes = 1});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      '{"ok":true}',
      calls <= failTimes ? 401 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio stubDio({
  required Future<bool> Function() renew,
  required void Function(_StubAdapter transport) expose,
  int failTimes = 1,
}) {
  final transport = _StubAdapter(failTimes: failTimes);
  expose(transport);
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = transport;
  dio.interceptors.add(AuthRetryInterceptor(dio: dio, renewSession: renew));
  return dio;
}

void main() {
  test('401 renews once and retries to success', () async {
    var renewals = 0;
    late _StubAdapter transport;
    final dio = stubDio(
      expose: (t) => transport = t,
      renew: () async {
        renewals++;
        return true;
      },
    );
    final res = await dio.get('/cards');
    expect(res.statusCode, 200);
    expect(transport.calls, 2); // original + exactly one retry
    expect(renewals, 1);
  });

  test('failed renewal surfaces the 401', () async {
    late _StubAdapter transport;
    final dio = stubDio(
      expose: (t) => transport = t,
      renew: () async => false,
    );
    await expectLater(dio.get('/cards'), throwsA(isA<DioException>()));
    expect(transport.calls, 1); // no retry without a renewal
  });

  test('/auth/refresh itself is never retried', () async {
    var renewals = 0;
    late _StubAdapter transport;
    final dio = stubDio(
      expose: (t) => transport = t,
      renew: () async {
        renewals++;
        return true;
      },
    );
    // expectLater, not expect: the rejection is async — plain expect would
    // assert the counts before the request even runs.
    await expectLater(dio.post('/auth/refresh'), throwsA(isA<DioException>()));
    expect(transport.calls, 1); // no retry — dead refresh surfaces to sign-out
    expect(renewals, 0);
  });
}
