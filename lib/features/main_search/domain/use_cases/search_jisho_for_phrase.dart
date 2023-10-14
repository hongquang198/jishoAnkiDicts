import 'package:dartz/dartz.dart';
import 'package:japanese_ocr/features/main_search/domain/entities/jisho_definition.dart';
import 'package:japanese_ocr/features/main_search/domain/repositories/jisho_repository.dart';
import 'package:unofficial_jisho_api/api.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_cases/use_case.dart';

class SearchJishoForPhrase extends UseCase<List<JishoDefinition>, String> {
  final JishoRepository repository;

  SearchJishoForPhrase(this.repository);

  @override
  Future<Either<Failure, List<JishoDefinition>>> call(String phrase) async {
    final result = await repository.searchForPhrase(phrase: phrase);
    return result.fold(
      (failure) => Left(failure),
      (jishoApiResult) => Right(
          jishoApiResult.data?.map((e) => e.toJishoDefinitionEntity).toList() ??
              []),
    );
  }
}

extension JishoAPIResultExt on JishoResult {
  JishoDefinition get toJishoDefinitionEntity => JishoDefinition(
        slug: slug,
        isCommon: isCommon ?? false,
        tags: tags,
        jlpt: jlpt,
        word: japanese.firstOrNull?.word,
        reading: japanese.firstOrNull?.reading,
        senses: senses,
        isJmdict: attribution.jmdict,
        isJmnedict: attribution.jmnedict,
        isDbpedia: attribution.dbpedia?.isNotEmpty == true,
      );
  String get japaneseWord => slug.isEmpty
      ? slug
      : japanese.firstOrNull?.word ?? japanese.firstOrNull?.reading ?? '';
}
