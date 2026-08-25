import 'package:jisho_anki/core/domain/entities/user_data/user_study_stats.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

class GetStudyStatsUseCase {
  final UserDataRepository repository;

  GetStudyStatsUseCase(this.repository);

  Future<UserStudyStats> call() => repository.getStudyStats();
}
