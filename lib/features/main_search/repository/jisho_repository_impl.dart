import 'package:dartz/dartz.dart';
import 'package:japanese_ocr/core/error/failures.dart';
import 'package:japanese_ocr/features/main_search/data/data_sources/jisho_remote_data_source.dart';
import 'package:unofficial_jisho_api/api.dart';

import '../../../common/utils/api_errors.dart';
import '../domain/repositories/jisho_repository.dart';

class JishoRepositoryImpl extends JishoRepository with ApiErrorParseMixin {
  final JishoRemoteDataSource jishoRemoteDataSource;
  JishoRepositoryImpl({required this.jishoRemoteDataSource});

  @override
  Future<Either<Failure, JishoAPIResult>> searchForPhrase({required String phrase}) async {
    try {
      final response = await jishoRemoteDataSource.searchForPhrase(phrase: phrase);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(
        message: parseErrorApiToMessage(e),
      ));
    }
  }
}