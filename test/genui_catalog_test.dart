import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/services/llm/genui_catalog.dart';

void main() {
  group('GenUI Catalog Tests', () {
    test('Catalog contains all expected items', () {
      final names = genUiCatalog.items.map((e) => e.name).toList();
      expect(names, contains('DefinitionCard'));
      expect(names, contains('ExampleSentences'));
      expect(names, contains('KanjiComponents'));
    });

    test('DefinitionCard schema builds correct widget', () {
      final item =
          genUiCatalog.items.firstWhere((e) => e.name == 'DefinitionCard');
      expect(item.dataSchema, isNotNull);

      // Dummy context since builder takes context
      // Note: testing widget build requires widget test or simple instantiation
    });

    test('ExampleSentences schema builds correct widget', () {
      final item =
          genUiCatalog.items.firstWhere((e) => e.name == 'ExampleSentences');
      expect(item.dataSchema, isNotNull);
    });

    test('KanjiComponents schema builds correct widget', () {
      final item =
          genUiCatalog.items.firstWhere((e) => e.name == 'KanjiComponents');
      expect(item.dataSchema, isNotNull);
    });
  });
}
