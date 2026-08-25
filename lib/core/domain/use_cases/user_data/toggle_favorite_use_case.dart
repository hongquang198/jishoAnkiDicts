import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

class ToggleFavoriteUseCase {
  final UserDataRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> call(WordCard card) => repository.toggleFavorite(card: card);
}
