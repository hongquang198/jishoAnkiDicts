import 'package:dio/dio.dart';

import '../../core/error/exception.dart';
import '../../core/data/models/base_response_model.dart';
import '../../injection.dart';
import '../../l10n/localization.dart';

mixin ApiError {
  Localization localization = getIt<Localization>();

  String parseErrorApiToMessage(error) {
    if (error is String) {
      return error;
    }

    if (error is DioException) {
      return _parseDioError(error);
    }

    if (error is BaseException) {
      return error.toString();
    }

    return localization.l.unknownError;
  }

  String _parseDioError(DioException error) {
    final response = error.response?.data;
    try {
      if (error.response?.statusCode == 401) {
        return localization.l.tokenExpiredMessage;
      }
      if (response is String) {
        return response;
      }
      if (response is Map<String, dynamic>) {
        final baseResponse = BaseResponseModel.fromJson(response);
        if (baseResponse.code == 401) {
          return localization.l.tokenExpiredMessage;
        }
        return baseResponse.message;
      }
      return localization.l.unknownError;
    } catch (_) {
      return localization.l.unknownError;
    }
  }
}
