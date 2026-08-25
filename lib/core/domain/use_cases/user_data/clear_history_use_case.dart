import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

class ClearHistoryUseCase {
  final UserDataRepository repository;

  ClearHistoryUseCase(this.repository);

  Future<void> call() => repository.clearHistory();
}
