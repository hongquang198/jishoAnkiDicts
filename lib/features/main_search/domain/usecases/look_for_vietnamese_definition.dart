import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/dictionary.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecases.dart';
import '../../../../injection.dart';
import '../../../../models/vietnameseDefinition.dart';

class LookForVietnameseDefinition extends UseCase<List<VietnameseDefinition>, String> {

  @override
  Future<Either<Failure, List<VietnameseDefinition>>> call(String phrase) async {
    try {
      final result = await getIt<Dictionary>()
          .offlineDatabase
          .searchForVnMeaning(word: phrase);
      return Right(result);
    } catch (e) {
      return Left(SqfliteFailure(message: e.toString()));
    }
  }
}