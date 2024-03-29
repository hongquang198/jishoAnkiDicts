import 'package:dartz/dartz.dart';
import 'package:unofficial_jisho_api/api.dart';

import '../../../common/utils/api_errors.dart';
import '../../../core/error/failures.dart';
import '../data/data_sources/jisho_remote_data_source.dart';
import '../domain/repositories/jisho_repository.dart';

class JishoRepositoryImpl extends JishoRepository with ApiErrorParseMixin {
  final JishoRemoteDataSource jishoRemoteDataSource;
  JishoRepositoryImpl({required this.jishoRemoteDataSource});

  @override
  Future<Either<Failure, JishoAPIResult>> searchForPhrase({required String phrase}) async {
    try {
      final response = await jishoRemoteDataSource.searchJishoForPhrase(phrase: phrase);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(
        message: parseErrorApiToMessage(e),
      ));
    }
  }
}