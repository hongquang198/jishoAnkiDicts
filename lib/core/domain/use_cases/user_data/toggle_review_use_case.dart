import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

class ToggleReviewUseCase {
  final UserDataRepository repository;

  ToggleReviewUseCase(this.repository);

  Future<void> call(WordCard card) =>
      repository.toggleReviewEnrollment(card: card);
}
