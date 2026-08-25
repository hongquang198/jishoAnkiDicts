import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

class GetFavoritesUseCase {
  final UserDataRepository repository;

  GetFavoritesUseCase(this.repository);

  Stream<List<WordCard>> call() => repository.watchFavorites();
}
