import '../../domain/entities/base_response.dart';

class BaseResponseModel extends BaseResponse {
  BaseResponseModel({
    required int code,
    required String message,
  }) : super(
          code: code,
          message: message,
        );

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) =>
      BaseResponseModel(
        code: json["code"] ?? 0,
        message: json["message"] ?? '',
      );
}
