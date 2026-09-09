import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/features/language/language_capability.dart';
import 'package:jisho_anki/features/main_search/domain/entities/jisho_definition.dart';
import 'package:jisho_anki/models/localized_gloss.dart';
import 'package:jisho_anki/models/offline_word_record.dart';

void main() {
  group('LocalizedGloss', () {
    test('defaults to empty headword/gloss/langCode', () {
      const gloss = LocalizedGloss();
      expect(gloss.headword, isEmpty);
      expect(gloss.gloss, isEmpty);
      expect(gloss.langCode, isEmpty);
    });

    test('fromMap reads new keys first', () {
      final gloss = LocalizedGloss.fromMap({
        'headword': '本',
        'word': '水',
        'gloss': 'book',
        'definition': 'water',
        'lang_code': 'en',
      });
      expect(gloss.headword, equals('本'));
      expect(gloss.gloss, equals('book'));
      expect(gloss.langCode, equals('en'));
    });

    test('fromMap falls back to legacy asset keys', () {
      final gloss = LocalizedGloss.fromMap({
        'word': '水',
        'definition': 'nước',
      });
      expect(gloss.headword, equals('水'));
      expect(gloss.gloss, equals('nước'));
    });
  });

  group('headword getters', () {
    test('WordCard prefers word, then slug, then reading', () {
      const base = WordCard(id: 'x', word: '', addedAt: 1, updatedAt: 1);
      expect(
        base.copyWith(word: '本', slug: 'slug', reading: 'ほん').headword,
        equals('本'),
      );
      expect(
        base.copyWith(slug: 'slug', reading: 'ほん').headword,
        equals('slug'),
      );
      expect(base.copyWith(reading: 'ほん').headword, equals('ほん'));
    });

    test('JishoDefinition prefers word, then slug, then reading', () {
      const def = JishoDefinition(
        slug: 'slug',
        word: '本',
        reading: 'ほん',
      );
      expect(def.headword, equals('本'));
      expect(
        const JishoDefinition(slug: 'slug', reading: 'ほん').headword,
        equals('slug'),
      );
    });

    test('OfflineWordRecord prefers word, then slug, then reading', () {
      final record = OfflineWordRecord(slug: 'slug', word: '本', reading: 'ほん');
      expect(record.headword, equals('本'));
    });
  });

  group('WordCard persistence', () {
    test('round-trips localized_definition + gloss_lang', () {
      const card = WordCard(
        id: '本',
        word: '本',
        localizedGloss: 'book',
        glossLang: 'en',
        addedAt: 100,
        updatedAt: 200,
      );
      final restored = WordCard.fromMap(card.toMap());
      expect(restored.localizedGloss, equals('book'));
      expect(restored.glossLang, equals('en'));
      expect(restored.headword, equals('本'));
    });

    test('falls back to legacy vietnamese_definition from old remotes', () {
      const card = WordCard(
        id: '本',
        word: '本',
        localizedGloss: 'sách',
        addedAt: 100,
        updatedAt: 200,
      );
      final legacyDoc = Map<String, dynamic>.from(card.toMap())
        ..remove('localized_definition')
        ..['vietnamese_definition'] = 'sách';
      final restored = WordCard.fromMap(legacyDoc);
      expect(restored.localizedGloss, equals('sách'));
    });
  });

  group('LanguageCapability', () {
    test('Japanese variants enable JA-only features', () {
      for (final lang in ['Japanese', 'japanese', 'ja', 'jp']) {
        final capability = LanguageCapability(lang);
        expect(capability.isJapanese, isTrue, reason: lang);
        expect(capability.supportsPitch, isTrue);
        expect(capability.supportsKanjiComponents, isTrue);
        expect(capability.supportsHanViet, isTrue);
        expect(capability.supportsJlpt, isTrue);
        expect(capability.supportsOfflineGloss, isTrue);
      }
    });

    test('other languages disable JA-only features', () {
      const capability = LanguageCapability('English');
      expect(capability.isJapanese, isFalse);
      expect(capability.supportsPitch, isFalse);
      expect(capability.supportsKanjiComponents, isFalse);
      expect(capability.supportsHanViet, isFalse);
      expect(capability.supportsJlpt, isFalse);
      expect(capability.supportsOfflineGloss, isFalse);
    });
  });
}
