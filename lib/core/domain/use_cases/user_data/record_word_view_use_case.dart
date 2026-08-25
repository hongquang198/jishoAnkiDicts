import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

class RecordWordViewUseCase {
  final UserDataRepository repository;

  RecordWordViewUseCase(this.repository);

  Future<void> call(String word) => repository.recordWordView(word);
}
