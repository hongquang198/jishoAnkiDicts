import 'dart:developer';

import 'package:dio/dio.dart';
// Logs every REST call as `→ POST /cards/bulk` / `← 200 POST /cards/bulk (84ms)`
// plus request/response bodies. Secrets (passwords, tokens, keys) are masked
// as *** before logging; bodies over [_kMaxBodyChars] are truncated so a full
// collection pull doesn't flood the terminal.
class RestLogInterceptor extends Interceptor {
  static const _kStart = 'rest_log_start_ms';
  static const _kMaxBodyChars = 4000;
  static const _sensitiveKeys = {
    'password',
    'id_token',
    'access_token',
    'refresh_token',
    'token',
    'api_key',
    'apikey',
    'key',
    'secret',
    'authorization',
  };

  // Deep-copies maps/lists, replacing sensitive values with *** so auth
  // payloads (login passwords, Google id-tokens, JWTs) never hit the log.
  static Object? _redact(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key:
              _sensitiveKeys.contains(entry.key.toString().toLowerCase())
                  ? '***'
                  : _redact(entry.value),
      };
    }
    if (value is List) return [for (final item in value) _redact(item)];
    return value;
  }

  static String _bodyPreview(Object? data) {
    final text = data is FormData
        ? '[FormData fields: ${data.fields.map((f) => '${f.key}=***')}]'
        : '${_redact(data)}';
    return text.length <= _kMaxBodyChars
        ? text
        : '${text.substring(0, _kMaxBodyChars)}…(truncated)';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_kStart] = DateTime.now().millisecondsSinceEpoch;
    log('→ ${options.method} ${options.path}', name: 'REST');
    if (options.data != null) {
      log('  body: ${_bodyPreview(options.data)}', name: 'REST');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final req = response.requestOptions;
    final start = req.extra[_kStart] as int?;
    final ms = start == null
        ? '?'
        : DateTime.now().millisecondsSinceEpoch - start;
    log('← ${response.statusCode} ${req.method} ${req.path} (${ms}ms)',
        name: 'REST');
    if (response.data != null) {
      log('  body: ${_bodyPreview(response.data)}', name: 'REST');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    log(
        '✗ ${err.response?.statusCode ?? 'ERR'} ${req.method} ${req.path}: '
        '${err.message}',
        name: 'REST');
    if (err.response?.data != null) {
      log('  body: ${_bodyPreview(err.response!.data)}', name: 'REST');
    }
    handler.next(err);
  }
}
