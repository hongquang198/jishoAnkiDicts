import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../../../services/kanji_helper.dart';

class LookupHanVietReading extends UseCase<List<String>, String> {

  @override
  Future<Either<Failure, List<String>>> call(String word) async {
    try {
      final result = await KanjiHelper.getHanvietReading(
          word: word);
      return Right(result);
    } catch (e) {
      return Left(SqfliteFailure(message: e.toString()));
    }
  }
}