import 'package:equatable/equatable.dart';

/// Generic gloss of a dictionary headword in a target/localized language.
///
/// Replaces the former `VietnameseDefinition`: [headword] is the looked-up
/// term (any source language) and [gloss] is its explanation in [langCode]
/// (e.g. 'vi', 'en'). Offline asset rows (`jpvnDictionary`) carry no
/// language tag, so [langCode] defaults to empty and is only populated for
/// user-saved cards and LLM-provided glosses.
class LocalizedGloss extends Equatable {
  final String headword;
  final String gloss;
  final String langCode;

  const LocalizedGloss({
    this.headword = '',
    this.gloss = '',
    this.langCode = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'word': headword,
      'definition': gloss,
    };
  }

  factory LocalizedGloss.fromMap(Map<String, dynamic> map) {
    return LocalizedGloss(
      headword: (map['headword'] ?? map['word'])?.toString() ?? '',
      gloss: (map['gloss'] ?? map['definition'])?.toString() ?? '',
      langCode:
          map['langCode']?.toString() ?? map['lang_code']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [headword, gloss, langCode];
}
