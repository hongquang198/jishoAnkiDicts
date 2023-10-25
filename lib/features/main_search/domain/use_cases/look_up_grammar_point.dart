import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/dictionary.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../../../injection.dart';
import '../../../../models/grammar_point.dart';

class LookUpGrammarPoint extends UseCase<List<GrammarPoint>, String> {

  @override
  Future<Either<Failure, List<GrammarPoint>>> call(String word) async {
    try {
      final result = await getIt<Dictionary>().offlineDatabase
        .searchForGrammar(
          grammarPoint: word);
      return Right(result);
    } catch (e) {
      return Left(SqfliteFailure(message: e.toString()));
    }
  }
}