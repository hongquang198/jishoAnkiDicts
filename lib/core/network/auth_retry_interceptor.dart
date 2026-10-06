import 'package:dio/dio.dart';

// Transparent session renewal: on 401, renews once via [renewSession] and
// retries the original call with fresh headers. Queued (not plain)
// Interceptor, so ten concurrent 401s trigger one renewal, not ten.
// Never retries /auth/refresh itself — a dead refresh token must surface
// (sign-out) instead of looping.
class AuthRetryInterceptor extends QueuedInterceptor {
  static const _kRetried = 'auth_retried';

  final Dio _dio;
  final Future<bool> Function() _renew;
  final Map<String, String> Function()? _freshHeaders;

  AuthRetryInterceptor({
    required Dio dio,
    required Future<bool> Function() renewSession,
    Map<String, String> Function()? freshHeaders,
  })  : _dio = dio,
        _renew = renewSession,
        _freshHeaders = freshHeaders;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        req.extra[_kRetried] == true ||
        req.path == '/auth/refresh') {
      return handler.next(err);
    }
    try {
      if (!await _renew()) return handler.next(err);
      // Clone, never reuse: a consumed RequestOptions can't re-run fetch,
      // and the retry must carry fresh headers (not the dead token).
      final headers = Map<String, dynamic>.of(req.headers);
      final fresh = _freshHeaders?.call();
      if (fresh != null) headers.addAll(fresh);
      return handler.resolve(await _dio.request(
        req.path,
        data: req.data,
        queryParameters: req.queryParameters,
        cancelToken: req.cancelToken,
        onReceiveProgress: req.onReceiveProgress,
        options: Options(
          method: req.method,
          headers: headers,
          extra: Map.of(req.extra)..[_kRetried] = true,
          responseType: req.responseType,
          contentType: req.contentType,
          followRedirects: req.followRedirects,
          receiveDataWhenStatusError: req.receiveDataWhenStatusError,
          validateStatus: req.validateStatus,
          receiveTimeout: req.receiveTimeout,
          sendTimeout: req.sendTimeout,
        ),
      ));
    } catch (_) {
      return handler.next(err);
    }
  }
}
