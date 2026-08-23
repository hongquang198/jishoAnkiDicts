import '../../domain/entities/base_response.dart';

class BaseResponseModel extends BaseResponse {
  BaseResponseModel({
    required super.code,
    required super.message,
  });

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) =>
      BaseResponseModel(
        code: json['code'] ?? 0,
        message: json['message'] ?? '',
      );
}
