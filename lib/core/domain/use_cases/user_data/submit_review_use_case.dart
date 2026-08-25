import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

class SubmitReviewUseCase {
  final UserDataRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<WordCard> call({
    required WordCard card,
    required SrsRating rating,
    int durationMs = 0,
  }) {
    return repository.submitReview(
      card: card,
      rating: rating,
      durationMs: durationMs,
    );
  }
}
