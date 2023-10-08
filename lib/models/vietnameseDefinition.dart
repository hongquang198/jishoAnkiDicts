import 'package:equatable/equatable.dart';

class VietnameseDefinition extends Equatable {
  final String word;
  final String definition;

  const VietnameseDefinition({
    this.word = '',
    this.definition = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'definition': definition,
    };
  }
  
  @override
  List<Object?> get props => [word, definition];
}
