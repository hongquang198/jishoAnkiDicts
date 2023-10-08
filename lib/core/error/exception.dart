import '../../l10n/localization.dart';

class BaseException with Localization implements Exception {
  final dynamic _message;
  final dynamic _prefix;

  BaseException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends BaseException {
  FetchDataException({String message = '', String title = ''})
      : super(
          message,
          title,
        );
}

class BadRequestException extends BaseException {
  BadRequestException({String message = '', String title = ''})
      : super(
          message,
          title,
        );
}

class UnauthorizedException extends BaseException {
  UnauthorizedException({String message = '', String title = ''})
      : super(
          message,
          title,
        );
}

class CacheException implements Exception {}
