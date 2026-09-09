import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/dictionary.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../../../injection.dart';
import '../../../../models/localized_gloss.dart';

/// Offline gloss lookup for Japanese headwords (jpvnDictionary lane).
///
/// For non-Japanese target languages there is no offline table; callers
/// should route through [SearchDictionaryForPhrase] which falls back to the
/// LLM/GenUI lane instead of calling this directly.
class LookUpLocalizedGloss extends UseCase<List<LocalizedGloss>, String> {
  @override
  Future<Either<Failure, List<LocalizedGloss>>> call(String phrase) async {
    try {
      final result = await getIt<Dictionary>()
          .offlineDatabase
          .searchForLocalizedGloss(word: phrase);
      return Right(result);
    } catch (e) {
      return Left(SqfliteFailure(message: e.toString()));
    }
  }
}
