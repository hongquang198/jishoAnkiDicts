import 'package:dartz/dartz.dart';

import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../../../features/language/language_capability.dart';
import '../../../../injection.dart';
import '../../../../models/localized_gloss.dart';
import 'look_up_localized_gloss.dart';

/// Dispatcher behind the multilingual search box.
///
/// - Japanese target: existing offline gloss lane (jpvnDictionary).
/// - Any other target: no offline table exists, so this returns an empty
///   offline result and the LLM/GenUI lane owns the lookup. UI layers
///   consult [LanguageCapability] to decide whether to show pitch, kanji,
///   Han-Viet, or Jisho-sense sections.
class SearchDictionaryForPhrase extends UseCase<List<LocalizedGloss>, String> {
  final LookUpLocalizedGloss lookUpLocalizedGloss;

  SearchDictionaryForPhrase({required this.lookUpLocalizedGloss});

  LanguageCapability get capability =>
      getIt<SharedPref>().targetLanguageCapability;

  @override
  Future<Either<Failure, List<LocalizedGloss>>> call(String phrase) async {
    if (!capability.supportsOfflineGloss) {
      return const Right([]);
    }
    return lookUpLocalizedGloss.call(phrase);
  }
}
