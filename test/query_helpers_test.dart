import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:jisho_anki/services/query_helpers.dart';

void main() {
  group('isSentenceQuery', () {
    test('inflected single words are not sentences', () {
      expect(isSentenceQuery('食べた'), isFalse);
      expect(isSentenceQuery('食べます'), isFalse);
      expect(isSentenceQuery('食べてください'), isFalse);
      expect(isSentenceQuery('食べさせられたくなかった'), isFalse);
      expect(isSentenceQuery('勉強'), isFalse);
    });

    test('sentences are detected', () {
      expect(isSentenceQuery('これは本です。'), isTrue);
      expect(isSentenceQuery('何を食べたの?'), isTrue);
      expect(isSentenceQuery('私は学生です'), isTrue);
    });

    test('empty query is not a sentence', () {
      expect(isSentenceQuery('  '), isFalse);
    });
  });

  group('canonicalBaseForm', () {
    test('sentence queries resolve to empty (no view)', () {
      expect(canonicalBaseForm(query: 'これは本です。'), isEmpty);
    });

    test('LLM canonical word wins over inflected surface', () {
      expect(
        canonicalBaseForm(
          query: '食べた',
          wordInfo: {'found': true, 'word': '食べる'},
        ),
        equals('食べる'),
      );
    });

    test('falls back to jisho base when LLM unavailable', () {
      const jisho = JishoDefinition(slug: '食べる', word: '食べる');
      expect(
        canonicalBaseForm(query: '食べた', jishoDefinition: jisho),
        equals('食べる'),
      );
    });

    test('falls back to trimmed query', () {
      expect(canonicalBaseForm(query: ' 勉強 '), equals('勉強'));
    });

    test('ignores LLM payload when not found', () {
      expect(
        canonicalBaseForm(
          query: '食べた',
          wordInfo: {'found': false, 'word': '食べる'},
        ),
        equals('食べた'),
      );
    });
  });
}
