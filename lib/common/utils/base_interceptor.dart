import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jisho_anki/common/extensions/build_context_extension.dart';
import '../../config/app_routes.dart';
import '../../core/services/navigation_service.dart';
import '../../l10n/localization.dart';

import '../../core/error/exception.dart';
import '../../injection.dart';

class BaseInterceptor extends Interceptor with Localization {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleExpiredToken();
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    Localization localization = getIt<Localization>();
    switch (response.statusCode) {
      case 200:
        break;
      case 400:
        throw BadRequestException(
          message: response.data.toString(),
          title: 
          localization.l.invalidRequest,
        );
      case 401:
        _handleExpiredToken();
        throw UnauthorizedException(
          message: response.data.toString(),
          title: localization.l.unauthorised,
        );
      case 403:
        throw UnauthorizedException(
          message: response.data.toString(),
          title: localization.l.unauthorised,
        );
      case 500:
      default:
        throw FetchDataException(
          message: '${localization.l.connectionError} ${response.statusCode}',
          title: localization.l.fetchDataError,
        );
    }
  }

  Future<void> _handleExpiredToken() async {
    final navigationService = getIt<NavigationService>();
    final currentContext = navigationService.navigatorKey.currentContext;

    if (currentContext != null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(SnackBar(
          content: Text(currentContext.localizations.tokenExpiredMessage)));
      GoRouter.of(currentContext).goNamed(AppRoutesPath.mainScreen);
    }
  }
}
